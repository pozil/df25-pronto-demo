/**
 * Invocable Action for retrieving customer reviews for a given storefront
 */
public with sharing class GetCustomerReviewsAction {
  /**
   * Invocable action to retrieve customer reviews for a storefront
   * @param requests List of request objects containing storefront ID
   * @return List of response objects containing the reviews and metadata
   */
  @InvocableMethod(label='Get Customer Reviews' description='Retrieves customer reviews for a specific storefront')
  public static List<Response> getCustomerReviews(List<Request> requests) {
    List<Response> responses = new List<Response>();

    for (Request request : requests) {
      Response response = new Response();
      try {
        // Validate input
        if (String.isBlank(request.storefrontId)) {
          throw new IllegalArgumentException('Storefront ID is required');
        }

        // Execute the query
        List<Review__c> reviews = [
          SELECT Id, Rating__c, Comments__c, Status__c, Order_Date__c, CreatedDate
          FROM Review__c
          WHERE Storefront__c = :request.storefrontId
          ORDER BY CreatedDate DESC
        ];

        // Format the response
        response.isSuccess = true;
        response.reviews = reviews;
        response.message = 'Successfully retrieved ' + reviews.size() + ' reviews';
      } catch (Exception e) {
        response.isSuccess = false;
        response.message = 'Error retrieving customer reviews: ' + e.getMessage();
        response.reviews = null;
        System.debug(LoggingLevel.ERROR, 'Error in GetCustomerReviewsAction: ' + e.getMessage());
      }

      responses.add(response);
    }

    return responses;
  }

  /**
   * Input parameters for the invocable action
   */
  public class Request {
    @InvocableVariable(
      label='Storefront ID'
      description='The ID of the storefront to retrieve reviews for'
      required=true
    )
    public String storefrontId;
  }

  /**
   * Response from the invocable action
   */
  public class Response {
    @InvocableVariable(label='Success' description='Whether the operation was successful')
    public Boolean isSuccess;

    @InvocableVariable(label='Message' description='Success or error message')
    public String message;

    @InvocableVariable(label='Reviews' description='List of customer reviews')
    public List<Review__c> reviews;
  }
}
