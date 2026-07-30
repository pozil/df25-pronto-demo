/**
 * Tests for GetOrderDeliveryTrackingAction.
 */
@isTest
private class GetOrderDeliveryTrackingActionTest {
  @isTest
  static void shouldReturnTracking_WhenOrderIdProvided() {
    // Given
    String orderId = 'a00000000000000AAA';
    GetOrderDeliveryTrackingAction.Input request = new GetOrderDeliveryTrackingAction.Input();
    request.orderId = orderId;

    // When
    Test.startTest();
    List<GetOrderDeliveryTrackingAction.Output> responses = GetOrderDeliveryTrackingAction.getDeliveryTracking(
      new List<GetOrderDeliveryTrackingAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.areEqual(1, responses.size(), 'One response should be returned');
    GetOrderDeliveryTrackingAction.DeliveryTracking tracking = responses[0].deliveryTracking;
    Assert.areEqual(orderId, tracking.orderId, 'The tracking should be for the requested order');
    Assert.areEqual('In Progress', tracking.status, 'The tracking status should be returned');
    Assert.areEqual(3, tracking.mapMarkers.size(), 'The tracking should include all map markers');
  }
}
