/**
 * Invocable Action for refreshing store review summaries
 */
public with sharing class RefreshStoreReviewSummariesAction {
  /**
   * Invocable action to refresh store review summaries
   * This action triggers the AI job to generate new review summaries for all storefronts
   */
  @InvocableMethod(
    label='Refresh Store Review Summaries'
    description='Triggers a job to refresh customer review summaries for all storefronts'
    category='Customer Reviews Management'
  )
  public static List<Output> refreshStoreReviewSummaries(List<Input> requests) {
    List<Output> responses = new List<Output>();
    for (Input request : requests) {
      Output response = new Output();
      try {
        ReviewService.refreshStoreReviewSummaries(request.forceRefresh);
        response.isSuccess = true;
        response.message = 'Store review summaries refresh job has been started successfully.';
      } catch (Exception e) {
        response.isSuccess = false;
        response.message = 'Error starting store review summaries refresh job: ' + e.getMessage();
        System.debug(LoggingLevel.ERROR, 'Error in RefreshStoreReviewSummariesAction: ' + e.getMessage());
      }
      responses.add(response);
    }
    return responses;
  }

  /**
   * Input parameters for the invocable action
   */
  public class Input {
    @InvocableVariable(
      label='Force Refresh'
      description='Whether to force refresh even if summaries already exist'
      required=false
    )
    public Boolean forceRefresh = false;
  }

  /**
   * Response from the invocable action
   */
  public class Output {
    @InvocableVariable(label='Success' description='Whether the operation was successful')
    public Boolean isSuccess;

    @InvocableVariable(label='Message' description='Success or error message')
    public String message;
  }
}
