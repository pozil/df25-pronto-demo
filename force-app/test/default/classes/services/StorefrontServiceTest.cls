/**
 * Test class for StorefrontService.
 */
@isTest
private class StorefrontServiceTest {
  @TestSetup
  static void setupTestData() {
    List<Storefront__c> storefronts = TestDataFactory.createStorefronts(3, true);
    TestDataFactory.createWeekdayHours(storefronts[0].Id, true);
    Menu__c menu = TestDataFactory.createMenu(storefronts[0].Id, true);
    TestDataFactory.createMenuItems(menu.Id, 4, true);
  }

  @isTest
  static void shouldGetStorefrontFromName_WhenSingleMatch() {
    // Given
    StorefrontService service = new StorefrontService();
    String name = TestDataFactory.STOREFRONT_NAME_PREFIX + '0';

    // When
    Test.startTest();
    Storefront__c result = service.getStorefrontFromName(name);
    Test.stopTest();

    // Then
    Assert.isNotNull(result, 'Should return a storefront');
    Assert.areEqual(name, result.Name, 'Should return the correct storefront');
  }

  @isTest
  static void shouldGetStorefrontFromName_WhenExactMatchAmongMultiple() {
    // Given
    StorefrontService service = new StorefrontService();
    // Create storefronts 10 and 1, so querying '...1' matches both via LIKE
    Storefront__c sf10 = new Storefront__c(Name = TestDataFactory.STOREFRONT_NAME_PREFIX + '10');
    insert sf10;
    String exactName = TestDataFactory.STOREFRONT_NAME_PREFIX + '1';

    // When
    Test.startTest();
    Storefront__c result = service.getStorefrontFromName(exactName);
    Test.stopTest();

    // Then
    Assert.areEqual(exactName, result.Name, 'Should return the exact match');
  }

