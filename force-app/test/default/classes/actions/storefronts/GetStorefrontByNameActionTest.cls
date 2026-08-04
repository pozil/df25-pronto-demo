@isTest
private class GetStorefrontByNameActionTest {
  private class MockStorefrontService extends StorefrontService {
    public Boolean shouldThrowException = false;
    public String exceptionMessage;
    public Storefront__c mockStorefront;

    public override Storefront__c getStorefrontFromName(String storefrontName) {
      if (shouldThrowException) {
        throw new StorefrontService.StorefrontException(exceptionMessage);
      }
      return mockStorefront;
    }
  }

  @isTest
  static void testGetStorefrontByName_Success() {
    Storefront__c mockStorefront = new Storefront__c(
      Id = TestDataFactory.getFakeId(Storefront__c.SObjectType),
      Name = 'Test Storefront',
      Description__c = 'A test storefront',
      Cuisine__c = 'Italian',
      Status__c = 'Open'
    );

    MockStorefrontService mockService = new MockStorefrontService();
    mockService.mockStorefront = mockStorefront;
    GetStorefrontByNameAction.storefrontService = mockService;

    GetStorefrontByNameAction.Input input = new GetStorefrontByNameAction.Input();
    input.storefrontName = 'Test Storefront';
    List<GetStorefrontByNameAction.Input> inputs = new List<GetStorefrontByNameAction.Input>{ input };

    Test.startTest();
    List<GetStorefrontByNameAction.Output> outputs = GetStorefrontByNameAction.getStorefrontByName(inputs);
    Test.stopTest();

    System.assertEquals(1, outputs.size());
    GetStorefrontByNameAction.Output output = outputs[0];
    System.assertEquals(true, output.isSuccess);
    System.assertEquals('Storefront retrieved successfully', output.message);
    System.assertNotEquals(null, output.storefront);
    System.assertEquals('Test Storefront', output.storefront.Name);
  }

  @isTest
  static void testGetStorefrontByName_Failure() {
    MockStorefrontService mockService = new MockStorefrontService();
    mockService.shouldThrowException = true;
    mockService.exceptionMessage = 'No storefront found with name: NonExistent';
    GetStorefrontByNameAction.storefrontService = mockService;

    GetStorefrontByNameAction.Input input = new GetStorefrontByNameAction.Input();
    input.storefrontName = 'NonExistent';
    List<GetStorefrontByNameAction.Input> inputs = new List<GetStorefrontByNameAction.Input>{ input };

    Test.startTest();
    List<GetStorefrontByNameAction.Output> outputs = GetStorefrontByNameAction.getStorefrontByName(inputs);
    Test.stopTest();

    System.assertEquals(1, outputs.size());
    GetStorefrontByNameAction.Output output = outputs[0];
    System.assertEquals(false, output.isSuccess);
    System.assertEquals('No storefront found with name: NonExistent', output.message);
    System.assertEquals(null, output.storefront);
  }
}
