/**
 * @description Invocable action to get the status of an order by its ID
 */
public with sharing class GetOrderStatusAction {
  /**
   * @description Invocable method to get order status
   * @param inputs List of Input parameters
   * @return List of Output results
   */
  @InvocableMethod(
    label='Get Order Status'
    description='Gets the status and details of an order by its ID'
    category='Order Management'
  )
  public static List<Output> getOrderStatus(List<Input> inputs) {
    List<Output> outputs = new List<Output>();

    for (Input input : inputs) {
      // Use OrderService to get the order
      Order__c order = OrderService.getOrderFromId(input.orderId);

      OrderStatus orderStatus = new OrderStatus();
      orderStatus.id = order.Id;
      orderStatus.name = order.Name;
      orderStatus.status = order.Status__c;
      orderStatus.customerName = order.Customer__r?.Name;
      orderStatus.storefrontName = order.Storefront__r?.Name;
      orderStatus.totalAmount = order.Total_Amount__c;
      orderStatus.orderTime = order.Order_Time__c;
      orderStatus.deliveryTime = order.Delivery_Time__c;
      orderStatus.items = OrderService.getOrderItems(order.Id);

      Output output = new Output();
      output.orderStatus = JSON.serialize(orderStatus);
      outputs.add(output);
    }

    return outputs;
  }

  /**
   * @description Input parameters for the invocable action
   */
  public class Input {
    @InvocableVariable(label='Order ID' description='The order ID of the order to get status for' required=true)
    public Id orderId;
  }

  /**
   * @description Output parameters for the invocable action
   */
  public class Output {
    @InvocableVariable(label='Order Status' description='The status of the order')
    public String orderStatus;
  }

  public class OrderStatus {
    public Id id;
    public String name;
    public String status;
    public String customerName;
    public String storefrontName;
    public Decimal totalAmount;
    public Datetime orderTime;
    public Datetime deliveryTime;
    public List<Order_Item__c> items;
  }
}
