/**
 * @description Invocable action to add items to an order
 */
public with sharing class AddItemToOrderAction {
  /**
   * @description Invocable method to add items to an order
   * @param inputs List of AddToOrderInput containing order ID/name, item name, and quantity
   * @return List of AddToOrderOutput with results
   */
  @InvocableMethod(
    label='Add Item to Order'
    description='Adds a menu item to an existing order with specified quantity'
    category='Order Management'
  )
  public static List<Response> addToOrder(List<Request> inputs) {
    List<Response> outputs = new List<Response>();

    for (Request input : inputs) {
      Response output = new Response();

      try {
        // Validate quantity
        if (input.quantity <= 0) {
          output.success = false;
          output.message = 'Quantity must be greater than 0.';
          outputs.add(output);
          continue;
        }

        // Get the order
        Order__c order = OrderService.getOrderFromIdOrName(input.orderId);
        output.orderId = order.Id;

        // Validate order status - only allow adding items to Draft orders
        if (order.Status__c != 'Draft') {
          output.success = false;
          output.message =
            'Cannot add items to order ' +
            order.Name +
            ' because it is in ' +
            order.Status__c +
            ' status. Only Draft orders can be modified.';
          outputs.add(output);
          continue;
        }

        // Find the menu item by name
        String menuItemName = '%' + input.orderItemName + '%';
        List<Menu_Item__c> menuItems = [
          SELECT Id, Name
          FROM Menu_Item__c
          WHERE Name LIKE :menuItemName
          LIMIT 1
        ];

        if (menuItems.isEmpty()) {
          output.success = false;
          output.message = 'Menu item "' + input.orderItemName + '" not found.';
          outputs.add(output);
          continue;
        }

        Menu_Item__c menuItem = menuItems[0];

        // Create the order item
        Order_Item__c orderItem = new Order_Item__c();
        orderItem.Order__c = order.Id;
        orderItem.Menu_Item__c = menuItem.Id;
        orderItem.Quantity__c = input.quantity;
        insert orderItem;

        // Set success message
        output.success = true;
        output.message = 'Added ' + input.quantity + ' x "' + input.orderItemName + '" to order ' + order.Name;
        output.orderItemId = orderItem.Id;
      } catch (OrderService.OrderException e) {
        output.success = false;
        output.message = e.getMessage();
      } catch (Exception e) {
        output.success = false;
        output.message = 'Error adding item to order: ' + e.getMessage();
      }

      outputs.add(output);
    }
    return outputs;
  }

  /**
   * @description Input parameters for the add to order action
   */
  public class Request {
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
  public class Response {
    @InvocableVariable(label='Success' description='Whether the item was successfully added to the order')
    public Boolean success;

    @InvocableVariable(label='Message' description='Result message')
    public String message;

    @InvocableVariable(label='Order ID' description='The ID of the order')
    public String orderId;

    @InvocableVariable(label='Order Item ID' description='The ID of the created order item')
    public String orderItemId;
  }
}
