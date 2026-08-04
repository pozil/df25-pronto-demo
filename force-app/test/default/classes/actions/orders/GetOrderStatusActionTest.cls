@isTest
private class GetOrderStatusActionTest {
  private class MockOrderService extends OrderService {
    public Order__c mockOrder;
    public List<Order_Item__c> mockOrderItems;
    public Boolean shouldThrowException = false;
    public String exceptionMessage;

    public override Order__c getOrderFromId(Id orderId) {
      if (shouldThrowException) {
        throw new OrderService.OrderException(exceptionMessage);
      }
      return mockOrder;
    }

    public override List<Order_Item__c> getOrderItems(Id orderId) {
      if (mockOrderItems != null) {
        return mockOrderItems;
      }
      return new List<Order_Item__c>();
    }
  }

  @isTest
  static void testGetOrderStatus_Success() {
    MockOrderService mockService = new MockOrderService();

    Order__c mockOrder = new Order__c(
      Id = TestDataFactory.getFakeId(Order__c.SObjectType),
      Status__c = 'Confirmed',
      Total_Amount__c = 45.99
    );

    List<Order_Item__c> mockItems = new List<Order_Item__c>{
      new Order_Item__c(Id = TestDataFactory.getFakeId(Order_Item__c.SObjectType), Quantity__c = 2)
    };

    mockService.mockOrder = mockOrder;
    mockService.mockOrderItems = mockItems;
    GetOrderStatusAction.orderService = mockService;

    GetOrderStatusAction.Input input = new GetOrderStatusAction.Input();
    input.orderId = mockOrder.Id;
    List<GetOrderStatusAction.Input> inputs = new List<GetOrderStatusAction.Input>{ input };

    Test.startTest();
    List<GetOrderStatusAction.Output> outputs = GetOrderStatusAction.getOrderStatus(inputs);
    Test.stopTest();

    System.assertEquals(1, outputs.size());
    System.assertNotEquals(null, outputs[0].orderStatus);
  }

  @isTest
  static void testGetOrderStatus_Failure() {
    MockOrderService mockService = new MockOrderService();
    mockService.shouldThrowException = true;
    mockService.exceptionMessage = 'No order found with ID: 001000000000000AAA';
    GetOrderStatusAction.orderService = mockService;

    GetOrderStatusAction.Input input = new GetOrderStatusAction.Input();
    input.orderId = TestDataFactory.getFakeId(Order__c.SObjectType);
    List<GetOrderStatusAction.Input> inputs = new List<GetOrderStatusAction.Input>{ input };

    Test.startTest();
    try {
      GetOrderStatusAction.getOrderStatus(inputs);
      System.assert(false, 'Expected OrderException to be thrown');
    } catch (OrderService.OrderException e) {
      System.assert(e.getMessage().contains('No order found with ID'));
    }
    Test.stopTest();
  }
}
