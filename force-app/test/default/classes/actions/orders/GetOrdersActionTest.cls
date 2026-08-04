@isTest
private class GetOrdersActionTest {
  private class MockOrderService extends OrderService {
    public Boolean shouldThrowException = false;
    public String exceptionMessage = 'Mock exception';
    public List<Order__c> ordersToReturn = new List<Order__c>();

    public override List<Order__c> getOrdersFromCustomer(Id customerId, String orderStatus) {
      if (shouldThrowException) {
        throw new OrderService.OrderException(exceptionMessage);
      }
      return ordersToReturn;
    }
  }

  @isTest
  static void testGetOrders_Success() {
    MockOrderService mockService = new MockOrderService();
    GetOrdersAction.orderService = mockService;

    Order__c order1 = new Order__c(Id = TestDataFactory.getFakeId(Order__c.SObjectType), Status__c = 'Delivered');
    Order__c order2 = new Order__c(Id = TestDataFactory.getFakeId(Order__c.SObjectType), Status__c = 'Delivered');
    mockService.ordersToReturn = new List<Order__c>{ order1, order2 };

    GetOrdersAction.Input input = new GetOrdersAction.Input();
    input.customerId = TestDataFactory.getFakeId(Contact.SObjectType);
    input.orderStatus = 'Delivered';

    Test.startTest();
    List<GetOrdersAction.Output> results = GetOrdersAction.getOrders(new List<GetOrdersAction.Input>{ input });
    Test.stopTest();

    System.assertEquals(1, results.size());
    GetOrdersAction.Output output = results[0];
    System.assertEquals(true, output.isSuccess);
    System.assertEquals(2, output.orders.size());
  }

  @isTest
  static void testGetOrders_Failure() {
    MockOrderService mockService = new MockOrderService();
    GetOrdersAction.orderService = mockService;
    mockService.shouldThrowException = true;
    mockService.exceptionMessage = 'Invalid status value';

    GetOrdersAction.Input input = new GetOrdersAction.Input();
    input.customerId = TestDataFactory.getFakeId(Contact.SObjectType);
    input.orderStatus = 'InvalidStatus';

    Test.startTest();
    List<GetOrdersAction.Output> results = GetOrdersAction.getOrders(new List<GetOrdersAction.Input>{ input });
    Test.stopTest();

    System.assertEquals(1, results.size());
    GetOrdersAction.Output output = results[0];
    System.assertEquals(false, output.isSuccess);
    System.assert(output.message.contains('Invalid status value'));
  }
}
