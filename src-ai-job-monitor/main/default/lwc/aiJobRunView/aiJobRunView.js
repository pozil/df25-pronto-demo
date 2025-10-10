import { LightningElement, wire } from "lwc";

import getAiJobRuns from "@salesforce/apex/AiJobMonitorController.getAiJobRuns";
import getJobTypes from "@salesforce/apex/AiJobMonitorController.getJobTypes";
import getTargets from "@salesforce/apex/AiJobMonitorController.getTargets";

const COLUMNS = [
  {
    label: "Name",
    type: "button",
    typeAttributes: {
      label: { fieldName: "Name" },
      name: "view_items",
      variant: "base",
      title: "View Job Run Items"
    }
  },
  { label: "Label", fieldName: "Label" },
  { label: "Job Type", fieldName: "JobType" },
  { label: "Status", fieldName: "Status" },
  { label: "Target", fieldName: "Target" },
  { label: "Created Date", fieldName: "CreatedDate" },
  { label: "Created By", fieldName: "CreatedBy" },
  { label: "Start Time", fieldName: "StartTime" },
  { label: "End Time", fieldName: "EndTime" },
  { label: "Duration", fieldName: "Duration" },
  { label: "Error Code", fieldName: "ErrorCode" },
  {
    label: "Error Message",
    fieldName: "ErrorMessage",
    type: "text",
    wrapText: true
  }
];

export default class AiJobRunView extends LightningElement {
  aiJobRuns = [];
  paginationInfo = {};
  error;
  isLoading = true;
  currentPage = 1;
  pageSize = 25;
  jobTypeFilter = "";
  targetFilter = "";
  jobTypeOptions = [];
  targetOptions = [];

  get columns() {
    return COLUMNS;
  }

  get currentPageInfo() {
    if (!this.paginationInfo.totalRecords) return "";
    const start = (this.currentPage - 1) * this.pageSize + 1;
    const end = Math.min(this.currentPage * this.pageSize, this.paginationInfo.totalRecords);
    return `Showing ${start}-${end} of ${this.paginationInfo.totalRecords}`;
  }

  @wire(getAiJobRuns, {
    pageSize: "$pageSize",
    pageNumber: "$currentPage",
    jobTypeFilter: "$jobTypeFilter",
    targetFilter: "$targetFilter"
  })
  wiredAiJobRuns({ error, data }) {
    this.isLoading = false;
    if (data) {
      // Format the date fields and calculate duration for each record
      this.aiJobRuns = data.records.map((record) => ({
        ...record,
        CreatedDate: this.formatDate(record.CreatedDate),
        CreatedBy: record.CreatedBy.Name,
        StartTime: this.formatDate(record.StartTime),
        EndTime: this.formatDate(record.EndTime),
        Duration: this.calculateDuration(record.StartTime, record.EndTime)
      }));
      this.paginationInfo = {
        totalRecords: data.totalRecords,
        totalPages: data.totalPages,
        currentPage: data.currentPage,
        pageSize: data.pageSize,
        hasNextPage: data.hasNextPage,
        hasPreviousPage: data.hasPreviousPage
      };
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.aiJobRuns = [];
      this.paginationInfo = {};
      console.error("Error fetching AI Job Runs:", error);
    }
  }

  @wire(getJobTypes)
  wiredJobTypes({ error, data }) {
    if (data) {
      this.jobTypeOptions = data.map((jobType) => ({
        label: jobType,
        value: jobType
      }));
    } else if (error) {
      console.error("Error fetching job types:", error);
    }
  }

  @wire(getTargets)
  wiredTargets({ error, data }) {
    if (data) {
      this.targetOptions = data.map((target) => ({
        label: target,
        value: target
      }));
    } else if (error) {
      console.error("Error fetching targets:", error);
    }
  }

  get hasActiveFilters() {
    return this.jobTypeFilter !== "" || this.targetFilter !== "";
  }

  get hasNoActiveFilters() {
    return this.jobTypeFilter === "" && this.targetFilter === "";
  }

  handleJobTypeFilterChange(event) {
    this.jobTypeFilter = event.target.value;
    this.currentPage = 1; // Reset to first page when filtering
  }

  handleTargetFilterChange(event) {
    this.targetFilter = event.target.value;
    this.currentPage = 1; // Reset to first page when filtering
  }

  handleClearFilters() {
    this.jobTypeFilter = "";
    this.targetFilter = "";
    this.currentPage = 1; // Reset to first page when clearing filters
  }

  formatDate(dateValue) {
    if (!dateValue) return "";
    const dateTime = dateValue.split("T");
    const date = dateTime[0]; // yyyy-mm-dd
    const time = dateTime[1].split(".")[0]; // hh:mm:ss
    return `${date} ${time}`;
  }

  calculateDuration(startTime, endTime) {
    if (!startTime || !endTime) return "N/A";

    const start = new Date(startTime);
    const end = new Date(endTime);
    const durationMs = end.getTime() - start.getTime();

    if (durationMs < 0) return "Invalid";

    const seconds = Math.floor(durationMs / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);

    if (hours > 0) {
      return `${hours}h ${minutes % 60}m ${seconds % 60}s`;
    } else if (minutes > 0) {
      return `${minutes}m ${seconds % 60}s`;
    }
    return `${seconds}s`;
  }

  get hasData() {
    return this.aiJobRuns && this.aiJobRuns.length > 0;
  }

  get hasError() {
    return this.error;
  }

  get isFirstPage() {
    return this.currentPage === 1;
  }

  get isLastPage() {
    return this.currentPage === this.paginationInfo.totalPages;
  }

  // Pagination methods
  handleFirstPage() {
    this.currentPage = 1;
  }

  handlePreviousPage() {
    if (this.paginationInfo.hasPreviousPage) {
      this.currentPage = this.currentPage - 1;
    }
  }

  handleNextPage() {
    if (this.paginationInfo.hasNextPage) {
      this.currentPage = this.currentPage + 1;
    }
  }

  handleLastPage() {
    this.currentPage = this.paginationInfo.totalPages;
  }

  handlePageSizeChange(event) {
    this.pageSize = parseInt(event.target.value, 10);
    this.currentPage = 1; // Reset to first page when changing page size
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    if (actionName === "view_items") {
      // Dispatch custom event to parent component with entire jobRun object
      const jobRunSelectedEvent = new CustomEvent("jobrunselected", {
        detail: { jobRun: row },
        bubbles: true
      });
      this.dispatchEvent(jobRunSelectedEvent);
    }
  }
}
