/**
 * Script to merge menu categories with matching names and move menu items accordingly
 * This script identifies duplicate category names, merges them into one category,
 * moves all menu items to the merged category, and deletes the duplicate categories.
 */

// Query all menu categories
List<Menu_Category__c> menuCategories = [SELECT Id, Name FROM Menu_Category__c ORDER BY Name];
System.debug('Initial menu categories: ' + menuCategories.size());

// Query all menu items with their category information
List<Menu_Item__c> menuItems = [SELECT Id, Menu_Category__c FROM Menu_Item__c];
System.debug('Initial menu items: ' + menuItems.size());
// Map to group categories by name
Map<String, List<Menu_Category__c>> categoriesByName = new Map<String, List<Menu_Category__c>>();

// Group categories by name
for (Menu_Category__c category : menuCategories) {
    if (!categoriesByName.containsKey(category.Name)) {
        categoriesByName.put(category.Name, new List<Menu_Category__c>());
    }
    categoriesByName.get(category.Name).add(category);
}

// Lists to track what needs to be updated/deleted
List<Menu_Item__c> itemsToUpdate = new List<Menu_Item__c>();
List<Menu_Category__c> categoriesToDelete = new List<Menu_Category__c>();

// Process each group of categories with the same name
for (String categoryName : categoriesByName.keySet()) {
    List<Menu_Category__c> categoriesWithSameName = categoriesByName.get(categoryName);
    
    // If there's only one category with this name, skip it
    if (categoriesWithSameName.size() <= 1) {
        continue;
    }
    
    System.debug('Found ' + categoriesWithSameName.size() + ' categories with name: ' + categoryName);
    
    // Keep the first category (oldest by ID) and delete the rest
    Menu_Category__c categoryToKeep = categoriesWithSameName[0];
    List<Menu_Category__c> categoriesToRemove = new List<Menu_Category__c>();
    for (Integer i = 1; i < categoriesWithSameName.size(); i++) {
        categoriesToRemove.add(categoriesWithSameName[i]);
    }
    
    // Find all menu items that belong to the categories being removed
    for (Menu_Item__c item : menuItems) {
        for (Menu_Category__c categoryToRemove : categoriesToRemove) {
            if (item.Menu_Category__c == categoryToRemove.Id) {
                // Move this item to the category we're keeping
                item.Menu_Category__c = categoryToKeep.Id;
                itemsToUpdate.add(item);
                break;
            }
        }
    }
    
    // Add the categories to be removed to the delete list
    categoriesToDelete.addAll(categoriesToRemove);
}

// Execute the updates and deletions
if (!itemsToUpdate.isEmpty()) {
    System.debug('Updating ' + itemsToUpdate.size() + ' menu items to move them to merged categories');
    update itemsToUpdate;
}

if (!categoriesToDelete.isEmpty()) {
    System.debug('Deleting ' + categoriesToDelete.size() + ' duplicate menu categories');
    delete categoriesToDelete;
}

// Summary
System.debug('Merge operation completed:');
System.debug('- Menu items updated: ' + itemsToUpdate.size());
System.debug('- Categories deleted: ' + categoriesToDelete.size());
System.debug('- Remaining categories: ' + ([SELECT COUNT() FROM Menu_Category__c]));
System.debug('- Total menu items: ' + ([SELECT COUNT() FROM Menu_Item__c]));


