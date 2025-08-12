import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import {
  subscribe,
  unsubscribe,
  MessageContext
} from "lightning/messageService";
import STORE_SELECTED_MC from "@salesforce/messageChannel/StoreSelected__c";
import getStoreOpeningHours from "@salesforce/apex/StoreController.getStoreOpeningHours";

// Storefront fields
import NAME_FIELD from "@salesforce/schema/Storefront__c.Name";
import TYPE_FIELD from "@salesforce/schema/Storefront__c.Type__c";
import CUISINE_FIELD from "@salesforce/schema/Storefront__c.Cuisine__c";
import DESCRIPTION_FIELD from "@salesforce/schema/Storefront__c.Description__c";
import SCORE_FIELD from "@salesforce/schema/Storefront__c.Average_Review_Score__c";
import TOTAL_REVIEWS_FIELD from "@salesforce/schema/Storefront__c.Total_Reviews__c";
import PICTURE_FIELD from "@salesforce/schema/Storefront__c.Thumbnail__c";

export default class StoreSummary extends NavigationMixin(LightningElement) {
  storeId;
  storeFormFields = [TYPE_FIELD, CUISINE_FIELD, DESCRIPTION_FIELD];
  subscription = null;

  @wire(MessageContext)
  messageContext;

  @wire(getRecord, {
    recordId: "$storeId",
    fields: [NAME_FIELD, PICTURE_FIELD, SCORE_FIELD, TOTAL_REVIEWS_FIELD]
  })
  store;

  @wire(getStoreOpeningHours, {
    storeId: "$storeId"
  })
  openingHours;

  @api
  get recordId() {
    return this.storeId;
  }

  set recordId(storeId) {
    this.storeId = storeId;
  }

  connectedCallback() {
    this.subscription = subscribe(
      this.messageContext,
      STORE_SELECTED_MC,
      (message) => {
        this.handleStoreSelected(message);
      }
    );
  }

  disconnectedCallback() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  handleStoreSelected(message) {
    this.storeId = message.storeId;
  }

  handleNavigateToRecord() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.storeId,
        objectApiName: "Storefront__c",
        actionName: "view"
      }
    });
  }

  get hasOpeningHours() {
    return this.openingHours.data && this.openingHours.data.length > 0;
  }

  get hasNoStoreId() {
    return this.storeId === undefined;
  }

  get storeName() {
    return getFieldValue(this.store.data, NAME_FIELD);
  }

  get pictureURL() {
    return getFieldValue(this.store.data, PICTURE_FIELD);
  }

  get reviewScore() {
    return getFieldValue(this.store.data, SCORE_FIELD);
  }

  get numberOfReviews() {
    return getFieldValue(this.store.data, TOTAL_REVIEWS_FIELD);
  }
}
