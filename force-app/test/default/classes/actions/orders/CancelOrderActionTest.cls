@isTest
private class CancelOrderActionTest {
  private class MockOrderService extends OrderService {
    public Boolean shouldThrowException = false;
    public String exceptionMessage;
    public Order__c orderToReturn;

    public override Order__c cancelOrder(Id orderId, String cancelationReason) {
      if (shouldThrowException) {
        throw new OrderService.OrderException(exceptionMessage);
      }
      return orderToReturn;
    }
  }

  @isTest
  static void testCancelOrder_Success() {
    MockOrderService mockService = new MockOrderService();
    Order__c mockOrder = new Order__c(
      Id = TestDataFactory.getFakeId(Order__c.SObjectType),
      Status__c = 'Canceled',
      Cancelation_Reason__c = 'Customer requested'
    );
    mockService.orderToReturn = mockOrder;
    CancelOrderAction.orderService = mockService;

    CancelOrderAction.Input input = new CancelOrderAction.Input();
    input.orderId = mockOrder.Id;
    input.cancelationReason = 'Customer requested';

    Test.startTest();
    List<CancelOrderAction.Output> results = CancelOrderAction.cancelOrder(new List<CancelOrderAction.Input>{ input });
    Test.stopTest();

    System.assertEquals(1, results.size(), 'Expected one output result');
    CancelOrderAction.Output output = results[0];
    System.assertEquals(true, output.isSuccess, 'Expected success to be true');
    System.assert(output.message.contains('was canceled'), 'Expected success message');
  }

  @isTest
  static void testCancelOrder_Failure() {
    MockOrderService mockService = new MockOrderService();
    mockService.shouldThrowException = true;
    mockService.exceptionMessage = 'Order cannot be canceled';
    CancelOrderAction.orderService = mockService;

    CancelOrderAction.Input input = new CancelOrderAction.Input();
    input.orderId = TestDataFactory.getFakeId(Order__c.SObjectType);
    input.cancelationReason = 'Test reason';

    Test.startTest();
    List<CancelOrderAction.Output> results = CancelOrderAction.cancelOrder(new List<CancelOrderAction.Input>{ input });
    Test.stopTest();

    System.assertEquals(1, results.size(), 'Expected one output result');
    CancelOrderAction.Output output = results[0];
    System.assertEquals(false, output.isSuccess, 'Expected success to be false');
    System.assertEquals('Order cannot be canceled', output.message, 'Expected error message');
  }
}
