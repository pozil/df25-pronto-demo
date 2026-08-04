@isTest
private class GetOrderFromNameActionTest {
  private class MockOrderService extends OrderService {
    public Boolean shouldThrowException = false;
    public String exceptionMessage = '';
    public Order__c orderToReturn;

    public override Order__c getOrderFromName(String orderName) {
      if (shouldThrowException) {
        throw new OrderException(exceptionMessage);
      }
      return orderToReturn;
    }
  }

  @isTest
  static void testGetOrderFromName_Success() {
    Order__c testOrder = new Order__c(Status__c = 'Confirmed', Total_Amount__c = 45.50);
    testOrder.Id = TestDataFactory.getFakeId(Order__c.SObjectType);

    MockOrderService mockService = new MockOrderService();
    mockService.orderToReturn = testOrder;
    GetOrderFromNameAction.orderService = mockService;

    GetOrderFromNameAction.Input input = new GetOrderFromNameAction.Input();
    input.orderName = 'ORD-12345';
    List<GetOrderFromNameAction.Input> inputs = new List<GetOrderFromNameAction.Input>{ input };

    Test.startTest();
    List<GetOrderFromNameAction.Output> outputs = GetOrderFromNameAction.getOrderFromName(inputs);
    Test.stopTest();

    System.assertEquals(1, outputs.size());
    System.assertNotEquals(null, outputs[0].order);
  }

  @isTest
  static void testGetOrderFromName_Failure() {
    MockOrderService mockService = new MockOrderService();
    mockService.shouldThrowException = true;
    mockService.exceptionMessage = 'No order found with number: ORD-INVALID';
    GetOrderFromNameAction.orderService = mockService;

    GetOrderFromNameAction.Input input = new GetOrderFromNameAction.Input();
    input.orderName = 'ORD-INVALID';
    List<GetOrderFromNameAction.Input> inputs = new List<GetOrderFromNameAction.Input>{ input };

    Test.startTest();
    try {
      GetOrderFromNameAction.getOrderFromName(inputs);
      System.assert(false, 'Expected OrderException to be thrown');
    } catch (OrderService.OrderException e) {
      System.assertEquals('No order found with number: ORD-INVALID', e.getMessage());
    }
    Test.stopTest();
  }
}
