import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import PRONTO_IMAGES from "@salesforce/resourceUrl/pronto_org_images";

// Import all necessary fields from Account, Contact, and Lead objects
import ACCOUNT_OBJECT from "@salesforce/schema/Account";
//import CONTACT_OBJECT from "@salesforce/schema/Contact";
//import LEAD_OBJECT from "@salesforce/schema/Lead";

// Contact Fields
import CONTACT_NAME_FIELD from "@salesforce/schema/Contact.Name";
import CONTACT_EMAIL_FIELD from "@salesforce/schema/Contact.Email";
import CONTACT_PHONE_FIELD from "@salesforce/schema/Contact.Phone";
import CONTACT_MOBILE_FIELD from "@salesforce/schema/Contact.MobilePhone";
import CONTACT_ACCOUNT_NAME_FIELD from "@salesforce/schema/Contact.Account.Name";
import CONTACT_TITLE from "@salesforce/schema/Contact.Title";
import CONTACT_LEAD_SOURCE from "@salesforce/schema/Contact.LeadSource";
import CONTACT_MAILING_CITY_FIELD from "@salesforce/schema/Contact.MailingCity";
import CONTACT_MAILING_STATE_FIELD from "@salesforce/schema/Contact.MailingState";

const CONTACT_FIELDS = [
  CONTACT_NAME_FIELD,
  CONTACT_EMAIL_FIELD,
  CONTACT_PHONE_FIELD,
  CONTACT_MOBILE_FIELD,
  CONTACT_ACCOUNT_NAME_FIELD,
  CONTACT_TITLE,
  CONTACT_LEAD_SOURCE,
  CONTACT_MAILING_CITY_FIELD,
  CONTACT_MAILING_STATE_FIELD
];

export default class ProntoProfileCard extends LightningElement {
  @api recordId;
  @api objectApiName;

  // Loading and error states
  isLoading = true;
  hasError = false;

  // Data containers
  _acct;
  _ct;
  _ld;
  _acctRt;

  // Wire object info to get record type details
  @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
  wiredObjectInfo({ error, data }) {
    console.log("🛠 wiredObjectInfo:", { error, data });
    this.objectInfo = data;
    this.objectInfoError = error;
  }

  @wire(getRecord, { recordId: "$contactRecordId", fields: CONTACT_FIELDS })
  wiredContact({ error, data }) {
    console.log("🛠 wiredContact:", { error, data });
    if (data) this._ct = data;
    if (error) console.error("❌ Contact fetch error:", error);
  }

  // STATE HELPERS
  get isAccount() {
    const val = this.objectApiName === "Account";
    console.log("🛠 isAccount:", val);
    return val;
  }
  get isContact() {
    const val = this.objectApiName === "Contact";
    console.log("🛠 isContact:", val);
    return val;
  }
  get isLead() {
    const val = this.objectApiName === "Lead";
    console.log("🛠 isLead:", val);
    return val;
  }

  get contactRecordId() {
    const id = this.isContact ? this.recordId : null;
    console.log("🛠 contactRecordId getter:", id);
    return id;
  }
  get leadRecordId() {
    const id = this.isLead ? this.recordId : null;
    console.log("🛠 leadRecordId getter:", id);
    return id;
  }

  get hasData() {
    const ok = (this.isAccount && this._acct) || (this.isContact && this._ct) || (this.isLead && this._ld);
    console.log("🛠 hasData:", ok);
    return ok;
  }

  // THEME AND HERO
  get themeClass() {
    if (this.isPartnerAccount || this.isBusinessContact) return "profile-card partner-account-theme";
    if (this.isCustomerAccount || this.isCustomerContact) return "profile-card customer-account-theme";
    return "profile-card default-theme"; // Fallback theme
  }

  get heroImageUrl() {
    if (this.isPartnerAccount) {
      return PRONTO_IMAGES + "/pronto-org-images/pronto-business-account-hero.png";
    }
    if (this.isCustomerAccountType) {
      return PRONTO_IMAGES + "/pronto-org-images/pronto-customer-account-hero.png";
    }
    if (this.isContact) {
      return PRONTO_IMAGES + "/pronto-org-images/pronto-customer-hero.png";
    }
    if (this.isLead) {
      return PRONTO_IMAGES + "/pronto-org-images/pronto-lead-hero.png";
    }
    return "";
  }

  get contactType() {
    if (!this.isContact) return null;

    const accountName = getFieldValue(this._ct, CONTACT_ACCOUNT_NAME_FIELD);
    const leadSource = getFieldValue(this._ct, CONTACT_LEAD_SOURCE);

    // If no account or customer-related lead source, it's a customer contact
    if (!accountName || leadSource === "Customer Referral" || leadSource === "Web") {
      return "customer";
    }

    // If has account and non-customer lead source, it's a business contact
    if (accountName && leadSource && leadSource !== "Customer Referral" && leadSource !== "Web") {
      return "business";
    }

    // Default to customer if unclear
    return "customer";
  }

  get isCustomerContact() {
    return this.contactType === "customer";
  }

  get isBusinessContact() {
    return this.contactType === "business";
  }

  // HELPER METHODS
  formatFieldValue(value) {
    return value || "—";
  }

  // SHARED GETTERS
  get displayName() {
    if (this.isContact) return getFieldValue(this._ct, CONTACT_NAME_FIELD);
    return "N/A";
  }

  get headlineSubtitle() {
    let city, state;
    if (this.isContact && this._ct) {
      city = getFieldValue(this._ct, CONTACT_MAILING_CITY_FIELD);
      state = getFieldValue(this._ct, CONTACT_MAILING_STATE_FIELD);
    }

    const locationParts = [];
    if (city) locationParts.push(city);
    if (state) locationParts.push(state);

    return locationParts.join(", ");
  }

  get recordTypeLabel() {
    if (this.isAccount) {
      if (this.isPartnerAccount) return "Partner Account";
      if (this.isCustomerAccount) return "Customer Account";
      return "Account";
    }
    if (this.isContact) {
      if (this.isCustomerContact) return "Customer Contact";
      if (this.isBusinessContact) return "Business Contact";
      return "Contact";
    }
    if (this.isLead) return "Lead";
    return "Record";
  }

  // CONTACT GETTERS
  get contactName() {
    return this.formatFieldValue(getFieldValue(this._ct, CONTACT_NAME_FIELD));
  }
  get contactEmail() {
    return this.formatFieldValue(getFieldValue(this._ct, CONTACT_EMAIL_FIELD));
  }
  get contactPhone() {
    return this.formatFieldValue(getFieldValue(this._ct, CONTACT_PHONE_FIELD));
  }
  get contactMobile() {
    return this.formatFieldValue(getFieldValue(this._ct, CONTACT_MOBILE_FIELD));
  }
  get contactAccountName() {
    return this.formatFieldValue(getFieldValue(this._ct, CONTACT_ACCOUNT_NAME_FIELD));
  }
  get contactTitle() {
    return this.formatFieldValue(getFieldValue(this._ct, CONTACT_TITLE));
  }
  get contactLeadSource() {
    return this.formatFieldValue(getFieldValue(this._ct, CONTACT_LEAD_SOURCE));
  }
}
