/**
 * Tests for CancelOrderAction.
 */
@isTest
private class CancelOrderActionTest {
  @TestSetup
  static void setupTestData() {
    Storefront__c storefront = TestDataFactory.createStorefronts(1, true)[0];
    Contact customer = TestDataFactory.createCustomers(1, true)[0];
    TestDataFactory.createOrders(customer.Id, storefront.Id, 'Draft', 1, true);
  }

  @isTest
  static void shouldCancelOrder_WhenOrderIsDraft() {
    // Given
    Order__c order = [SELECT Id FROM Order__c LIMIT 1];
    CancelOrderAction.Input request = new CancelOrderAction.Input();
    request.orderId = order.Id;
    request.cancelationReason = 'Customer changed their mind';

    // When
    Test.startTest();
    List<CancelOrderAction.Output> responses = CancelOrderAction.cancelOrder(
      new List<CancelOrderAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.areEqual(1, responses.size(), 'One response should be returned');
    Assert.isTrue(responses[0].isSuccess, 'Response should be successful');
    Order__c canceled = [SELECT Status__c, Cancelation_Reason__c FROM Order__c WHERE Id = :order.Id LIMIT 1];
    Assert.areEqual('Canceled', canceled.Status__c, 'The order should be Canceled');
    Assert.areEqual(
      'Customer changed their mind',
      canceled.Cancelation_Reason__c,
      'The cancelation reason should be stored'
    );
  }

  @isTest
  static void shouldReturnError_WhenOrderCannotBeCanceled() {
    // Given
    Order__c order = [SELECT Id FROM Order__c LIMIT 1];
    order.Status__c = 'Delivered';
    update order;
    CancelOrderAction.Input request = new CancelOrderAction.Input();
    request.orderId = order.Id;

    // When
    Test.startTest();
    List<CancelOrderAction.Output> responses = CancelOrderAction.cancelOrder(
      new List<CancelOrderAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.isFalse(responses[0].isSuccess, 'Response should not be successful');
    Assert.isTrue(
      responses[0].message.contains('cannot be canceled'),
      'Message should indicate the order cannot be canceled'
    );
  }
}
