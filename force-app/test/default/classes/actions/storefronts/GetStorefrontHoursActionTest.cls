/**
 * Tests for GetStorefrontHoursAction.
 */
@isTest
private class GetStorefrontHoursActionTest {
  @TestSetup
  static void setupTestData() {
    List<Storefront__c> storefronts = TestDataFactory.createStorefronts(1, true);
    TestDataFactory.createWeekdayHours(storefronts[0].Id, true);
  }

  @isTest
  static void shouldReturnHours_WhenStorefrontHasHours() {
    // Given
    Storefront__c storefront = [SELECT Id FROM Storefront__c LIMIT 1];
    GetStorefrontHoursAction.Input request = new GetStorefrontHoursAction.Input();
    request.storefrontId = storefront.Id;

    // When
    Test.startTest();
    List<GetStorefrontHoursAction.Output> responses = GetStorefrontHoursAction.getStorefrontHours(
      new List<GetStorefrontHoursAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.areEqual(1, responses.size(), 'One response should be returned');
    Assert.isTrue(responses[0].isSuccess, 'Response should be successful');
    Assert.areEqual(
      TestDataFactory.WEEK_DAYS.size(),
      responses[0].hours.size(),
      'All seven weekday hours should be returned'
    );
  }

  @isTest
  static void shouldReturnError_WhenStorefrontHasNoHours() {
    // Given
    Storefront__c storefront = TestDataFactory.createStorefronts(1, true)[0];
    GetStorefrontHoursAction.Input request = new GetStorefrontHoursAction.Input();
    request.storefrontId = storefront.Id;

    // When
    Test.startTest();
    List<GetStorefrontHoursAction.Output> responses = GetStorefrontHoursAction.getStorefrontHours(
      new List<GetStorefrontHoursAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.isFalse(responses[0].isSuccess, 'Response should not be successful');
    Assert.isTrue(responses[0].hours.isEmpty(), 'No hours should be returned');
    Assert.isTrue(
      responses[0].message.contains('No operating hours found'),
      'Message should indicate no hours were found'
    );
  }
}
