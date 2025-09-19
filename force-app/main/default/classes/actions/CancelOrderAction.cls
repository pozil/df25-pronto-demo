/**
 * @description Invocable action to cancel orders that are in Draft or Confirmed status
 */
public with sharing class CancelOrderAction {
  /**
   * @description Invocable method to cancel orders
   * @param inputs List of CancelOrderInput containing order IDs and optional cancellation reasons
   * @return List of CancelOrderOutput with results
   */
  @InvocableMethod(
    label='Cancel Order'
    description='Cancels an order if it is in Draft or Confirmed status'
    category='Order Management'
  )
  public static List<CancelOrderOutput> cancelOrder(List<CancelOrderInput> inputs) {
    List<CancelOrderOutput> outputs = new List<CancelOrderOutput>();

    for (CancelOrderInput input : inputs) {
      CancelOrderOutput output = new CancelOrderOutput();

      try {
        // Use OrderService to get the order
        Order__c order = OrderService.getOrderFromIdOrName(input.orderId);
        output.orderId = order.Id;

        // Check if order can be canceled
        if (order.Status__c == 'Draft' || order.Status__c == 'Confirmed') {
          // Update order status to Canceled
          order.Status__c = 'Canceled';
          if (String.isNotBlank(input.cancellationReason)) {
            order.Cancellation_Reason__c = input.cancellationReason;
          }
          update order;
          // Set success message
          output.success = true;
          output.message = 'Order ' + order.Name + ' was cancelled';
        } else {
          output.success = false;
          output.message =
            'Order ' +
            order.Name +
            ' cannot be cancelled because of its current status: ' +
            order.Status__c +
            '.';
        }
      } catch (OrderService.OrderException e) {
        output.success = false;
        output.message = e.getMessage();
      }

      outputs.add(output);
    }
    return outputs;
  }

  /**
   * @description Input parameters for the cancel order action
   */
  public class CancelOrderInput {
    @InvocableVariable(
      label='Order ID'
      description='The order ID or order number (Name) of the order to cancel'
      required=true
    )
    public String orderId;

    @InvocableVariable(
      label='Cancellation Reason'
      description='Optional reason for cancelling the order'
      required=false
    )
    public String cancellationReason;
  }

  /**
   * @description Output parameters for the cancel order action
   */
  public class CancelOrderOutput {
    @InvocableVariable(label='Success' description='Whether the order was successfully cancelled')
    public Boolean success;

    @InvocableVariable(label='Message' description='Result message')
    public String message;

    @InvocableVariable(label='Order ID' description='The ID of the processed order')
    public String orderId;
  }
}
