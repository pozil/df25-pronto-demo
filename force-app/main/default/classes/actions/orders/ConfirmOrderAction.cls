/**
 * @description Invocable action to confirm orders that are in Draft status
 */
public with sharing class ConfirmOrderAction {
  @TestVisible
  private static OrderService orderService = new OrderService();

  /**
   * @description Invocable method to confirm orders
   * @param inputs List of Input containing order IDs
   * @return List of Output with results
   */
  @InvocableMethod(
    label='Confirm Order'
    description='Confirms an order by setting its status to Confirmed'
    category='Order Management'
  )
  public static List<Output> confirmOrder(List<Input> inputs) {
    List<Output> outputs = new List<Output>();

    for (Input input : inputs) {
      Output output = new Output();
      try {
        Order__c order = orderService.confirmOrder(input.orderId);
        output.orderId = order.Id;
        output.success = true;
        output.message = 'Order ' + order.Name + ' has been confirmed';
      } catch (Exception e) {
        output.success = false;
        output.message = e.getMessage();
      }
      outputs.add(output);
    }
    return outputs;
  }

  /**
   * @description Input parameters for the confirm order action
   */
  public class Input {
    @InvocableVariable(
      label='Order ID'
      description='The order ID or order number (Name) of the order to confirm'
      required=true
    )
    public String orderId;
  }

  /**
   * @description Output parameters for the confirm order action
   */
  public class Output {
    @InvocableVariable(label='Success' description='Whether the order was successfully confirmed')
    public Boolean success;

    @InvocableVariable(label='Message' description='Result message')
    public String message;

    @InvocableVariable(label='Order ID' description='The ID of the processed order')
    public String orderId;
  }
}
