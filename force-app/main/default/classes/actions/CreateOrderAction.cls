public with sharing class CreateOrderAction {
  @InvocableMethod(label='Create Order' description='Creates a draft order')
  public static List<Response> createOrder(List<Request> requests) {
    List<Response> responses = new List<Response>();

    for (Request request : requests) {
      Response response = new Response();

      try {
        // Get contact with delivery address
        Contact customer = [
          SELECT Id, MailingAddress, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
          FROM Contact
          WHERE Id = :request.customerId
          LIMIT 1
        ];

        // Create the draft order
        Order__c newOrder = new Order__c();
        newOrder.Customer__c = request.customerId;
        newOrder.Storefront__c = request.storefrontId;
        newOrder.Status__c = 'Draft';
        newOrder.Order_Time__c = System.now();
        newOrder.Delivery_Address__Street__s = customer.MailingStreet;
        newOrder.Delivery_Address__City__s = customer.MailingCity;
        newOrder.Delivery_Address__StateCode__s = 'CA';
        newOrder.Delivery_Address__PostalCode__s = customer.MailingPostalCode;
        newOrder.Delivery_Address__CountryCode__s = 'US';
        insert newOrder;

        // Get the inserted order name
        Order__c insertedOrder = [SELECT Name FROM Order__c WHERE Id = :newOrder.Id LIMIT 1];

        // Create the order items
        response.isSuccess = true;
        response.orderId = newOrder.Id;
        response.message =
          'Draft order ' +
          insertedOrder.Name +
          ' created successfully. You can now add items to the order.';
      } catch (Exception e) {
        response.isSuccess = false;
        response.message = 'Error creating draft order: ' + e.getMessage();
      }

      responses.add(response);
    }

    return responses;
  }

  // Input wrapper for the invocable action
  public class Request {
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
  public class Response {
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
