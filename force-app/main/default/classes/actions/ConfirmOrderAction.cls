/**
 * @description Invocable action to confirm orders that are in Draft status
 */
public with sharing class ConfirmOrderAction {
  /**
   * @description Invocable method to confirm orders
   * @param inputs List of ConfirmOrderInput containing order IDs
   * @return List of ConfirmOrderOutput with results
   */
  @InvocableMethod(
    label='Confirm Order'
    description='Confirms an order by setting its status to Confirmed'
    category='Order Management'
  )
  public static List<Response> confirmOrder(List<Request> inputs) {
    List<Response> outputs = new List<Response>();

    for (Request input : inputs) {
      Response output = new Response();

      Order__c order;
      try {
        order = OrderService.getOrderFromIdOrName(input.orderId);
        output.orderId = order.Id;
      } catch (OrderService.OrderException e) {
        output.success = false;
        output.message = e.getMessage();
        outputs.add(output);
        continue;
      }

      // Check if order can be confirmed
      if (order.Status__c == 'Draft') {
        // Update order status to Confirmed
        order.Status__c = 'Confirmed';
        update order;

        // Set success message
        output.success = true;
        output.message = 'Order ' + order.Name + ' has been confirmed';
      } else {
        output.success = false;
        output.message =
          'Order ' +
          order.Name +
          ' cannot be confirmed because of its current status: ' +
          order.Status__c +
          '. Only Draft orders can be confirmed.';
      }

      outputs.add(output);
    }
    return outputs;
  }

  /**
   * @description Input parameters for the confirm order action
   */
  public class Request {
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
  public class Response {
    @InvocableVariable(label='Success' description='Whether the order was successfully confirmed')
    public Boolean success;

    @InvocableVariable(label='Message' description='Result message')
    public String message;

    @InvocableVariable(label='Order ID' description='The ID of the processed order')
    public String orderId;
  }
}
