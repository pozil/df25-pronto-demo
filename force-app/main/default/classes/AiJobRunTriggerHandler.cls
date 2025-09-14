public with sharing class AiJobRunTriggerHandler {
  /**
   * Handles after update events for AiJobRun records
   * @param oldList List of old AiJobRun records
   * @param newList List of new AiJobRun records
   */
  public static void handleAfterUpdate(List<AiJobRun> oldJobs, List<AiJobRun> updatedJobs) {
    // Handle completed job runs for Store Review Summary prompt template
    for (AiJobRun job : updatedJobs) {
      if (
        job.JobType == 'PromptTemplate' &&
        job.Target == StoreReviewSummaryAiJob.PROMPT_TEMPLATE_NAME &&
        job.Status == 'Completed'
      ) {
        StoreReviewSummaryAiJob.handleCompletedJob(job.Id);
      }
    }
  }
}
