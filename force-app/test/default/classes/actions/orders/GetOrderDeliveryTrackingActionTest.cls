@isTest
private class GetOrderDeliveryTrackingActionTest {
  @isTest
  static void testGetDeliveryTracking_Success() {
    String testOrderId = TestDataFactory.getFakeId(Order.SObjectType);
    GetOrderDeliveryTrackingAction.Input input = new GetOrderDeliveryTrackingAction.Input();
    input.orderId = testOrderId;
    List<GetOrderDeliveryTrackingAction.Input> inputs = new List<GetOrderDeliveryTrackingAction.Input>{ input };

    Test.startTest();
    List<GetOrderDeliveryTrackingAction.Output> outputs = GetOrderDeliveryTrackingAction.getDeliveryTracking(inputs);
    Test.stopTest();

    System.assertEquals(1, outputs.size());
    GetOrderDeliveryTrackingAction.Output output = outputs[0];
    System.assertNotEquals(null, output.deliveryTracking);
    System.assertEquals(testOrderId, output.deliveryTracking.orderId);
    System.assertEquals('In Progress', output.deliveryTracking.status);
    System.assertEquals(3, output.deliveryTracking.mapMarkers.size());
  }

  @isTest
  static void testGetDeliveryTracking_Failure() {
    GetOrderDeliveryTrackingAction.Input input = new GetOrderDeliveryTrackingAction.Input();
    input.orderId = null;
    List<GetOrderDeliveryTrackingAction.Input> inputs = new List<GetOrderDeliveryTrackingAction.Input>{ input };

    Test.startTest();
    List<GetOrderDeliveryTrackingAction.Output> outputs = GetOrderDeliveryTrackingAction.getDeliveryTracking(inputs);
    Test.stopTest();

    System.assertEquals(1, outputs.size());
    GetOrderDeliveryTrackingAction.Output output = outputs[0];
    System.assertNotEquals(null, output.deliveryTracking);
    System.assertEquals(null, output.deliveryTracking.orderId);
  }
}
