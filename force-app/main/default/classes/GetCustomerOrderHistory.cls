public with sharing class GetCustomerOrderHistory {
  @InvocableMethod(label='Get Customer Order History' description='Get past orders from a customer')
  public static List<OrderResponse> getOrders(List<OrderRequest> requests) {
    List<OrderResponse> responses = new List<OrderResponse>();

    for (OrderRequest request : requests) {
      String customerId = request.customerId;
      OrderResponse response = new OrderResponse();
      try {
        List<RestaurantOrder> orders = new List<RestaurantOrder>();

        // Query actual Order__c records for the customer
        List<Order__c> orderRecords = [
          SELECT Id, Name, Customer__c, Storefront__c, Order_Time__c, Status__c, Total_Amount__c, Storefront__r.Name
          FROM Order__c
          WHERE Customer__c = :customerId AND Status__c = 'Delivered'
          ORDER BY Order_Time__c DESC
          LIMIT 10
        ];

        // Convert Order__c records to RestaurantOrder objects
        for (Order__c orderRecord : orderRecords) {
          RestaurantOrder order = new RestaurantOrder();
          order.orderId = orderRecord.Name;
          order.customerId = orderRecord.Customer__c;
          order.storefrontId = orderRecord.Storefront__c;
          order.orderDate = orderRecord.Order_Time__c;
          order.orderStatus = orderRecord.Status__c;
          order.totalAmount = orderRecord.Total_Amount__c;

          // Query Order_Item__c records for this order
          List<Order_Item__c> orderItemRecords = [
            SELECT Id, Item_Name__c, Quantity__c, Total_Amount__c, Menu_Item__r.Price__c
            FROM Order_Item__c
            WHERE Order__c = :orderRecord.Id
          ];

          // Convert Order_Item__c records to OrderItem objects
          List<OrderItem> items = new List<OrderItem>();
          for (Order_Item__c itemRecord : orderItemRecords) {
            OrderItem item = new OrderItem();
            item.itemName = itemRecord.Item_Name__c;
            item.quantity = (Integer) itemRecord.Quantity__c;
            item.unitPrice = itemRecord.Menu_Item__r.Price__c;
            items.add(item);
          }
          order.items = items;

          orders.add(order);
        }

        response.Prompt = 'Orders: ' + JSON.serialize(orders);
      } catch (Exception e) {
        response.Prompt = 'Error occurred while processing orders: ' + e.getMessage();
      }

      responses.add(response);
    }

    return responses;
  }

  // Input wrapper for the invocable action
  public class OrderRequest {
    @InvocableVariable(label='Customer ID' description='Customer ID to retrieve orders for' required=true)
    public String customerId;

    public OrderRequest() {
    }

    public OrderRequest(String customerId) {
      this.customerId = customerId;
    }
  }

  // Output wrapper for the invocable action
  public class OrderResponse {
    @InvocableVariable(label='Prompt' description='JSON string containing order details')
    public String Prompt;
  }

  // Restaurant order data structure
  public class RestaurantOrder {
    @InvocableVariable(label='Order ID' description='Unique order identifier')
    public String orderId;

    @InvocableVariable(label='Customer ID' description='Customer who placed the order')
    public String customerId;

    @InvocableVariable(label='Storefront ID' description='ID of the storefront where the order was placed')
    public String storefrontId;

    @InvocableVariable(label='Order Date' description='When the order was placed')
    public Datetime orderDate;

    @InvocableVariable(label='Order Status' description='Current status of the order')
    public String orderStatus;

    @InvocableVariable(label='Total Amount' description='Total cost of the order')
    public Decimal totalAmount;

    @InvocableVariable(label='Items' description='List of ordered items')
    public List<OrderItem> items;
  }

  // Order item data structure
  public class OrderItem {
    @InvocableVariable(label='Item Name' description='Name of the food item')
    public String itemName;

    @InvocableVariable(label='Quantity' description='Quantity ordered')
    public Integer quantity;

    @InvocableVariable(label='Unit Price' description='Price per unit')
    public Decimal unitPrice;

    // Default constructor
    public OrderItem() {
    }

    // Constructor with parameters
    public OrderItem(String itemName, Integer quantity, Decimal unitPrice) {
      this.itemName = itemName;
      this.quantity = quantity;
      this.unitPrice = unitPrice;
    }
  }

  public class OrderException extends Exception {
  }
}
