/**
 * Script to clear Menu_Category__c records that have no associated Menu_Item__c records
 * This script identifies categories with no menu items and deletes them to clean up the database.
 */

// Query all menu categories
List<Menu_Category__c> allCategories = [SELECT Id, Name FROM Menu_Category__c];
System.debug('Total menu categories found: ' + allCategories.size());

// Query all menu items with their category information
List<Menu_Item__c> allMenuItems = [SELECT Id, Menu_Category__c FROM Menu_Item__c];
System.debug('Total menu items found: ' + allMenuItems.size());

// Create a set of category IDs that have menu items
Set<Id> categoriesWithItems = new Set<Id>();
for (Menu_Item__c item : allMenuItems) {
    if (item.Menu_Category__c != null) {
        categoriesWithItems.add(item.Menu_Category__c);
    }
}

// Find categories that have no menu items
List<Menu_Category__c> emptyCategories = new List<Menu_Category__c>();
for (Menu_Category__c category : allCategories) {
    if (!categoriesWithItems.contains(category.Id)) {
        emptyCategories.add(category);
        System.debug('Empty category found: ' + category.Name + ' (ID: ' + category.Id + ')');
    }
}

// Delete empty categories
if (!emptyCategories.isEmpty()) {
    System.debug('Deleting ' + emptyCategories.size() + ' empty menu categories');
    delete emptyCategories;
    
    // Summary of deleted categories
    for (Menu_Category__c deletedCategory : emptyCategories) {
        System.debug('Deleted empty category: ' + deletedCategory.Name);
    }
} else {
    System.debug('No empty menu categories found');
}

// Final summary
System.debug('Cleanup operation completed:');
System.debug('- Empty categories deleted: ' + emptyCategories.size());
System.debug('- Remaining categories: ' + ([SELECT COUNT() FROM Menu_Category__c]));
System.debug('- Total menu items: ' + allMenuItems.size());
