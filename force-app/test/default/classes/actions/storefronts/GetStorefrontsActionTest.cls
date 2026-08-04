/**
 * Tests for GetStorefrontsAction.
 */
@isTest
private class GetStorefrontsActionTest {
  @isTest
  static void shouldReturnStorefronts_WhenStorefrontsExist() {
    // Given
    TestDataFactory.createStorefronts(3, true);
    GetStorefrontsAction.Input request = new GetStorefrontsAction.Input();

    // When
    Test.startTest();
    List<GetStorefrontsAction.Output> responses = GetStorefrontsAction.getStorefronts(
      new List<GetStorefrontsAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.areEqual(1, responses.size(), 'One response should be returned');
    Assert.isTrue(responses[0].isSuccess, 'Response should be successful');
    Assert.areEqual(3, responses[0].storefronts.size(), 'All storefronts should be returned');
  }

  @isTest
  static void shouldReturnFirstTen_WhenMoreThanTenExist() {
    // Given
    TestDataFactory.createStorefronts(15, true);
    GetStorefrontsAction.Input request = new GetStorefrontsAction.Input();

    // When
    Test.startTest();
    List<GetStorefrontsAction.Output> responses = GetStorefrontsAction.getStorefronts(
      new List<GetStorefrontsAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.isTrue(responses[0].isSuccess, 'Response should be successful');
    Assert.areEqual(10, responses[0].storefronts.size(), 'At most 10 storefronts should be returned');
  }

  @isTest
  static void shouldReturnEmptyList_WhenNoStorefrontsExist() {
    // Given
    GetStorefrontsAction.Input request = new GetStorefrontsAction.Input();

    // When
    Test.startTest();
    List<GetStorefrontsAction.Output> responses = GetStorefrontsAction.getStorefronts(
      new List<GetStorefrontsAction.Input>{ request }
    );
    Test.stopTest();

    // Then
    Assert.isTrue(responses[0].isSuccess, 'Response should be successful');
    Assert.areEqual(0, responses[0].storefronts.size(), 'No storefronts should be returned');
  }
}
