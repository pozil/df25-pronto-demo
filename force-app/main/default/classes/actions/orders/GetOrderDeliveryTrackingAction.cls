public with sharing class GetOrderDeliveryTrackingAction {
  @InvocableMethod(
    label='Get Delivery Tracking'
    description='Get the delivery tracking information for an order'
    category='Order Management'
  )
  public static List<Output> getDeliveryTracking(List<Input> requests) {
    List<Output> responses = new List<Output>();
    for (Input request : requests) {
      Output response = new Output();
      response.deliveryTracking = getDeliveryTracking(request.orderId);
      responses.add(response);
    }
    return responses;
  }

  private static DeliveryTracking getDeliveryTracking(String orderId) {
    List<MapMarker> mapMarkers = new List<MapMarker>{
      new MapMarker(37.7897441, -122.4021046, 'Storefront Location'),
      new MapMarker(37.7875941, -122.400459, 'Driver Location'),
      new MapMarker(37.7835, -122.403, 'Delivery Location')
    };

    DeliveryTracking deliveryTracking = new DeliveryTracking();
    deliveryTracking.orderId = orderId;
    deliveryTracking.status = 'In Progress';
    deliveryTracking.mapMarkers = mapMarkers;
    return deliveryTracking;
  }

  public class Input {
    @InvocableVariable(required=true label='Order ID' description='The ID of the order to track')
    public String orderId;
  }

  public class Output {
    @InvocableVariable(label='Delivery Tracking' description='The delivery tracking information')
    public DeliveryTracking deliveryTracking;
  }

  public class DeliveryTracking {
    public String orderId;
    public String status;
    public List<MapMarker> mapMarkers;
  }

  public class MapMarker {
    public Decimal latitude;
    public Decimal longitude;
    public String title;

    public MapMarker(Decimal latitude, Decimal longitude, String title) {
      this.latitude = latitude;
      this.longitude = longitude;
      this.title = title;
    }
  }
}
