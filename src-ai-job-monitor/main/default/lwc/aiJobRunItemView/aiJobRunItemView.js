import { LightningElement, wire, api } from "lwc";

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

export default class AiJobRunItemView extends LightningElement {
  @api jobRun;

  aiJobRunItems = [];
  paginationInfo = {};
  error;
  isLoading = true;
  currentPage = 1;
  pageSize = 25;

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

  @wire(getAiJobRunItems, { jobRunId: "$jobRunId", pageSize: "$pageSize", pageNumber: "$currentPage" })
  wiredAiJobRunItems({ error, data }) {
    this.isLoading = false;
    if (data) {
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
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.aiJobRunItems = [];
      this.paginationInfo = {};
      console.error("Error fetching AI Job Run Items:", error);
    }
  }

  formatDate(dateValue) {
    if (!dateValue) return "";
    const dateTime = dateValue.split("T");
    const date = dateTime[0]; // yyyy-mm-dd
    const time = dateTime[1].split(".")[0]; // hh:mm:ss
    return `${date} ${time}`;
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
}
