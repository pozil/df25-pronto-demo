public with sharing class GetCustomerOrdersAction {
  private static List<String> statusValues;

  @InvocableMethod(label='Get Customer Orders' description='Get orders from a customer')
  public static List<OrderResponse> getOrders(List<OrderRequest> requests) {
    List<OrderResponse> responses = new List<OrderResponse>();

    for (OrderRequest request : requests) {
      String customerId = request.customerId;
      String orderStatus = request.orderStatus;

      if (!isValidStatusValue(orderStatus)) {
        throw new OrderException('Invalid status value: ' + orderStatus);
      }

      // Build dynamic SOQL query based on optional order status parameter
      String soqlQuery =
        'SELECT Id, Name, Customer__c, Storefront__c, Order_Time__c, Status__c, Total_Amount__c, Storefront__r.Name ' +
        'FROM Order__c ' +
        'WHERE Customer__c = :customerId';
      if (String.isNotBlank(orderStatus)) {
        soqlQuery += ' AND Status__c = :orderStatus';
      }
      soqlQuery += ' ORDER BY Order_Time__c DESC LIMIT 10';

      // Query orders
      OrderResponse response = new OrderResponse();
      response.orders = Database.query(soqlQuery);
      responses.add(response);
    }

    return responses;
  }

  private static Boolean isValidStatusValue(String value) {
    if (statusValues == null)
      return true;

    // Load status values if not already loaded
    if (statusValues == null) {
      Set<String> statusValues = new Set<String>();
      try {
        Schema.DescribeFieldResult fieldDescribe = Order__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {
          if (entry.isActive()) {
            statusValues.add(entry.getValue());
          }
        }
      } catch (Exception e) {
        throw new OrderException('Error retrieving status picklist values: ' + e.getMessage());
      }
    }
    return statusValues.contains(value);
  }

  // Input wrapper for the invocable action
  public class OrderRequest {
    @InvocableVariable(label='Customer ID' description='Customer ID to retrieve orders from' required=true)
    public String customerId;

    @InvocableVariable(
      label='Order Status'
      description='Optional filter for order status (e.g., Delivered, Pending, Cancelled)'
      required=false
    )
    public String orderStatus;
  }

  // Output wrapper for the invocable action
  public class OrderResponse {
    @InvocableVariable(label='Orders' description='List of customer orders')
    public List<Order__c> orders;
  }

  public class OrderException extends Exception {
  }
}
