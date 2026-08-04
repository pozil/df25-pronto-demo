/**
 * Tests for GetOrderFromNameAction.
 */
@isTest
private class GetOrderFromNameActionTest {
  @TestSetup
  static void setupTestData() {
    Storefront__c storefront = TestDataFactory.createStorefronts(1, true)[0];
    Contact customer = TestDataFactory.createCustomers(1, true)[0];
    TestDataFactory.createOrders(customer.Id, storefront.Id, 'Confirmed', 1, true);
  }

  @isTest
  static void shouldReturnOrder_WhenLookupByName() {
    // Given
    Order__c order = [SELECT Id, Name FROM Order__c LIMIT 1];
    GetOrderFromNameAction.Input request = new GetOrderFromNameAction.Input();
    request.orderName = order.Name;

    // When
    Test.startTest();
    List<GetOrderFromNameAction.Output> responses = GetOrderFromNameAction.getOrderFromName(
      new List<GetOrderFromNameAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.areEqual(1, responses.size(), 'One response should be returned');
    GetOrderFromNameAction.OrderDetails details = (GetOrderFromNameAction.OrderDetails) JSON.deserialize(
      responses[0].order,
      GetOrderFromNameAction.OrderDetails.class
    );
    Assert.areEqual(order.Id, details.id, 'The returned order should be for the requested order number');
    Assert.areEqual(order.Name, details.name, 'The order number should be returned');
    Assert.areEqual('Confirmed', details.status, 'The order status should be returned');
  }

  @isTest
  static void shouldThrowException_WhenOrderNameNotFound() {
    // Given
    GetOrderFromNameAction.Input request = new GetOrderFromNameAction.Input();
    request.orderName = 'NON-EXISTENT-ORDER';

    // When
    Test.startTest();
    Exception caughtException;
    try {
      GetOrderFromNameAction.getOrderFromName(new List<GetOrderFromNameAction.Input>{ request });
      Assert.fail('Expected an OrderException to be thrown');
    } catch (Exception e) {
      caughtException = e;
    }
    Test.stopTest();

    // Then
    Assert.isInstanceOfType(
      caughtException,
      OrderService.OrderException.class,
      'An OrderException should be thrown when the order is not found'
    );
  }
}
