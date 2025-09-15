import { LightningElement } from "lwc";

export default class AiJobMonitor extends LightningElement {
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
    this.template.querySelector("c-ai-job-run-item-view").refresh();
  }

  handleJobRunSelected(event) {
    if (event.detail && event.detail.jobRun) {
      // Event from child component (aiJobRunView)
      this.selectedJobRun = event.detail.jobRun;
    } else {
      // Event from back button - clear selection
      this.selectedJobRun = null;
    }
  }
}
