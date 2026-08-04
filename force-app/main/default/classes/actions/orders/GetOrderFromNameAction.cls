/**
 * @description Invocable action to get an order by its order number (Name)
 */
public with sharing class GetOrderFromNameAction {
  /**
   * @description Invocable method to get an order from its order number (Name)
   * @param inputs List of Input parameters
   * @return List of Output results
   */
  @InvocableMethod(
    label='Get Order From Name'
    description='Gets the details of an order by its order number (Name)'
    category='Order Management'
  )
  public static List<Output> getOrderFromName(List<Input> inputs) {
    List<Output> outputs = new List<Output>();

    for (Input input : inputs) {
      // Use OrderService to look up the order by its order number (Name)
      Order__c order = OrderService.getOrderFromName(input.orderName);

      OrderDetails orderDetails = new OrderDetails();
      orderDetails.id = order.Id;
      orderDetails.name = order.Name;
      orderDetails.status = order.Status__c;
      orderDetails.customerName = order.Customer__r?.Name;
      orderDetails.storefrontName = order.Storefront__r?.Name;
      orderDetails.totalAmount = order.Total_Amount__c;
      orderDetails.orderTime = order.Order_Time__c;
      orderDetails.deliveryTime = order.Delivery_Time__c;

      Output output = new Output();
      output.order = JSON.serialize(orderDetails);
      outputs.add(output);
    }

    return outputs;
  }

  /**
   * @description Input parameters for the invocable action
   */
  public class Input {
    @InvocableVariable(
      label='Order Number'
      description='The order number (Name) of the order to retrieve'
      required=true
    )
    public String orderName;
  }

  /**
   * @description Output parameters for the invocable action
   */
  public class Output {
    @InvocableVariable(label='Order' description='The order details')
    public String order;
  }

  public class OrderDetails {
    public Id id;
    public String name;
    public String status;
    public String customerName;
    public String storefrontName;
    public Decimal totalAmount;
    public Datetime orderTime;
    public Datetime deliveryTime;
  }
}
