import { LightningElement, api } from "lwc";

export default class StoreTile extends LightningElement {
  @api store;

  handleStoreSelected() {
    // In other devices, send message to other cmps on the page
    const selectedEvent = new CustomEvent("selected", {
      detail: this.store.Id
    });
    this.dispatchEvent(selectedEvent);
  }

  get backgroundImageStyle() {
    return `background-image:url(${this.store.Thumbnail__c})`;
  }
}
