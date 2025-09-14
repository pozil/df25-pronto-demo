import { LightningElement, wire, api } from "lwc";
import { getRelatedListRecords } from "lightning/uiRelatedListApi";

export default class Reviews extends LightningElement {
  reviews = [];

  @api storeId;

  @wire(getRelatedListRecords, {
    parentRecordId: "$storeId",
    relatedListId: "Reviews__r",
    fields: ["Review__c.Comments__c", "Review__c.Rating__c", "Review__c.Order_Date__c"],
    sortBy: ["Review__c.Order_Date__c"]
  })
  getReviews({ error, data }) {
    if (data) {
      this.reviews = data.records.map((review) => ({
        id: review.id,
        rating: review.fields.Rating__c.value,
        comments: review.fields.Comments__c.value
      }));
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.reviews = undefined;
    }
  }
}
