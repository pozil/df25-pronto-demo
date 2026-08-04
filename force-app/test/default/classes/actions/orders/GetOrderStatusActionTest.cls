/**
 * Tests for GetOrderStatusAction.
 */
@isTest
private class GetOrderStatusActionTest {
  @TestSetup
  static void setupTestData() {
    Storefront__c storefront = TestDataFactory.createStorefronts(1, true)[0];
    Contact customer = TestDataFactory.createCustomers(1, true)[0];
    TestDataFactory.createOrders(customer.Id, storefront.Id, 'Confirmed', 1, true);
  }

  @isTest
  static void shouldReturnStatus() {
    // Given
    Order__c order = [SELECT Id FROM Order__c LIMIT 1];
    GetOrderStatusAction.Input request = new GetOrderStatusAction.Input();
    request.orderId = order.Id;

    // When
    Test.startTest();
    List<GetOrderStatusAction.Output> responses = GetOrderStatusAction.getOrderStatus(
      new List<GetOrderStatusAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.areEqual(1, responses.size(), 'One response should be returned');
    GetOrderStatusAction.OrderStatus status = (GetOrderStatusAction.OrderStatus) JSON.deserialize(
      responses[0].orderStatus,
      GetOrderStatusAction.OrderStatus.class
    );
    Assert.areEqual(order.Id, status.id, 'The returned status should be for the requested order');
    Assert.areEqual('Confirmed', status.status, 'The order status should be returned');
  }

  @isTest
  static void shouldThrowException_WhenOrderIdNotFound() {
    // Given
    GetOrderStatusAction.Input request = new GetOrderStatusAction.Input();
    request.orderId = 'a00000000000000AAA';

    // When
    Test.startTest();
    Exception caughtException;
    try {
      GetOrderStatusAction.getOrderStatus(new List<GetOrderStatusAction.Input>{ request });
    } catch (Exception e) {
      caughtException = e;
    }
    Test.stopTest();

    // Then
    Assert.isNotNull(caughtException, 'An exception should be thrown when the order is not found');
    Assert.isInstanceOfType(
      caughtException,
      OrderService.OrderException.class,
      'An OrderException should be thrown when the order is not found'
    );
  }
}
