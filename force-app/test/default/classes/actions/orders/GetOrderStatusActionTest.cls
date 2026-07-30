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
  static void shouldReturnStatus_WhenLookupById() {
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
  static void shouldReturnStatus_WhenLookupByName() {
    // Given
    Order__c order = [SELECT Id, Name FROM Order__c LIMIT 1];
    GetOrderStatusAction.Input request = new GetOrderStatusAction.Input();
    request.orderId = order.Name;

    // When
    Test.startTest();
    List<GetOrderStatusAction.Output> responses = GetOrderStatusAction.getOrderStatus(
      new List<GetOrderStatusAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    GetOrderStatusAction.OrderStatus status = (GetOrderStatusAction.OrderStatus) JSON.deserialize(
      responses[0].orderStatus,
      GetOrderStatusAction.OrderStatus.class
    );
    Assert.areEqual(order.Id, status.id, 'The returned status should be for the requested order');
    Assert.areEqual(order.Name, status.name, 'The order name should be returned');
  }
}
