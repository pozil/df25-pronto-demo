/**
 * @description Invocable action to get the status of an order by its ID
 */
public with sharing class GetOrderStatusAction {
  /**
   * @description Invocable method to get order status
   * @param inputs List of GetOrderStatusInput parameters
   * @return List of GetOrderStatusOutput results
   */
  @InvocableMethod(
    label='Get Order Status'
    description='Gets the status and details of an order by its ID'
    category='Order Management'
  )
  public static List<GetOrderStatusOutput> getOrderStatus(List<GetOrderStatusInput> inputs) {
    List<GetOrderStatusOutput> outputs = new List<GetOrderStatusOutput>();

    for (GetOrderStatusInput input : inputs) {
      // Use OrderService to get the order
      Order__c order = OrderService.getOrderFromIdOrName(input.orderId);

      OrderStatus orderStatus = new OrderStatus();
      orderStatus.orderId = order.Id;
      orderStatus.orderNumber = order.Name;
      orderStatus.status = order.Status__c;
      orderStatus.customerName = order.Customer__r?.Name;
      orderStatus.storefrontName = order.Storefront__r?.Name;
      orderStatus.totalAmount = order.Total_Amount__c;
      orderStatus.orderTime = order.Order_Time__c;
      orderStatus.deliveryTime = order.Delivery_Time__c;

      GetOrderStatusOutput output = new GetOrderStatusOutput();
      output.orderStatus = orderStatus;
      outputs.add(output);
    }

    return outputs;
  }

  /**
   * @description Input parameters for the invocable action
   */
  public class GetOrderStatusInput {
    @InvocableVariable(
      label='Order ID'
      description='The order ID or order number (Name) of the order to get status for'
      required=true
    )
    public String orderId;
  }

  /**
   * @description Output parameters for the invocable action
   */
  public class GetOrderStatusOutput {
    @InvocableVariable(label='Order Status' description='The status of the order')
    public OrderStatus orderStatus;
  }

  public class OrderStatus {
    public String orderId;
    public String orderNumber;
    public String status;
    public String customerName;
    public String storefrontName;
    public Decimal totalAmount;
    public Datetime orderTime;
    public Datetime deliveryTime;
  }
}
