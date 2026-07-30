/**
 * @description Service layer for customer review operations. Encapsulates all
 * SOQL/DML and job orchestration related to Review__c records so that invocable
 * actions and other callers remain free of data-access logic.
 */
public with sharing class ReviewService {
  /**
   * @description Retrieves customer reviews for a given storefront, most recent first.
   * @param storefrontId The ID of the storefront to retrieve reviews for
   * @return List of reviews for the storefront (never null)
   * @throws ReviewException if the storefront ID is blank
   * @example
   * List<Review__c> reviews = ReviewService.getReviewsForStorefront(storefrontId);
   */
  public static List<Review__c> getReviewsForStorefront(Id storefrontId) {
    if (storefrontId == null) {
      throw new ReviewException('Storefront ID is required');
    }
    return [
      SELECT Id, Rating__c, Comments__c, Status__c, Order_Date__c, CreatedDate
      FROM Review__c
      WHERE Storefront__c = :storefrontId
      WITH USER_MODE
      ORDER BY CreatedDate DESC
    ];
  }

  /**
   * @description Starts the asynchronous job that regenerates store review summaries.
   * @param forceRefresh Whether to force a refresh even if summaries already exist
   * @example
   * ReviewService.refreshStoreReviewSummaries(true);
   */
  public static void refreshStoreReviewSummaries(Boolean forceRefresh) {
    StoreReviewSummaryAiJob.startJob(forceRefresh == true);
  }

  /**
   * @description Domain exception for review service errors.
   */
  public class ReviewException extends Exception {
  }
}
