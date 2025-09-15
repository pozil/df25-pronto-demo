public with sharing class AiJobMonitorController {
  private static final Integer DEFAULT_PAGE_SIZE = 25;
  private static final Integer MAX_PAGE_SIZE = 200;

  /**
   * Retrieves AI Job Run Item records for a specific job run with pagination
   * @param jobRunId The ID of the AI Job Run
   * @param pageSize Number of records per page
   * @param pageNumber Page number (1-based)
   * @return Map containing records and pagination info
   */
  @AuraEnabled
  public static Map<String, Object> getAiJobRunItems(String jobRunId, Integer pageSize, Integer pageNumber) {
    try {
      // Validate and set defaults
      if (pageSize == null || pageSize <= 0) {
        pageSize = DEFAULT_PAGE_SIZE;
      }
      if (pageSize > MAX_PAGE_SIZE) {
        pageSize = MAX_PAGE_SIZE;
      }
      if (pageNumber == null || pageNumber <= 0) {
        pageNumber = 1;
      }
      if (String.isBlank(jobRunId)) {
        throw new AuraHandledException('Job Run ID is required');
      }

      Integer offset = (pageNumber - 1) * pageSize;

      // Get total count
      Integer totalRecords = [
        SELECT COUNT()
        FROM AiJobRunItem
        WHERE AiJobRunId = :jobRunId
        WITH USER_MODE
      ];

      // Get status counts
      List<AggregateResult> statusCounts = [
        SELECT Status, COUNT(Id) itemCount
        FROM AiJobRunItem
        WHERE AiJobRunId = :jobRunId
        WITH USER_MODE
        GROUP BY Status
        ORDER BY Status
      ];

      // Convert aggregate results to map
      Map<String, Integer> statusCountMap = new Map<String, Integer>();
      for (AggregateResult ar : statusCounts) {
        String status = (String) ar.get('Status');
        Integer count = (Integer) ar.get('itemCount');
        statusCountMap.put(status, count);
      }

      // Get paginated records
      List<AiJobRunItem> records = [
        SELECT Id, Status, ErrorCode, ErrorMessage, Input, PreprocessedInput, Response, LastModifiedDate
        FROM AiJobRunItem
        WHERE AiJobRunId = :jobRunId
        WITH USER_MODE
        ORDER BY CreatedDate DESC
        LIMIT :pageSize
        OFFSET :offset
      ];

      // Calculate pagination info
      Integer totalPages = (Integer) Math.ceil((Decimal) totalRecords / pageSize);

      Map<String, Object> result = new Map<String, Object>();
      result.put('records', records);
      result.put('totalRecords', totalRecords);
      result.put('totalPages', totalPages);
      result.put('currentPage', pageNumber);
      result.put('pageSize', pageSize);
      result.put('hasNextPage', pageNumber < totalPages);
      result.put('hasPreviousPage', pageNumber > 1);
      result.put('statusCounts', statusCountMap);

      return result;
    } catch (Exception e) {
      throw new AuraHandledException('Error retrieving AI Job Run Items: ' + e.getMessage());
    }
  }

  /**
   * Retrieves AI Job Run records with pagination
   * @param pageSize Number of records per page
   * @param pageNumber Page number (1-based)
   * @return Map containing records and pagination info
   */
  @AuraEnabled(cacheable=true)
  public static Map<String, Object> getAiJobRuns(Integer pageSize, Integer pageNumber) {
    try {
      // Validate and set defaults
      if (pageSize == null || pageSize <= 0) {
        pageSize = DEFAULT_PAGE_SIZE;
      }
      if (pageSize > MAX_PAGE_SIZE) {
        pageSize = MAX_PAGE_SIZE;
      }
      if (pageNumber == null || pageNumber <= 0) {
        pageNumber = 1;
      }

      Integer offset = (pageNumber - 1) * pageSize;

      // Get total count
      Integer totalRecords = [
        SELECT COUNT()
        FROM AiJobRun
        WITH USER_MODE
      ];

      // Get paginated records
      List<AiJobRun> records = [
        SELECT
          Id,
          JobType,
          Target,
          Status,
          CreatedDate,
          CreatedBy.Name,
          EndTime,
          ErrorCode,
          ErrorMessage,
          Label,
          Name,
          StartTime
        FROM AiJobRun
        WITH USER_MODE
        ORDER BY CreatedDate DESC
        LIMIT :pageSize
        OFFSET :offset
      ];

      // Calculate pagination info
      Integer totalPages = (Integer) Math.ceil((Decimal) totalRecords / pageSize);

      Map<String, Object> result = new Map<String, Object>();
      result.put('records', records);
      result.put('totalRecords', totalRecords);
      result.put('totalPages', totalPages);
      result.put('currentPage', pageNumber);
      result.put('pageSize', pageSize);
      result.put('hasNextPage', pageNumber < totalPages);
      result.put('hasPreviousPage', pageNumber > 1);

      return result;
    } catch (Exception e) {
      throw new AuraHandledException('Error retrieving AI Job Runs: ' + e.getMessage());
    }
  }
}
