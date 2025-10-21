import { LightningElement, wire, track } from "lwc";

import getAiJobRuns from "@salesforce/apex/AiJobMonitorController.getAiJobRuns";
import getJobTypes from "@salesforce/apex/AiJobMonitorController.getJobTypes";
import getTargets from "@salesforce/apex/AiJobMonitorController.getTargets";
import getStatuses from "@salesforce/apex/AiJobMonitorController.getStatuses";

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
  {
    label: "Target",
    type: "button",
    typeAttributes: {
      label: { fieldName: "Target" },
      name: "view_target",
      variant: "base",
      title: "View Target"
    }
  },
  { label: "Status", fieldName: "Status" },
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

export default class AiJobListView extends LightningElement {
  aiJobRuns = [];
  @track columnVisibility = {};
  paginationInfo = {};
  error;
  isLoading = true;
  currentPage = 1;
  pageSize = 25;

  // Filters
  jobTypeFilter = "";
  targetFilter = "";
  statusFilter = "";
  startTimeFilter = "";
  endTimeFilter = "";
  jobTypeOptions = [];
  targetOptions = [];
  statusOptions = [];

  @wire(getAiJobRuns, {
    pageSize: "$pageSize",
    pageNumber: "$currentPage",
    jobTypeFilter: "$jobTypeFilter",
    targetFilter: "$targetFilter",
    statusFilter: "$statusFilter",
    startTimeFilter: "$startTimeFilter",
    endTimeFilter: "$endTimeFilter"
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

  @wire(getStatuses)
  wiredStatuses({ error, data }) {
    if (data) {
      this.statusOptions = data.map((status) => ({
        label: status,
        value: status
      }));
    } else if (error) {
      console.error("Error fetching statuses:", error);
    }
  }

  connectedCallback() {
    // Set all columns to visible by default
    this.columnVisibility = {};
    COLUMNS.forEach((column) => {
      const fieldName = this.getFieldNameFromColumn(column);
      this.columnVisibility[fieldName] = true;
    });
  }
  getFieldNameFromColumn(column) {
    if (column.type === "button") {
      return column.typeAttributes.label.fieldName;
    }
    return column.fieldName;
  }

  get visibleColumns() {
    return COLUMNS.filter((column) => {
      const fieldName = this.getFieldNameFromColumn(column);
      return this.columnVisibility[fieldName];
    });
  }

  get columnOptions() {
    const cols = COLUMNS.map((column) => {
      const fieldName = this.getFieldNameFromColumn(column);
      return {
        label: column.label,
        value: fieldName,
        checked: this.columnVisibility[fieldName]
      };
    });
    // Remove Name column from options
    return cols.filter((option) => option.value !== "Name");
  }

  get currentPageInfo() {
    if (!this.paginationInfo.totalRecords) return "";
    const start = (this.currentPage - 1) * this.pageSize + 1;
    const end = Math.min(this.currentPage * this.pageSize, this.paginationInfo.totalRecords);
    return `Showing ${start}-${end} of ${this.paginationInfo.totalRecords}`;
  }

  get hasActiveFilters() {
    return (
      this.jobTypeFilter !== "" ||
      this.targetFilter !== "" ||
      this.statusFilter !== "" ||
      this.startTimeFilter !== "" ||
      this.endTimeFilter !== ""
    );
  }

  get hasNoActiveFilters() {
    return (
      this.jobTypeFilter === "" &&
      this.targetFilter === "" &&
      this.statusFilter === "" &&
      this.startTimeFilter === "" &&
      this.endTimeFilter === ""
    );
  }

  handleJobTypeFilterChange(event) {
    this.jobTypeFilter = event.detail.value;
    this.currentPage = 1; // Reset to first page when filtering
  }

  handleTargetFilterChange(event) {
    this.targetFilter = event.detail.value;
    this.currentPage = 1; // Reset to first page when filtering
  }

  handleStatusFilterChange(event) {
    this.statusFilter = event.detail.value;
    this.currentPage = 1; // Reset to first page when filtering
  }

  handleStartTimeFilterChange(event) {
    this.startTimeFilter = event.detail.value;
    this.currentPage = 1; // Reset to first page when filtering
  }

  handleEndTimeFilterChange(event) {
    this.endTimeFilter = event.detail.value;
    this.currentPage = 1; // Reset to first page when filtering
  }

  handleClearFilters() {
    this.jobTypeFilter = "";
    this.targetFilter = "";
    this.statusFilter = "";
    this.startTimeFilter = "";
    this.endTimeFilter = "";
    this.currentPage = 1; // Reset to first page when clearing filters
  }

  handleColumnMenuSelect(event) {
    const selectedValue = event.detail.value;
    this.columnVisibility[selectedValue] = !this.columnVisibility[selectedValue];
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
    } else if (actionName === "view_target") {
      // Dispatch custom event to parent component with target
      const targetSelectedEvent = new CustomEvent("targetselected", {
        detail: { target: row.Target },
        bubbles: true
      });
      this.dispatchEvent(targetSelectedEvent);
    }
  }
}
