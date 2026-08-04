/**
 * Invocable Action for retrieving the first storefronts
 */
public with sharing class GetStorefrontsAction {
  @TestVisible
  private static StorefrontService storefrontService = new StorefrontService();

  /**
   * Invocable action to retrieve the first 10 storefronts
   * @param requests List of request objects
   * @return List of response objects containing the storefront data
   */
  @InvocableMethod(
    label='Get Storefronts'
    description='Retrieves the first 10 storefronts'
    category='Storefront Management'
  )
  public static List<Output> getStorefronts(List<Input> requests) {
    List<Output> responses = new List<Output>();

    for (Input request : requests) {
      Output response = new Output();
      try {
        response.storefronts = storefrontService.getStorefronts(request.recordLimit);
        response.message = 'Found ' + response.storefronts.size() + ' storefronts.';
        response.isSuccess = true;
      } catch (Exception e) {
        response.message = 'Error retrieving storefronts: ' + e.getMessage();
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
    @InvocableVariable(
      label='Record Limit'
      description='Optional maximum number of storefronts to return. Defaults to 10.'
      required=false
    )
    public Integer recordLimit;
  }

  /**
   * Response from the invocable action
   */
  public class Output {
    @InvocableVariable(label='Storefronts' description='The retrieved storefront records')
    public List<Storefront__c> storefronts;

    @InvocableVariable(label='Message' description='Success or error message')
    public String message;

    @InvocableVariable(label='Is Success' description='Indicates whether the storefronts were retrieved successfully')
    public Boolean isSuccess;
  }
}
