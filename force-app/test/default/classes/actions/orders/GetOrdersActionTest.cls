/**
 * Tests for GetOrdersAction.
 */
@isTest
private class GetOrdersActionTest {
  @TestSetup
  static void setupTestData() {
    Storefront__c storefront = TestDataFactory.createStorefronts(1, true)[0];
    Contact customer = TestDataFactory.createCustomers(1, true)[0];
    TestDataFactory.createOrders(customer.Id, storefront.Id, 'Draft', 2, true);
    TestDataFactory.createOrders(customer.Id, storefront.Id, 'Confirmed', 1, true);
  }

  @isTest
  static void shouldReturnAllOrders_WhenNoStatusFilter() {
    // Given
    Contact customer = [SELECT Id FROM Contact LIMIT 1];
    GetOrdersAction.Input request = new GetOrdersAction.Input();
    request.customerId = customer.Id;

    // When
    Test.startTest();
    List<GetOrdersAction.Output> responses = GetOrdersAction.getOrders(new List<GetOrdersAction.Input>{ request });
    Test.stopTest();

    // Then
    Assert.areEqual(1, responses.size(), 'One response should be returned');
    Assert.isTrue(responses[0].isSuccess, 'Response should be successful');
    Assert.areEqual(3, responses[0].orders.size(), 'All orders for the customer should be returned');
  }

  @isTest
  static void shouldReturnFilteredOrders_WhenStatusFilterProvided() {
    // Given
    Contact customer = [SELECT Id FROM Contact LIMIT 1];
    GetOrdersAction.Input request = new GetOrdersAction.Input();
    request.customerId = customer.Id;
    request.orderStatus = 'Draft';

    // When
    Test.startTest();
    List<GetOrdersAction.Output> responses = GetOrdersAction.getOrders(new List<GetOrdersAction.Input>{ request });
    Test.stopTest();

    // Then
    Assert.isTrue(responses[0].isSuccess, 'Response should be successful');
    Assert.areEqual(2, responses[0].orders.size(), 'Only Draft orders should be returned');
  }

  @isTest
  static void shouldReturnError_WhenStatusIsInvalid() {
    // Given
    Contact customer = [SELECT Id FROM Contact LIMIT 1];
    GetOrdersAction.Input request = new GetOrdersAction.Input();
    request.customerId = customer.Id;
    request.orderStatus = 'NotAStatus';

    // When
    Test.startTest();
    List<GetOrdersAction.Output> responses = GetOrdersAction.getOrders(new List<GetOrdersAction.Input>{ request });
    Test.stopTest();

    // Then
    Assert.isFalse(responses[0].isSuccess, 'Response should not be successful');
    Assert.isTrue(
      responses[0].message.contains('Invalid status value'),
      'Message should indicate the status value is invalid'
    );
  }
}
