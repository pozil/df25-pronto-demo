/**
 * Central factory for building test records. Keeps @TestSetup blocks free of
 * inline record construction so test data stays consistent across test classes.
 */
@isTest
public class TestDataFactory {
  public static final String STOREFRONT_NAME_PREFIX = 'Test Storefront ';
  public static final String CONTACT_LAST_NAME_PREFIX = 'Test Customer ';
  public static final String MENU_ITEM_NAME_PREFIX = 'Test Menu Item ';
  public static final Decimal MENU_ITEM_PRICE = 10;

  public static final List<String> WEEK_DAYS = new List<String>{
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  };

  /**
   * Builds Storefront records.
   * @param count Number of storefronts to build
   * @param doInsert Whether to insert the records
   * @return The built (and optionally inserted) storefronts
   */
  public static List<Storefront__c> createStorefronts(Integer count, Boolean doInsert) {
    List<Storefront__c> storefronts = new List<Storefront__c>();
    for (Integer i = 0; i < count; i++) {
      storefronts.add(new Storefront__c(Name = STOREFRONT_NAME_PREFIX + i));
    }
    if (doInsert && !storefronts.isEmpty()) {
      insert storefronts;
    }
    return storefronts;
  }

  /**
   * Builds one Hours of Operation record per weekday for the given storefront.
   * @param storefrontId The parent storefront Id
   * @param doInsert Whether to insert the records
   * @return The built (and optionally inserted) hours records
   */
  public static List<Storefront_Hours_of_Operation__c> createWeekdayHours(Id storefrontId, Boolean doInsert) {
    List<Storefront_Hours_of_Operation__c> hours = new List<Storefront_Hours_of_Operation__c>();
    for (String day : WEEK_DAYS) {
      hours.add(
        new Storefront_Hours_of_Operation__c(
          Storefront__c = storefrontId,
          Day_of_Week__c = day,
          Opening_Time__c = '09:00',
          Closing_Time__c = '17:00'
        )
      );
    }
    if (doInsert) {
      insert hours;
    }
    return hours;
  }

  /**
   * Builds Contact records to act as order customers, each with a mailing address.
   * @param count Number of contacts to build
   * @param doInsert Whether to insert the records
   * @return The built (and optionally inserted) contacts
   */
  public static List<Contact> createCustomers(Integer count, Boolean doInsert) {
    List<Contact> customers = new List<Contact>();
    for (Integer i = 0; i < count; i++) {
      customers.add(
        new Contact(
          LastName = CONTACT_LAST_NAME_PREFIX + i,
          MailingStreet = '415 Mission St',
          MailingCity = 'San Francisco',
          MailingState = 'CA',
          MailingPostalCode = '94105',
          MailingCountry = 'US'
        )
      );
    }
    if (doInsert && !customers.isEmpty()) {
      insert customers;
    }
    return customers;
  }

  /**
   * Builds a Menu for the given storefront.
   * @param storefrontId The parent storefront Id
   * @param doInsert Whether to insert the record
   * @return The built (and optionally inserted) menu
   */
  public static Menu__c createMenu(Id storefrontId, Boolean doInsert) {
    Menu__c menu = new Menu__c(Storefront__c = storefrontId, Active__c = true);
    if (doInsert) {
      insert menu;
    }
    return menu;
  }

  /**
   * Builds Menu Item records for the given menu.
   * @param menuId The parent menu Id
   * @param count Number of menu items to build
   * @param doInsert Whether to insert the records
   * @return The built (and optionally inserted) menu items
   */
  public static List<Menu_Item__c> createMenuItems(Id menuId, Integer count, Boolean doInsert) {
    List<Menu_Item__c> menuItems = new List<Menu_Item__c>();
    for (Integer i = 0; i < count; i++) {
      menuItems.add(
        new Menu_Item__c(
          Name = MENU_ITEM_NAME_PREFIX + i,
          Menu__c = menuId,
          Price__c = MENU_ITEM_PRICE,
          Available__c = true
        )
      );
    }
    if (doInsert && !menuItems.isEmpty()) {
      insert menuItems;
    }
    return menuItems;
  }

  /**
   * Builds Order records for the given customer and storefront.
   * @param customerId The customer (Contact) Id
   * @param storefrontId The parent storefront Id
   * @param status The order status
   * @param count Number of orders to build
   * @param doInsert Whether to insert the records
   * @return The built (and optionally inserted) orders
   */
  public static List<Order__c> createOrders(
    Id customerId,
    Id storefrontId,
    String status,
    Integer count,
    Boolean doInsert
  ) {
    List<Order__c> orders = new List<Order__c>();
    for (Integer i = 0; i < count; i++) {
      orders.add(
        new Order__c(
          Customer__c = customerId,
          Storefront__c = storefrontId,
          Status__c = status,
          Order_Time__c = System.now()
        )
      );
    }
    if (doInsert && !orders.isEmpty()) {
      insert orders;
    }
    return orders;
  }
}
