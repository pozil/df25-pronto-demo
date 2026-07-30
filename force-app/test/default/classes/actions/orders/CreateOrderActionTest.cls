/**
 * Tests for CreateOrderAction.
 */
@isTest
private class CreateOrderActionTest {
  @TestSetup
  static void setupTestData() {
    Storefront__c storefront = TestDataFactory.createStorefronts(1, true)[0];
    TestDataFactory.createCustomers(1, true);
  }

  @isTest
  static void shouldCreateDraftOrder_WhenValidInput() {
    // Given
    Contact customer = [SELECT Id FROM Contact LIMIT 1];
    Storefront__c storefront = [SELECT Id FROM Storefront__c LIMIT 1];
    CreateOrderAction.Input request = new CreateOrderAction.Input();
    request.customerId = customer.Id;
    request.storefrontId = storefront.Id;

    // When
    Test.startTest();
    List<CreateOrderAction.Output> responses = CreateOrderAction.createOrder(
      new List<CreateOrderAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.areEqual(1, responses.size(), 'One response should be returned');
    Assert.isTrue(responses[0].isSuccess, 'Response should be successful');
    Assert.isNotNull(responses[0].orderId, 'An order ID should be returned');
    Order__c order = [SELECT Id, Status__c FROM Order__c WHERE Id = :responses[0].orderId LIMIT 1];
    Assert.areEqual('Draft', order.Status__c, 'The created order should be in Draft status');
  }

  @isTest
  static void shouldReturnError_WhenCustomerDoesNotExist() {
    // Given
    Storefront__c storefront = [SELECT Id FROM Storefront__c LIMIT 1];
    CreateOrderAction.Input request = new CreateOrderAction.Input();
    request.customerId = '003000000000000AAA';
    request.storefrontId = storefront.Id;

    // When
    Test.startTest();
    List<CreateOrderAction.Output> responses = CreateOrderAction.createOrder(
      new List<CreateOrderAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.isFalse(responses[0].isSuccess, 'Response should not be successful');
    Assert.isNull(responses[0].orderId, 'No order ID should be returned');
    Assert.isTrue(
      responses[0].message.contains('Error creating draft order'),
      'Message should indicate an error occurred'
    );
  }
}
