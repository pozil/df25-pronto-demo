public virtual with sharing class StorefrontService {
  private final Integer DEFAULT_STOREFRONT_LIMIT = 10;

  public virtual Storefront__c getStorefrontFromName(String storefrontName) {
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

  private Storefront__c resolveExactMatch(List<Storefront__c> storefronts, String storefrontName) {
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

  public virtual List<Storefront__c> getStorefronts(Integer recordLimit) {
    Integer resolvedLimit = (recordLimit == null || recordLimit <= 0) ? DEFAULT_STOREFRONT_LIMIT : recordLimit;

    return [
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
      WITH USER_MODE
      ORDER BY Name
      LIMIT :resolvedLimit
    ];
  }

  public virtual List<Storefront_Hours_of_Operation__c> getStorefrontHours(Id storefrontId) {
    if (storefrontId == null) {
      throw new StorefrontException('A storefront ID must be provided.');
    }

    return [
      SELECT Id, Day_of_Week__c, Opening_Time__c, Closing_Time__c, Storefront__c
      FROM Storefront_Hours_of_Operation__c
      WHERE Storefront__c = :storefrontId
      WITH USER_MODE
      ORDER BY Opening_Time__c
    ];
  }

  /**
   * Retrieves the available menu items for a storefront by its Id.
   * Menu items are resolved through their parent Menu's Storefront lookup and
   * only records flagged as available are returned.
   * @param storefrontId The Id of the storefront whose menu items are retrieved
   * @return The available menu items for the storefront
   * @throws StorefrontException if storefrontId is null
   * @example
   * List<Menu_Item__c> items = new StorefrontService().getMenuItems(storefrontId);
   */
  public virtual List<Menu_Item__c> getMenuItems(Id storefrontId) {
    if (storefrontId == null) {
      throw new StorefrontException('A storefront ID must be provided.');
    }

    return [
      SELECT
        Id,
        Name,
        Description__c,
        Price__c,
        Calories__c,
        Image_URL__c,
        Available__c,
        Menu__c,
        Menu_Category__c,
        Menu_Category__r.Name
      FROM Menu_Item__c
      WHERE Menu__r.Storefront__c = :storefrontId AND Available__c = TRUE
      WITH USER_MODE
      ORDER BY Menu_Category__r.Name NULLS LAST, Name
    ];
  }

  public class StorefrontException extends Exception {
  }
}
