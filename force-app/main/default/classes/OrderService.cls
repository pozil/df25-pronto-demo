public with sharing class OrderService {
  public static Order__c getOrderFromIdOrName(String orderIdOrName) {
    // Configure filter based on order ID or name format
    String filter = 'Id = :orderIdOrName';
    if (orderIdOrName.startsWith('O-')) {
      filter = 'Name = :orderIdOrName';
    }

    // Query the order with the filter
    String soqlQuery =
      'SELECT Id, Name, Status__c, Customer__r.Name, Storefront__r.Name, Total_Amount__c, Order_Time__c, Delivery_Time__c FROM Order__c WHERE ' +
      filter +
      ' LIMIT 1';
    List<Order__c> orders = Database.query(soqlQuery);
    if (orders.isEmpty()) {
      throw new OrderException('No order found with ID or name: ' + orderIdOrName);
    }
    return orders[0];
  }

  public class OrderException extends Exception {
  }
}
