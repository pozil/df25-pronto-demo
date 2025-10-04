public with sharing class ContentVersionTriggerHandler {
  private static Map<String, Menu_Category__c> menuCategoriesByName;

  private static final String EXCLUDE_STOREFRONT_NAME_PATTERN = 'Fusion';

  /**
   * Handles after insert events for ContentVersion records
   * Checks if the ContentVersion is attached to a Storefront__c record and runs menu extraction
   * @param newContentVersions List of newly inserted ContentVersion records
   */
  public static void handleAfterInsert(List<ContentVersion> newContentVersions) {
    // Get ContentDocument IDs from the ContentVersion records
    Set<Id> contentDocumentIds = new Set<Id>();
    for (ContentVersion cv : newContentVersions) {
      if (cv.ContentDocumentId != null) {
        contentDocumentIds.add(cv.ContentDocumentId);
      }
    }

    if (contentDocumentIds.isEmpty()) {
      return;
    }

    // Query for ContentDocumentLink records to find Storefront__c attachments
    List<ContentDocumentLink> contentDocumentLinks = [
      SELECT Id, ContentDocumentId, LinkedEntityId, LinkedEntity.Type
      FROM ContentDocumentLink
      WHERE ContentDocumentId IN :contentDocumentIds
      WITH USER_MODE
    ];

    // Filter out ContentDocumentLinks that are not linked to Storefront__c records
    List<ContentDocumentLink> storefrontLinks = new List<ContentDocumentLink>();
    for (ContentDocumentLink cdl : contentDocumentLinks) {
      if (cdl.LinkedEntity.Type == 'Storefront__c') {
        storefrontLinks.add(cdl);
      }
    }

    if (storefrontLinks.isEmpty()) {
      return;
    }

    // Extract Storefront IDs
    Set<Id> storefrontIds = new Set<Id>();
    for (ContentDocumentLink cdl : storefrontLinks) {
      storefrontIds.add(cdl.LinkedEntityId);
    }

    // Query for Storefront records
    List<Storefront__c> storefronts = [
      SELECT Id, Name
      FROM Storefront__c
      WHERE Id IN :storefrontIds
      WITH USER_MODE
    ];

    if (storefronts.isEmpty()) {
      return;
    }

    // Process each storefront for menu extraction
    for (Storefront__c storefront : storefronts) {
      // Only process storefronts that do not match the exclude pattern
      if (!storefront.Name.contains(EXCLUDE_STOREFRONT_NAME_PATTERN)) {
        processStorefront(storefront.Id);
      }
    }
  }

  @future
  private static void processStorefront(Id storefrontId) {
    Storefront__c storefront = [SELECT Id, Name FROM Storefront__c WHERE Id = :storefrontId];
    String promptResponse = callExtractMenuPrompt(storefront);
    System.debug('Prompt Response: ' + promptResponse);
    parseAndInsertMenuItems(promptResponse, storefront);
    deleteAttachments(storefrontId);
  }

  private static void deleteAttachments(Id storefrontId) {
    List<ContentDocumentLink> attachments = [
      SELECT Id, ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :storefrontId
    ];
    Set<Id> contentDocumentIds = new Set<Id>();
    for (ContentDocumentLink cdl : attachments) {
      contentDocumentIds.add(cdl.ContentDocumentId);
    }
    delete [SELECT Id FROM ContentDocument WHERE Id IN :contentDocumentIds];
  }

  /**
   * Processes menu extraction for a single storefront using the Extract_Menu prompt template
   * @param storefront The Storefront__c record to process
   * @return The response from the prompt template
   */
  private static String callExtractMenuPrompt(Storefront__c storefrontRecord) {
    try {
      // Create inputs
      Map<String, Object> storefront = new Map<String, Object>();
      storefront.put('id', storefrontRecord.Id);
      ConnectApi.WrappedValue storefrontValue = new ConnectApi.WrappedValue();
      storefrontValue.value = storefront;
      Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
      inputParams.put('Input:storefront', storefrontValue);

      // Configure invocation parameters
      ConnectApi.EinsteinPromptTemplateGenerationsInput executeTemplateInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
      executeTemplateInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
      executeTemplateInput.additionalConfig.applicationName = 'PromptBuilderPreview';
      executeTemplateInput.isPreview = false;
      executeTemplateInput.inputParams = inputParams;

      // Call the prompt template
      ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
        'Extract_Menu',
        executeTemplateInput
      );
      ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];
      return response.text;
    } catch (Exception e) {
      throw new MenuParsingException(
        'Error running menu extraction prompt for storefront ' +
          storefrontRecord.Name +
          ' (' +
          storefrontRecord.Id +
          '): ' +
          e.getMessage()
      );
    }
  }

  /**
   * Parses the menu items from the prompt response and inserts them into the database
   * @param promptResponse The response from the prompt template
   * @param storefrontRecord The Storefront__c record to insert the menu items into
   */
  private static void parseAndInsertMenuItems(String promptResponse, Storefront__c storefrontRecord) {
    List<Menu_Item__c> menuItems;
    try {
      menuItems = (List<Menu_Item__c>) JSON.deserialize(promptResponse, List<Menu_Item__c>.class);
    } catch (Exception e) {
      throw new MenuParsingException(
        'Error parsing menu items for storefront ' +
          storefrontRecord.Name +
          ' (' +
          storefrontRecord.Id +
          '): ' +
          e.getMessage()
      );
    }

    // Retrieve or create a menu
    Menu__c menu = getMenuFromStorefrontAndName(storefrontRecord, 'Standard Menu');
    if (menu == null) {
      // Create a menu
      menu = new Menu__c(
        Menu_Display_Name__c = 'Standard Menu',
        Description__c = 'Standard menu imported from a PDF file',
        Storefront__c = storefrontRecord.Id,
        Active__c = true
      );
      insert menu;
    } else {
      // Delete existing menu items
      delete [SELECT Id FROM Menu_Item__c WHERE Menu__c = :menu.Id];
    }

    // Add menu items
    for (Menu_Item__c menuItem : menuItems) {
      menuItem.Menu__c = menu.Id;
      menuItem.Available__c = true;
      menuItem.Menu_Category__c = getMenuCategoryId(menuItem.Menu_Category__c);
    }
    insert menuItems;
  }

  // Get menu from storefront and menu name
  private static Menu__c getMenuFromStorefrontAndName(Storefront__c storefront, String menuName) {
    List<Menu__c> menus = [
      SELECT Id
      FROM Menu__c
      WHERE Storefront__c = :storefront.Id AND Menu_Display_Name__c = :menuName
    ];
    if (menus.isEmpty()) {
      return null;
    }
    return menus[0];
  }

  private static Id getMenuCategoryId(String categoryName) {
    if (menuCategoriesByName == null) {
      // Initialize the map with existing categories
      List<Menu_Category__c> categories = [
        SELECT Id, Name
        FROM Menu_Category__c
      ];
      menuCategoriesByName = new Map<String, Menu_Category__c>();
      for (Menu_Category__c category : categories) {
        menuCategoriesByName.put(category.Name.toLowerCase(), category);
      }
    }

    // Try to find an existing category with the given name (case-insensitive)
    String normalizedCategoryName = categoryName.toLowerCase();
    if (menuCategoriesByName.containsKey(normalizedCategoryName)) {
      return menuCategoriesByName.get(normalizedCategoryName).Id;
    }

    // If no category found, create a new one
    Menu_Category__c newCategory = new Menu_Category__c(Name = categoryName);
    insert newCategory;

    // Add the new category to our map for future lookups
    menuCategoriesByName.put(normalizedCategoryName, newCategory);

    return newCategory.Id;
  }

  public class MenuParsingException extends Exception {
  }
}
