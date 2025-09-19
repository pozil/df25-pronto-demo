/**
 * Invocable Action for retrieving a storefront by its name
 */
public with sharing class GetStorefrontByNameAction {
  /**
   * Invocable action to retrieve a storefront by name
   * @param requests List of request objects containing storefront name
   * @return List of response objects containing the storefront data
   */
  @InvocableMethod(label='Get Storefront By Name' description='Retrieves a storefront record by its name')
  public static List<Response> getStorefrontByName(List<Request> requests) {
    List<Response> responses = new List<Response>();

    for (Request request : requests) {
      // Validate input
      if (String.isBlank(request.storefrontName)) {
        throw new IllegalArgumentException('Storefront name is required');
      }

      // Query for the storefront by name
      String likeName = '%' + request.storefrontName + '%';
      List<Storefront__c> storefronts = [
        SELECT
          Id,
          Name,
          Description__c,
          Cuisine__c,
          Address__c,
          Phone__c,
          Thumbnail__c,
          Status__c,
          Type__c,
          Average_Review_Score__c,
          Total_Reviews__c,
          Review_Summary__c
        FROM Storefront__c
        WHERE Name LIKE :likeName
      ];

      Response response = new Response();
      if (storefronts.isEmpty()) {
        response.message = 'No storefront found with name: ' + request.storefrontName;
        response.isSuccess = false;
      } else if (storefronts.size() > 1) {
        List<String> storefrontNames = new List<String>();
        for (Storefront__c storefront : storefronts) {
          storefrontNames.add(storefront.Name);
        }
        response.message = 'Multiple storefronts found. Possible matches: ' + String.join(storefrontNames, ', ');
        response.isSuccess = false;
      } else {
        response.storefront = storefronts[0];
        response.message = 'Storefront retrieved successfully';
        response.isSuccess = true;
      }
      responses.add(response);
    }

    return responses;
  }

  /**
   * Input parameters for the invocable action
   */
  public class Request {
    @InvocableVariable(label='Storefront Name' description='The name of the storefront to retrieve' required=true)
    public String storefrontName;
  }

  /**
   * Response from the invocable action
   */
  public class Response {
    @InvocableVariable(label='Storefront' description='The retrieved storefront record')
    public Storefront__c storefront;

    @InvocableVariable(label='Message' description='Success or error message')
    public String message;

    @InvocableVariable(label='Is Success' description='Indicates whether the storefront was retrieved successfully')
    public Boolean isSuccess;
  }
}
