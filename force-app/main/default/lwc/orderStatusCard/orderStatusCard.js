import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

const STATUS_OUT_FOR_DELIVERY = "Out for Delivery";
const STATUS_UNKNOWN = "Unknown";

// Status configuration for styling
const STATUS_CONFIG = {
  Draft: { variant: "base", icon: "utility:edit", label: "Draft" },
  Confirmed: { variant: "success", icon: "utility:check", label: "Confirmed" },
  Processed: { variant: "success", icon: "utility:settings", label: "Processed" },
  STATUS_OUT_FOR_DELIVERY: { variant: "warning", icon: "utility:delivery_truck", label: "Out for Delivery" },
  Delivered: { variant: "success", icon: "utility:check_circle", label: "Delivered" },
  Canceled: { variant: "error", icon: "utility:close", label: "Canceled" },
  STATUS_UNKNOWN: { variant: "base", icon: "utility:help", label: "Unknown" }
};

export default class OrderStatusCard extends NavigationMixin(LightningElement) {
  @api value;

  getStatusInfo() {
    if (!this.value?.status) {
      return STATUS_CONFIG[STATUS_UNKNOWN];
    }
    if (Object.hasOwn(STATUS_CONFIG, this.value.status)) {
      return STATUS_CONFIG[this.value.status];
    }
    return STATUS_CONFIG[STATUS_UNKNOWN];
  }

  get mapMarkers() {
    if (this.value?.status === STATUS_OUT_FOR_DELIVERY) {
      return [
        { latitude: 37.7897441, longitude: -122.4021046, title: "Storefront Location" },
        { latitude: 37.7875941, longitude: -122.400459, title: "Driver Location" },
        { latitude: 37.7835, longitude: -122.403, title: "Delivery Location" }
      ];
    }
    return null;
  }

  get orderNumber() {
    return this.value?.orderNumber;
  }

  get statusIconName() {
    return this.getStatusInfo().icon;
  }

  get statusLabel() {
    return this.getStatusInfo().label;
  }

  get statusVariant() {
    return this.getStatusInfo().variant;
  }

  get storefrontName() {
    return this.value?.storefrontName;
  }

  get formattedTotalAmount() {
    if (!this.orderData || !this.orderData.totalAmount) {
      return "$0.00";
    }
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD"
    }).format(this.orderData.totalAmount);
  }

  get formattedOrderTime() {
    if (!this.orderData || !this.orderData.orderTime) {
      return "N/A";
    }
    return new Date(this.orderData.orderTime).toLocaleString();
  }

  get formattedDeliveryTime() {
    if (!this.orderData || !this.orderData.deliveryTime) {
      return "N/A";
    }
    return new Date(this.orderData.deliveryTime).toLocaleString();
  }

  get deliveryTime() {
    // Add fake delivery time in 10 minutes
    const now = new Date();
    const deliveryTime = new Date(now.getTime() + 10 * 60 * 1000); // 10 minutes from now

    const timeString = deliveryTime.toLocaleTimeString("en-US", {
      hour: "numeric",
      minute: "2-digit",
      hour12: true
    });

    return timeString;
  }

  handleNavigateToOrderRecord() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.orderId,
        objectApiName: "Order__c",
        actionName: "view"
      }
    });
  }
}
