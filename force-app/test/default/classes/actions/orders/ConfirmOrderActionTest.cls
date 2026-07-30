/**
 * Tests for ConfirmOrderAction.
 */
@isTest
private class ConfirmOrderActionTest {
  @TestSetup
  static void setupTestData() {
    Storefront__c storefront = TestDataFactory.createStorefronts(1, true)[0];
    Contact customer = TestDataFactory.createCustomers(1, true)[0];
    TestDataFactory.createOrders(customer.Id, storefront.Id, 'Draft', 1, true);
  }

  @isTest
  static void shouldConfirmOrder_WhenOrderIsDraft() {
    // Given
    Order__c order = [SELECT Id FROM Order__c LIMIT 1];
    ConfirmOrderAction.Input request = new ConfirmOrderAction.Input();
    request.orderId = order.Id;

    // When
    Test.startTest();
    List<ConfirmOrderAction.Output> responses = ConfirmOrderAction.confirmOrder(
      new List<ConfirmOrderAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.areEqual(1, responses.size(), 'One response should be returned');
    Assert.isTrue(responses[0].success, 'Response should be successful');
    Order__c confirmed = [SELECT Status__c FROM Order__c WHERE Id = :order.Id LIMIT 1];
    Assert.areEqual('Confirmed', confirmed.Status__c, 'The order should be Confirmed');
  }

  @isTest
  static void shouldReturnError_WhenOrderIsNotDraft() {
    // Given
    Order__c order = [SELECT Id FROM Order__c LIMIT 1];
    order.Status__c = 'Confirmed';
    update order;
    ConfirmOrderAction.Input request = new ConfirmOrderAction.Input();
    request.orderId = order.Id;

    // When
    Test.startTest();
    List<ConfirmOrderAction.Output> responses = ConfirmOrderAction.confirmOrder(
      new List<ConfirmOrderAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.isFalse(responses[0].success, 'Response should not be successful');
    Assert.isTrue(
      responses[0].message.contains('Only Draft orders can be confirmed'),
      'Message should indicate only Draft orders can be confirmed'
    );
  }
}
