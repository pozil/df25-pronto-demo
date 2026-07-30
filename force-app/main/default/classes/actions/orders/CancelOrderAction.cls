/**
 * @description Invocable action to cancel orders that are in Draft or Confirmed status
 */
public with sharing class CancelOrderAction {
  /**
   * @description Invocable method to cancel orders
   * @param inputs List of Input containing order IDs and optional cancelation reasons
   * @return List of Output with results
   */
  @InvocableMethod(
    label='Cancel Order'
    description='Cancels an order if it is in Draft or Confirmed status'
    category='Order Management'
  )
  public static List<Output> cancelOrder(List<Input> inputs) {
    List<Output> outputs = new List<Output>();
    for (Input input : inputs) {
      Output output = new Output();
      try {
        Order__c order = OrderService.cancelOrder(input.orderId, input.cancelationReason);
        output.isSuccess = true;
        output.message = 'Order ' + order.Name + ' was canceled';
      } catch (Exception e) {
        output.isSuccess = false;
        output.message = e.getMessage();
      }
      outputs.add(output);
    }
    return outputs;
  }

  /**
   * @description Input parameters for the cancel order action
   */
  public class Input {
    @InvocableVariable(label='Order ID' description='The order ID of the order to cancel' required=true)
    public Id orderId;

    @InvocableVariable(label='Cancelation Reason' description='Optional reason for canceling the order' required=false)
    public String cancelationReason;
  }

  /**
   * @description Output parameters for the cancel order action
   */
  public class Output {
    @InvocableVariable(label='Success' description='Whether the order was successfully canceled')
    public Boolean isSuccess;

    @InvocableVariable(label='Message' description='Result message')
    public String message;

    @InvocableVariable(label='Order ID' description='The ID of the processed order')
    public String orderId;
  }
}
