public with sharing class CreateOrderAction {
  @TestVisible
  private static OrderService orderService = new OrderService();

  @InvocableMethod(label='Create Order' description='Creates a draft order' category='Order Management')
  public static List<Output> createOrder(List<Input> requests) {
    List<Output> responses = new List<Output>();
    for (Input request : requests) {
      Output response = new Output();
      try {
        Order__c order = orderService.createDraftOrder(request.customerId, request.storefrontId);
        response.isSuccess = true;
        response.orderId = order.Id;
        response.message = 'Draft order ' + order.Name + ' created successfully. You can now add items to the order.';
      } catch (Exception e) {
        response.isSuccess = false;
        response.message = 'Error creating draft order: ' + e.getMessage();
      }
      responses.add(response);
    }
    return responses;
  }

  // Input wrapper for the invocable action
  public class Input {
    @InvocableVariable(
      label='Customer ID'
      description='ID of the customer (Contact) to create the order for'
      required=true
    )
    public String customerId;

    @InvocableVariable(label='Storefront ID' description='ID of the storefront to create the order for' required=true)
    public String storefrontId;
  }

  // Output wrapper for the invocable action
  public class Output {
    @InvocableVariable(label='Is Success' description='Indicates whether the order was created successfully')
    public Boolean isSuccess;

    @InvocableVariable(label='Order ID' description='ID of the created order (if successful)')
    public String orderId;

    @InvocableVariable(label='Message' description='Success or error message')
    public String message;
  }

  public class CreateOrderException extends Exception {
  }
}
