public with sharing class StorefrontService {
  public static Storefront__c getStorefrontFromName(String storefrontName) {
    if (String.isBlank(storefrontName)) {
      throw new StorefrontException('A storefront name must be provided.');
    }

    // Query for storefronts matching the provided name
    String likeName = '%' + storefrontName + '%';
    List<Storefront__c> storefronts = [
      SELECT
        Id,
        Name,
        Description__c,
        Cuisine__c,
        Address__c,
        Phone__c,
        Thumbnail__c,
        Status__c,
        Type__c,
        Average_Review_Score__c,
        Total_Reviews__c,
        Review_Summary__c
      FROM Storefront__c
      WHERE Name LIKE :likeName
      WITH USER_MODE
    ];

    if (storefronts.isEmpty()) {
      throw new StorefrontException('No storefront found with name: ' + storefrontName);
    }

    // Single match: return it directly
    if (storefronts.size() == 1) {
      return storefronts[0];
    }

    // Multiple matches: resolve to the exact name match or surface the options
    return resolveExactMatch(storefronts, storefrontName);
  }

  private static Storefront__c resolveExactMatch(List<Storefront__c> storefronts, String storefrontName) {
    Set<String> storefrontNames = new Set<String>();
    for (Storefront__c storefront : storefronts) {
      if (storefront.Name == storefrontName) {
        return storefront;
      }
      storefrontNames.add(storefront.Name);
    }

    // No exact match: surface the possible matches
    throw new StorefrontException(
      'Multiple storefronts found. Possible matches: ' + String.join(storefrontNames, ', ')
    );
  }

  public static List<Storefront_Hours_of_Operation__c> getHoursByStorefrontId(Id storefrontId) {
    if (storefrontId == null) {
      return new List<Storefront_Hours_of_Operation__c>();
    }

    return [
      SELECT Id, Day_of_Week__c, Opening_Time__c, Closing_Time__c, Storefront__c
      FROM Storefront_Hours_of_Operation__c
      WHERE Storefront__c = :storefrontId
      WITH USER_MODE
      ORDER BY Opening_Time__c
    ];
  }

  public class StorefrontException extends Exception {
  }
}
