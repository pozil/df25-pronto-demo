import { LightningElement, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import USER_NAME from "@salesforce/schema/User.Username";
import ApiCalloutTool from "c/apiCalloutTool";

const navigationItems = [{ label: "Home", value: "home" }];

export default class ProntoHome extends NavigationMixin(LightningElement) {
  userId = USER_ID;
  navigationItems = navigationItems;
  selectedItem = "home";

  @track username = "";

  @wire(getRecord, { recordId: "$userId", fields: [USER_NAME] })
  wiredUser({ error, data }) {
    if (data) {
      this.username = data.fields.Username.value;
    } else if (error) {
      console.error("Error loading user record:", error);
    }
  }

  view(event) {
    const viewType = event.currentTarget.dataset.type;
    let url;
    if (viewType === "url") {
      url = event.currentTarget.dataset.url;
    }
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url
      }
    });
  }

  handleCopy(event) {
    const text = event.currentTarget.dataset.content;
    navigator.clipboard
      .writeText(text)
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Text copied to clipboard",
            variant: "success"
          })
        );
      })
      .catch((error) => {
        console.error("Failed to copy text: ", error);
      });
  }

  handleViewGuide() {
    // Navigate to workshop documentation
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "https://developer.salesforce.com/docs/atlas.en-us.data_cloud.meta/data_cloud/"
      }
    });
  }

  async launchCalloutModal() {
    await ApiCalloutTool.open({
      size: "large"
    });
  }

  get showHome() {
    return this.selectedItem === "home";
  }

  get prontoAppUrl() {
    // Construct Pronto app URL with username and password as URL parameters
    const baseUrl = "https://pronto-app-demo-pronto-daa85e7f30cb.herokuapp.com/";
    return `${baseUrl}`;
  }
}
