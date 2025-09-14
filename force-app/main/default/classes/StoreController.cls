public with sharing class StoreController {
  private static final Integer DEFAULT_PAGE_SIZE = 9;

  /**
   * Endpoint that retrieves a paged and filtered list of stores
   * @param searchKey String used for searching on store name and owner
   * @param type Storefront type
   * @param cuisine Storefront cuisine
   * @param minReviewScore Minimum review score
   * @param pageSize Number of stores per page
   * @param pageNumber Page number
   * @return PagedResult object holding the paged and filtered list of stores
   */
  @AuraEnabled(cacheable=true scope='global')
  public static PagedResult getPagedStoreList(
    String searchKey,
    String type,
    String cuisine,
    Integer minReviewScore,
    Integer pageSize,
    Integer pageNumber
  ) {
    // Normalize inputs
    Integer safePageSize = pageSize ?? DEFAULT_PAGE_SIZE;
    Integer safePageNumber = pageNumber ?? 1;
    String searchPattern = '%' + searchKey + '%';
    Integer offset = (safePageNumber - 1) * safePageSize;

    // Prepare filter conditions
    List<String> conditions = new List<String>();
    if (!String.isBlank(searchKey)) {
      conditions.add('(Name LIKE :searchPattern OR Address__City__s LIKE :searchPattern)');
    }
    if (!String.isBlank(type)) {
      conditions.add('Type__c >= :type');
    }
    if (!String.isBlank(cuisine)) {
      conditions.add('Cuisine__c = :cuisine');
    }
    if (minReviewScore != null) {
      conditions.add('Average_Review_Score__c >= :minReviewScore');
    }

    // Count records
    String countQuery = 'SELECT COUNT() FROM Storefront__c ';
    if (conditions.size() > 0) {
      countQuery += 'WHERE ' + String.join(conditions, ' AND ');
    }
    countQuery += ' WITH USER_MODE';
    Integer totalItemCount = Database.countQuery(countQuery);

    // Retrieve records
    String query = 'SELECT Id, Name, Account__c, Address__City__s, Average_Review_Score__c, Description__c, Menu_Count__c, Phone__c, Primary_Contact__c, Status__c, Total_Reviews__c, Total_Score__c, Type__c, Thumbnail__c FROM Storefront__c ';
    if (conditions.size() > 0) {
      query += 'WHERE ' + String.join(conditions, ' AND ');
    }
    query += ' WITH USER_MODE' + ' ORDER BY Name' + ' LIMIT :safePageSize' + ' OFFSET :offset';
    List<Storefront__c> stores = Database.query(query);

    // Return paginated results
    PagedResult result = new PagedResult();
    result.pageSize = safePageSize;
    result.pageNumber = safePageNumber;
    result.totalItemCount = totalItemCount;
    result.records = stores;
    return result;
  }

  /**
   * Retrieves storefront's opening hours
   * @param storefrontId The ID of the store to get opening hours for
   * @return List of Storefront_Hours_of_Operation__c records containing day, opening time, and closing time
   */
  @AuraEnabled(cacheable=true)
  public static List<Storefront_Hours_of_Operation__c> getStoreOpeningHours(Id storeId) {
    if (String.isBlank(storeId)) {
      throw new AuraHandledException('Storefront ID is required');
    }

    try {
      return [
        SELECT Day_of_Week__c, Opening_Time__c, Closing_Time__c
        FROM Storefront_Hours_of_Operation__c
        WHERE Storefront__c = :storeId
        WITH USER_MODE
        ORDER BY Day_of_Week__c
      ];
    } catch (Exception e) {
      throw new AuraHandledException('Error retrieving store opening hours: ' + e.getMessage());
    }
  }

  /**
   * Retrieves storefront's menus
   * @param storeId The ID of the store to get menus for
   * @return List of Menu__c records containing menu details
   */
  @AuraEnabled(cacheable=true)
  public static List<Menu__c> getStoreMenus(Id storeId) {
    if (String.isBlank(storeId)) {
      throw new AuraHandledException('Storefront ID is required');
    }

    try {
      return [
        SELECT Id, Menu_Display_Name__c, Description__c
        FROM Menu__c
        WHERE Storefront__c = :storeId AND Active__c = TRUE
        WITH USER_MODE
        ORDER BY Menu_Display_Name__c
      ];
    } catch (Exception e) {
      throw new AuraHandledException('Error retrieving store menus: ' + e.getMessage());
    }
  }
}
