public with sharing class StoreReviewSummaryAiJob {
  public static final String PROMPT_TEMPLATE_NAME = 'Customer_Review_Summary_Flex';

  public static void startJob() {
    // Create job draft
    AIJobRun jobRun = new AIJobRun(
      JobType = 'PromptTemplate',
      Target = PROMPT_TEMPLATE_NAME,
      Label = 'Refresh customer review summaries'
    );
    insert jobRun;

    // Get storefronts that have reviews
    List<Storefront__c> storefronts = [
      SELECT Id
      FROM Storefront__c
      WHERE Id IN (SELECT Storefront__c FROM Review__c)
    ];

    // Create job run items only for storefronts that have reviews
    List<AiJobRunItem> jobRunItems = new List<AiJobRunItem>();
    for (Storefront__c storefront : storefronts) {
      String promptInput = '{"Input:storefront": {"id":"' + storefront.Id + '"}}';
      AiJobRunItem runItem = new AiJobRunItem(AiJobRunId = jobRun.Id, Status = 'Ready', Input = promptInput);
      jobRunItems.add(runItem);
    }
    insert jobRunItems;

    // Start job
    jobRun.Status = 'ReadyToStart';
    update jobRun;
    System.debug('Job started to summmarize ' + storefronts.size() + ' storefront reviews: ' + jobRun.Id);
  }

  public static void handleCompletedJob(Id jobRunId) {
    // Get job run items
    List<AiJobRunItem> jobRunItems = [
      SELECT Id, Input, Response
      FROM AiJobRunItem
      WHERE AiJobRunId = :jobRunId AND Status = 'Completed'
    ];
    System.debug('Job run items: ' + jobRunItems.size());

    // Map of storefront ID to review summary
    Map<Id, String> storeIdToSummary = new Map<Id, String>();
    for (AiJobRunItem jobRunItem : jobRunItems) {
      try {
        // Parse input JSON to extract storefront ID
        Map<String, Object> inputMap = (Map<String, Object>) JSON.deserializeUntyped(jobRunItem.Input);
        Map<String, Object> storefrontInput = (Map<String, Object>) inputMap.get('Input:storefront');
        String storefrontId = (String) storefrontInput.get('id');

        // Parse response JSON to extract promptResponse
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jobRunItem.Response);
        String promptResponse = (String) responseMap.get('promptResponse');

        storeIdToSummary.put(storefrontId, promptResponse);
      } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'Error processing job run item: ' + e.getMessage());
      }
    }

    // Stop if no storefronts to update
    if (storeIdToSummary.isEmpty()) {
      System.debug('No storefronts to update');
      return;
    }

    // Update storefronts with review summaries
    try {
      Set<Id> storefrontIds = storeIdToSummary.keySet();
      List<Storefront__c> storefrontsToUpdate = [
        SELECT Id, Review_Summary__c
        FROM Storefront__c
        WHERE Id IN :storefrontIds
      ];
      for (Storefront__c storefront : storefrontsToUpdate) {
        storefront.Review_Summary__c = storeIdToSummary.get(storefront.Id);
      }
      update storefrontsToUpdate;
      System.debug('Updated ' + storefrontsToUpdate.size() + ' storefronts with review summaries');
    } catch (Exception e) {
      System.debug(LoggingLevel.ERROR, 'Error updating storefronts: ' + e.getMessage());
    }
  }
}
