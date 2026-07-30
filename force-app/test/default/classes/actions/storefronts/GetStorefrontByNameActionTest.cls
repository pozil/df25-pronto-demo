/**
 * Tests for GetStorefrontByNameAction.
 */
@isTest
private class GetStorefrontByNameActionTest {
  @isTest
  static void shouldReturnStorefront_WhenSingleMatch() {
    // Given
    TestDataFactory.createStorefronts(1, true);
    String name = TestDataFactory.STOREFRONT_NAME_PREFIX + '0';
    GetStorefrontByNameAction.Input request = new GetStorefrontByNameAction.Input();
    request.storefrontName = name;

    // When
    Test.startTest();
    List<GetStorefrontByNameAction.Output> responses = GetStorefrontByNameAction.getStorefrontByName(
      new List<GetStorefrontByNameAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.areEqual(1, responses.size(), 'One response should be returned');
    Assert.isTrue(responses[0].isSuccess, 'Response should be successful');
    Assert.areEqual(name, responses[0].storefront.Name, 'The matching storefront should be returned');
  }

  @isTest
  static void shouldReturnExactMatch_WhenMultipleMatches() {
    // Given: names 0..10 - querying '...1' also matches '...10' via LIKE
    TestDataFactory.createStorefronts(11, true);
    String name = TestDataFactory.STOREFRONT_NAME_PREFIX + '1';
    GetStorefrontByNameAction.Input request = new GetStorefrontByNameAction.Input();
    request.storefrontName = name;

    // When
    Test.startTest();
    List<GetStorefrontByNameAction.Output> responses = GetStorefrontByNameAction.getStorefrontByName(
      new List<GetStorefrontByNameAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.isTrue(responses[0].isSuccess, 'Response should be successful');
    Assert.isNotNull(responses[0].storefront, 'A storefront should be returned');
    Assert.areEqual(name, responses[0].storefront.Name, 'The exact-name match should be returned');
  }

  @isTest
  static void shouldReturnSimilarNames_WhenMultipleMatchesButNoExactMatch() {
    // Given: names '...0' and '...1', querying the prefix matches both but neither exactly
    TestDataFactory.createStorefronts(2, true);
    GetStorefrontByNameAction.Input request = new GetStorefrontByNameAction.Input();
    request.storefrontName = TestDataFactory.STOREFRONT_NAME_PREFIX;

    // When
    Test.startTest();
    List<GetStorefrontByNameAction.Output> responses = GetStorefrontByNameAction.getStorefrontByName(
      new List<GetStorefrontByNameAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.isFalse(responses[0].isSuccess, 'Response should not be successful');
    Assert.isNull(responses[0].storefront, 'No storefront should be returned');
    Assert.isTrue(
      responses[0].message.contains('Multiple storefronts found'),
      'Message should indicate multiple matches'
    );
  }

  @isTest
  static void shouldReturnError_WhenNoMatch() {
    // Given
    TestDataFactory.createStorefronts(1, true);
    GetStorefrontByNameAction.Input request = new GetStorefrontByNameAction.Input();
    request.storefrontName = 'Nonexistent Storefront';

    // When
    Test.startTest();
    List<GetStorefrontByNameAction.Output> responses = GetStorefrontByNameAction.getStorefrontByName(
      new List<GetStorefrontByNameAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.isFalse(responses[0].isSuccess, 'Response should not be successful');
    Assert.isNull(responses[0].storefront, 'No storefront should be returned');
    Assert.isTrue(responses[0].message.contains('No storefront found'), 'Message should indicate no match was found');
  }
}
