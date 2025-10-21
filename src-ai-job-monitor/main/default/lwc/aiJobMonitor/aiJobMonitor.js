import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class AiJobMonitor extends NavigationMixin(LightningElement) {
  selectedJobRun;

  get title() {
    if (this.selectedJobRun) {
      let title = "Run items for job ";
      if (this.selectedJobRun.Label) {
        title += `${this.selectedJobRun.Label} (${this.selectedJobRun.Name})`;
      } else {
        title += `${this.selectedJobRun.Name}`;
      }
      return title;
    }
    return "AI Job Runs";
  }

  handleRefreshClick() {
    this.template.querySelector("c-ai-job-item-list-view").refresh();
  }

  handleJobRunSelected(event) {
    if (event?.detail?.jobRun) {
      // Event from child component (aiJobRunView)
      this.selectedJobRun = event.detail.jobRun;
    } else {
      // Event from back button - clear selection
      this.selectedJobRun = null;
    }
  }

  handleTargetSelected(event) {
    if (event?.detail?.target) {
      // Navigate to prompt builder, we're not using the prompt name (target) because Apex can't access it.
      this[NavigationMixin.Navigate]({
        type: "standard__webPage",
        attributes: {
          url: "/lightning/setup/EinsteinPromptStudio/home"
        }
      });
    }
  }
}
