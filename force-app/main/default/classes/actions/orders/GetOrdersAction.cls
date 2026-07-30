public with sharing class GetOrdersAction {
  private static List<String> statusValues;

  @InvocableMethod(label='Get Customer Orders' description='Get orders from a customer' category='Order Management')
  public static List<Output> getOrders(List<Input> requests) {
    List<Output> responses = new List<Output>();
    for (Input request : requests) {
      Output response = new Output();
      try {
        List<Order__c> orders = OrderService.getOrdersFromCustomer(request.customerId, request.orderStatus);
        response.isSuccess = true;
        response.orders = orders;
        response.message = 'Found ' + orders.size() + ' orders.';
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
    @InvocableVariable(label='Customer ID' description='Customer ID to retrieve orders from' required=true)
    public String customerId;

    @InvocableVariable(
      label='Order Status'
      description='Optional filter for order status (e.g., Delivered, Pending, Canceled)'
      required=false
    )
    public String orderStatus;
  }

  // Output wrapper for the invocable action
  public class Output {
    @InvocableVariable(label='Success' description='Whether the operation was successful')
    public Boolean isSuccess;

    @InvocableVariable(label='Message' description='Result message')
    public String message;

    @InvocableVariable(label='Orders' description='List of customer orders')
    public List<Order__c> orders;
  }

  public class OrderException extends Exception {
  }
}
