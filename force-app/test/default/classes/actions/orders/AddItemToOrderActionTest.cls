/**
 * Tests for AddItemToOrderAction.
 */
@isTest
private class AddItemToOrderActionTest {
  @TestSetup
  static void setupTestData() {
    Storefront__c storefront = TestDataFactory.createStorefronts(1, true)[0];
    Contact customer = TestDataFactory.createCustomers(1, true)[0];
    Menu__c menu = TestDataFactory.createMenu(storefront.Id, true);
    TestDataFactory.createMenuItems(menu.Id, 1, true);
    TestDataFactory.createOrders(customer.Id, storefront.Id, 'Draft', 1, true);
  }

  @isTest
  static void shouldAddItem_WhenOrderIsDraft() {
    // Given
    Order__c order = [SELECT Id FROM Order__c LIMIT 1];
    AddItemToOrderAction.Input request = new AddItemToOrderAction.Input();
    request.orderId = order.Id;
    request.orderItemName = TestDataFactory.MENU_ITEM_NAME_PREFIX + '0';
    request.quantity = 2;

    // When
    Test.startTest();
    List<AddItemToOrderAction.Output> responses = AddItemToOrderAction.addToOrder(
      new List<AddItemToOrderAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.areEqual(1, responses.size(), 'One response should be returned');
    Assert.isTrue(responses[0].isSuccess, 'Response should be successful');
    Assert.isNotNull(responses[0].orderItemId, 'An order item ID should be returned');
    Order_Item__c orderItem = [SELECT Id, Quantity__c FROM Order_Item__c WHERE Id = :responses[0].orderItemId LIMIT 1];
    Assert.areEqual(2, orderItem.Quantity__c, 'The order item should have the requested quantity');
  }

  @isTest
  static void shouldReturnError_WhenMenuItemNotFound() {
    // Given
    Order__c order = [SELECT Id FROM Order__c LIMIT 1];
    AddItemToOrderAction.Input request = new AddItemToOrderAction.Input();
    request.orderId = order.Id;
    request.orderItemName = 'Nonexistent Item';
    request.quantity = 1;

    // When
    Test.startTest();
    List<AddItemToOrderAction.Output> responses = AddItemToOrderAction.addToOrder(
      new List<AddItemToOrderAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.isFalse(responses[0].isSuccess, 'Response should not be successful');
    Assert.isTrue(responses[0].message.contains('not found'), 'Message should indicate the menu item was not found');
  }

  @isTest
  static void shouldReturnError_WhenOrderIsNotDraft() {
    // Given
    Order__c order = [SELECT Id FROM Order__c LIMIT 1];
    order.Status__c = 'Confirmed';
    update order;
    AddItemToOrderAction.Input request = new AddItemToOrderAction.Input();
    request.orderId = order.Id;
    request.orderItemName = TestDataFactory.MENU_ITEM_NAME_PREFIX + '0';
    request.quantity = 1;

    // When
    Test.startTest();
    List<AddItemToOrderAction.Output> responses = AddItemToOrderAction.addToOrder(
      new List<AddItemToOrderAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.isFalse(responses[0].isSuccess, 'Response should not be successful');
    Assert.isTrue(
      responses[0].message.contains('Only Draft orders can be modified'),
      'Message should indicate only Draft orders can be modified'
    );
  }
}
