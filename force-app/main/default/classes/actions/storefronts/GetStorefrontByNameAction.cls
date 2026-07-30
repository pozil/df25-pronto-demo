/**
 * Invocable Action for retrieving a storefront by its name
 */
public with sharing class GetStorefrontByNameAction {
  /**
   * Invocable action to retrieve a storefront by name
   * @param requests List of request objects containing storefront name
   * @return List of response objects containing the storefront data
   */
  @InvocableMethod(
    label='Get Storefront By Name'
    description='Retrieves a storefront record by its name'
    category='Storefront Management'
  )
  public static List<Output> getStorefrontByName(List<Input> requests) {
    List<Output> responses = new List<Output>();

    for (Input request : requests) {
      Output response = new Output();
      try {
        response.storefront = StorefrontService.getStorefrontFromName(request.storefrontName);
        response.message = 'Storefront retrieved successfully';
        response.isSuccess = true;
      } catch (StorefrontService.StorefrontException e) {
        response.message = e.getMessage();
        response.isSuccess = false;
      }
      responses.add(response);
    }

    return responses;
  }

  /**
   * Input parameters for the invocable action
   */
  public class Input {
    @InvocableVariable(label='Storefront Name' description='The name of the storefront to retrieve' required=true)
    public String storefrontName;
  }

  /**
   * Response from the invocable action
   */
  public class Output {
    @InvocableVariable(label='Storefront' description='The retrieved storefront record')
    public Storefront__c storefront;

    @InvocableVariable(label='Message' description='Success or error message')
    public String message;

    @InvocableVariable(label='Is Success' description='Indicates whether the storefront was retrieved successfully')
    public Boolean isSuccess;
  }
}
