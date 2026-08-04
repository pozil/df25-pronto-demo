/**
 * @description Invocable action to add items to an order
 */
public with sharing class AddItemToOrderAction {
  @TestVisible
  private static OrderService orderService = new OrderService();

  /**
   * @description Invocable method to add items to an order
   * @param inputs List of Input containing order ID/name, item name, and quantity
   * @return List of Output with results
   */
  @InvocableMethod(
    label='Add Item to Order'
    description='Adds a menu item to an existing order with specified quantity'
    category='Order Management'
  )
  public static List<Output> addToOrder(List<Input> inputs) {
    List<Output> outputs = new List<Output>();

    for (Input input : inputs) {
      Output output = new Output();

      try {
        Order_Item__c orderItem = orderService.addItemToOrder(input.orderId, input.orderItemName, input.quantity);

        // Set success message
        output.isSuccess = true;
        output.orderId = input.orderId;
        output.orderItemId = orderItem.Id;
        output.message = 'Added ' + input.quantity + ' ' + input.orderItemName + '" to order';
      } catch (Exception e) {
        output.isSuccess = false;
        output.message = e.getMessage();
      }
      outputs.add(output);
    }
    return outputs;
  }

  /**
   * @description Input parameters for the add to order action
   */
  public class Input {
    @InvocableVariable(
      label='Order ID'
      description='The order ID or order number (Name) of the order to add items to'
      required=true
    )
    public String orderId;

    @InvocableVariable(
      label='Order Item Name'
      description='The name of the menu item to add to the order'
      required=true
    )
    public String orderItemName;

    @InvocableVariable(label='Quantity' description='The quantity of the item to add to the order' required=true)
    public Decimal quantity;
  }

  /**
   * @description Output parameters for the add to order action
   */
  public class Output {
    @InvocableVariable(label='Success' description='Whether the item was successfully added to the order')
    public Boolean isSuccess;

    @InvocableVariable(label='Message' description='Result message')
    public String message;

    @InvocableVariable(label='Order ID' description='The ID of the order')
    public String orderId;

    @InvocableVariable(label='Order Item ID' description='The ID of the created order item')
    public String orderItemId;
  }
}