  @isTest
  static void shouldThrowException_WhenMultipleMatchesButNoExactMatch() {
    // Given
    StorefrontService service = new StorefrontService();
    // Query just the prefix, which matches all storefronts but none exactly
    String prefix = TestDataFactory.STOREFRONT_NAME_PREFIX;

    // When / Then
    Test.startTest();
    try {
      service.getStorefrontFromName(prefix);
      Assert.fail('Should have thrown StorefrontException');
    } catch (StorefrontService.StorefrontException e) {
      Assert.isTrue(
        e.getMessage().contains('Multiple storefronts found'),
        'Exception should indicate multiple matches'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void shouldThrowException_WhenNoStorefrontFound() {
    // Given
    StorefrontService service = new StorefrontService();
    String nonExistentName = 'Nonexistent Storefront';

    // When / Then
    Test.startTest();
    try {
      service.getStorefrontFromName(nonExistentName);
      Assert.fail('Should have thrown StorefrontException');
    } catch (StorefrontService.StorefrontException e) {
      Assert.isTrue(e.getMessage().contains('No storefront found'), 'Exception should indicate storefront not found');
    }
    Test.stopTest();
  }

  @isTest
  static void shouldThrowException_WhenStorefrontNameIsBlank() {
    // Given
    StorefrontService service = new StorefrontService();

    // When / Then
    Test.startTest();
    try {
      service.getStorefrontFromName('');
      Assert.fail('Should have thrown StorefrontException');
    } catch (StorefrontService.StorefrontException e) {
      Assert.isTrue(e.getMessage().contains('must be provided'), 'Exception should indicate name is required');
    }
    Test.stopTest();
  }

  @isTest
  static void shouldGetStorefronts_WithDefaultLimit() {
    // Given
    StorefrontService service = new StorefrontService();

    // When
    Test.startTest();
    List<Storefront__c> results = service.getStorefronts(null);
    Test.stopTest();

    // Then
    Assert.isTrue(results.size() <= 10, 'Should return at most 10 storefronts (default limit)');
    Assert.isTrue(results.size() > 0, 'Should return some storefronts');
  }

  @isTest
  static void shouldGetStorefronts_WithCustomLimit() {
    // Given
    StorefrontService service = new StorefrontService();

    // When
    Test.startTest();
    List<Storefront__c> results = service.getStorefronts(2);
    Test.stopTest();

    // Then
    Assert.areEqual(2, results.size(), 'Should return exactly 2 storefronts');
  }

  @isTest
  static void shouldGetStorefronts_ApplyDefaultWhenInvalidLimit() {
    // Given
    StorefrontService service = new StorefrontService();

    // When
    Test.startTest();
    List<Storefront__c> results = service.getStorefronts(0);
    Test.stopTest();

    // Then
    Assert.isTrue(results.size() <= 10, 'Should apply default limit when invalid limit provided');
  }

  @isTest
  static void shouldGetStorefrontHours_WhenHoursExist() {
    // Given
    StorefrontService service = new StorefrontService();
    Storefront__c storefront = [
      SELECT Id
      FROM Storefront__c
      WHERE Name = :TestDataFactory.STOREFRONT_NAME_PREFIX + '0'
      LIMIT 1
    ];

    // When
    Test.startTest();
    List<Storefront_Hours_of_Operation__c> results = service.getStorefrontHours(storefront.Id);
    Test.stopTest();

    // Then
    Assert.areEqual(7, results.size(), 'Should return hours for all 7 days');
    for (Storefront_Hours_of_Operation__c hours : results) {
      Assert.areEqual(storefront.Id, hours.Storefront__c, 'All hours should belong to the storefront');
      Assert.isNotNull(hours.Day_of_Week__c, 'Should include day of week');
      Assert.isNotNull(hours.Opening_Time__c, 'Should include opening time');
      Assert.isNotNull(hours.Closing_Time__c, 'Should include closing time');
    }
  }

  @isTest
  static void shouldReturnEmptyList_WhenStorefrontHasNoHours() {
    // Given
    StorefrontService service = new StorefrontService();
    Storefront__c storefront = [
      SELECT Id
      FROM Storefront__c
      WHERE Name = :TestDataFactory.STOREFRONT_NAME_PREFIX + '1'
      LIMIT 1
    ];

    // When
    Test.startTest();
    List<Storefront_Hours_of_Operation__c> results = service.getStorefrontHours(storefront.Id);
    Test.stopTest();

    // Then
    Assert.areEqual(0, results.size(), 'Should return empty list when no hours exist');
  }

  @isTest
  static void shouldThrowException_WhenStorefrontHoursIdIsNull() {
    // Given
    StorefrontService service = new StorefrontService();

    // When / Then
    Test.startTest();
    try {
      service.getStorefrontHours(null);
      Assert.fail('Should have thrown StorefrontException');
    } catch (StorefrontService.StorefrontException e) {
      Assert.isTrue(e.getMessage().contains('must be provided'), 'Exception should indicate ID is required');
    }
    Test.stopTest();
  }

  @isTest
  static void shouldGetMenuItems_WhenItemsExist() {
    // Given
    StorefrontService service = new StorefrontService();
    Storefront__c storefront = [
      SELECT Id
      FROM Storefront__c
      WHERE Name = :TestDataFactory.STOREFRONT_NAME_PREFIX + '0'
      LIMIT 1
    ];

    // When
    Test.startTest();
    List<Menu_Item__c> results = service.getMenuItems(storefront.Id);
    Test.stopTest();

    // Then
    Assert.areEqual(4, results.size(), 'Should return all available menu items for the storefront');
    for (Menu_Item__c menuItem : results) {
      Assert.isTrue(menuItem.Available__c, 'Only available menu items should be returned');
      Assert.isNotNull(menuItem.Name, 'Should include menu item name');
      Assert.isNotNull(menuItem.Menu__c, 'Should include parent menu');
    }
  }

  @isTest
  static void shouldExcludeUnavailableItems_WhenGettingMenuItems() {
    // Given
    StorefrontService service = new StorefrontService();
    Storefront__c storefront = [
      SELECT Id
      FROM Storefront__c
      WHERE Name = :TestDataFactory.STOREFRONT_NAME_PREFIX + '0'
      LIMIT 1
    ];
    List<Menu_Item__c> items = [SELECT Id FROM Menu_Item__c LIMIT 1];
    items[0].Available__c = false;
    update items;

    // When
    Test.startTest();
    List<Menu_Item__c> results = service.getMenuItems(storefront.Id);
    Test.stopTest();

    // Then
    Assert.areEqual(3, results.size(), 'Should exclude unavailable menu items');
  }

  @isTest
  static void shouldReturnEmptyList_WhenStorefrontHasNoMenuItems() {
    // Given
    StorefrontService service = new StorefrontService();
    Storefront__c storefront = [
      SELECT Id
      FROM Storefront__c
      WHERE Name = :TestDataFactory.STOREFRONT_NAME_PREFIX + '1'
      LIMIT 1
    ];

    // When
    Test.startTest();
    List<Menu_Item__c> results = service.getMenuItems(storefront.Id);
    Test.stopTest();

    // Then
    Assert.areEqual(0, results.size(), 'Should return empty list when no menu items exist');
  }

  @isTest
  static void shouldThrowException_WhenMenuItemsStorefrontIdIsNull() {
    // Given
    StorefrontService service = new StorefrontService();

    // When / Then
    Test.startTest();
    try {
      service.getMenuItems(null);
      Assert.fail('Should have thrown StorefrontException');
    } catch (StorefrontService.StorefrontException e) {
      Assert.isTrue(e.getMessage().contains('must be provided'), 'Exception should indicate ID is required');
    }
    Test.stopTest();
  }
}
