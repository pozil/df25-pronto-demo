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
   * Retrieves AI Job Run records with pagination and filtering
   * @param pageSize Number of records per page
   * @param pageNumber Page number (1-based)
   * @param jobTypeFilter Optional filter for job type
   * @param targetFilter Optional filter for target
   * @param statusFilter Optional filter for status
   * @param startTimeFilter Optional filter for start time (after this time)
   * @param endTimeFilter Optional filter for end time (before this time)
   * @return Map containing records and pagination info
   */
  @AuraEnabled(cacheable=true)
  public static Map<String, Object> getAiJobRuns(
    Integer pageSize,
    Integer pageNumber,
    String jobTypeFilter,
    String targetFilter,
    String statusFilter,
    String startTimeFilter,
    String endTimeFilter
  ) {
    try {
      DateTime startTime;
      DateTime endTime;

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

      // Build dynamic WHERE clause based on filters
      String whereClause = '';
      List<String> conditions = new List<String>();

      if (String.isNotBlank(jobTypeFilter)) {
        conditions.add('JobType = :jobTypeFilter');
      }

      if (String.isNotBlank(targetFilter)) {
        conditions.add('Target = :targetFilter');
      }

      if (String.isNotBlank(statusFilter)) {
        conditions.add('Status = :statusFilter');
      }

      if (String.isNotBlank(startTimeFilter)) {
        startTime = (DateTime) JSON.deserialize('"' + startTimeFilter + '"', DateTime.class);
        conditions.add('StartTime >= :startTime');
      }

      if (String.isNotBlank(endTimeFilter)) {
        endTime = (DateTime) JSON.deserialize('"' + endTimeFilter + '"', DateTime.class);
        conditions.add('EndTime <= :endTime');
      }

      if (!conditions.isEmpty()) {
        whereClause = 'WHERE ' + String.join(conditions, ' AND ');
      }

      // Get total count with filters
      String countQuery = 'SELECT COUNT() FROM AiJobRun ' + whereClause + ' WITH USER_MODE';
      Integer totalRecords = Database.countQuery(countQuery);

      // Get paginated records with filters
      String recordsQuery =
        'SELECT Id, JobType, Target, Status, CreatedDate, CreatedBy.Name, EndTime, ErrorCode, ErrorMessage, Label, Name, StartTime FROM AiJobRun ' +
        whereClause +
        ' WITH USER_MODE ORDER BY CreatedDate DESC LIMIT :pageSize OFFSET :offset';
      List<AiJobRun> records = Database.query(recordsQuery);

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

  /**
   * Retrieves unique job types for filter options
   * @return List of unique job types
   */
  @AuraEnabled(cacheable=true)
  public static List<String> getJobTypes() {
    try {
      List<AggregateResult> results = [
        SELECT JobType
        FROM AiJobRun
        WHERE JobType != NULL
        WITH USER_MODE
        GROUP BY JobType
        ORDER BY JobType
      ];

      List<String> jobTypes = new List<String>();
      for (AggregateResult ar : results) {
        jobTypes.add((String) ar.get('JobType'));
      }

      return jobTypes;
    } catch (Exception e) {
      throw new AuraHandledException('Error retrieving job types: ' + e.getMessage());
    }
  }

  /**
   * Retrieves unique targets for filter options
   * @return List of unique targets
   */
  @AuraEnabled(cacheable=true)
  public static List<String> getTargets() {
    try {
      List<AggregateResult> results = [
        SELECT Target
        FROM AiJobRun
        WHERE Target != NULL
        WITH USER_MODE
        GROUP BY Target
        ORDER BY Target
      ];

      List<String> targets = new List<String>();
      for (AggregateResult ar : results) {
        targets.add((String) ar.get('Target'));
      }

      return targets;
    } catch (Exception e) {
      throw new AuraHandledException('Error retrieving targets: ' + e.getMessage());
    }
  }

  /**
   * Retrieves unique statuses for filter options
   * @return List of unique statuses
   */
  @AuraEnabled(cacheable=true)
  public static List<String> getStatuses() {
    try {
      List<AggregateResult> results = [
        SELECT Status
        FROM AiJobRun
        WHERE Status != NULL
        WITH USER_MODE
        GROUP BY Status
        ORDER BY Status
      ];

      List<String> statuses = new List<String>();
      for (AggregateResult ar : results) {
        statuses.add((String) ar.get('Status'));
      }

      return statuses;
    } catch (Exception e) {
      throw new AuraHandledException('Error retrieving statuses: ' + e.getMessage());
    }
  }
}
