import { LightningElement, api } from "lwc";

import getAiJobRunItems from "@salesforce/apex/AiJobMonitorController.getAiJobRunItems";

const COLUMNS = [
  { label: "Status", fieldName: "Status" },
  { label: "Last Modified Date", fieldName: "LastModifiedDate" },
  {
    label: "Input",
    fieldName: "Input",
    type: "text",
    wrapText: true
  },
  {
    label: "Preprocessed Input",
    fieldName: "PreprocessedInput",
    type: "text",
    wrapText: true
  },
  {
    label: "Response",
    fieldName: "Response",
    type: "text",
    wrapText: true
  },
  { label: "Error Code", fieldName: "ErrorCode" },
  {
    label: "Error Message",
    fieldName: "ErrorMessage",
    type: "text",
    wrapText: true
  }
];

export default class AiJobItemListView extends LightningElement {
  @api jobRun;

  aiJobRunItems = [];
  paginationInfo = {};
  statusCounts = {};
  error;
  isLoading = true;
  currentPage = 1;
  pageSize = 25;

  connectedCallback() {
    this.refresh();
  }

  @api
  async refresh() {
    this.isLoading = true;
    try {
      const data = await getAiJobRunItems({
        jobRunId: this.jobRunId,
        pageSize: this.pageSize,
        pageNumber: this.currentPage
      });
      // Format the date fields for each record
      this.aiJobRunItems = data.records.map((record) => ({
        ...record,
        LastModifiedDate: this.formatDate(record.LastModifiedDate)
      }));
      this.paginationInfo = {
        totalRecords: data.totalRecords,
        totalPages: data.totalPages,
        currentPage: data.currentPage,
        pageSize: data.pageSize,
        hasNextPage: data.hasNextPage,
        hasPreviousPage: data.hasPreviousPage
      };
      this.statusCounts = data.statusCounts || {};
      this.error = undefined;
    } catch (error) {
      this.error = error;
      this.aiJobRunItems = [];
      this.paginationInfo = {};
      console.error("Error fetching AI Job Run Items:", JSON.stringify(error));
    } finally {
      this.isLoading = false;
    }
  }

  formatDate(dateValue) {
    if (!dateValue) return "";
    const dateTime = dateValue.split("T");
    const date = dateTime[0]; // yyyy-mm-dd
    const time = dateTime[1].split(".")[0]; // hh:mm:ss
    return `${date} ${time}`;
  }

  handleTargetClick(event) {
    event.preventDefault();
    const target = event.target.dataset.target;
    const targetSelectedEvent = new CustomEvent("targetselected", {
      detail: { target },
      bubbles: true
    });
    this.dispatchEvent(targetSelectedEvent);
  }

  // Pagination methods
  handleFirstPage() {
    this.currentPage = 1;
    this.refresh();
  }

  handlePreviousPage() {
    if (this.paginationInfo.hasPreviousPage) {
      this.currentPage = this.currentPage - 1;
      this.refresh();
    }
  }

  handleNextPage() {
    if (this.paginationInfo.hasNextPage) {
      this.currentPage = this.currentPage + 1;
      this.refresh();
    }
  }

  handleLastPage() {
    this.currentPage = this.paginationInfo.totalPages;
    this.refresh();
  }

  handlePageSizeChange(event) {
    this.pageSize = parseInt(event.target.value, 10);
    this.currentPage = 1; // Reset to first page when changing page size
    this.refresh();
  }

  get jobRunId() {
    return this.jobRun ? this.jobRun.Id : null;
  }

  get columns() {
    return COLUMNS;
  }

  get currentPageInfo() {
    if (!this.paginationInfo.totalRecords) return "";
    const start = (this.currentPage - 1) * this.pageSize + 1;
    const end = Math.min(this.currentPage * this.pageSize, this.paginationInfo.totalRecords);
    return `Showing ${start}-${end} of ${this.paginationInfo.totalRecords}`;
  }

  get statusSummary() {
    if (!this.statusCounts || Object.keys(this.statusCounts).length === 0) {
      return [];
    }

    return Object.entries(this.statusCounts).map(([status, count]) => ({
      status: status,
      count: count
    }));
  }

  get hasStatusCounts() {
    return this.statusSummary && this.statusSummary.length > 0;
  }

  get hasData() {
    return this.aiJobRunItems && this.aiJobRunItems.length > 0;
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

  get errorMessage() {
    return this.error ? this.error.body?.message : null;
  }

  get completionPercentage() {
    if (!this.statusCounts || Object.keys(this.statusCounts).length === 0) {
      return 0;
    }

    const totalItems = Object.values(this.statusCounts).reduce((sum, count) => sum + count, 0);
    if (totalItems === 0) return 0;

    const completedItems = this.statusCounts?.Completed || 0;
    return Math.round((completedItems / totalItems) * 100);
  }
}
