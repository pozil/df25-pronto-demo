String STOREFRONT_NAME = 'Artisan’s Edge Uptown';

Storefront__c[] storefronts = [SELECT Id FROM Storefront__c WHERE Name = :STOREFRONT_NAME];
if (storefronts.size() == 0) {
  System.debug('No storefront found with name: ' + STOREFRONT_NAME);
  return;
}
Storefront__c storefront = storefronts[0];

// Delete "Standard Menu" from storefront
delete [SELECT Id FROM Menu__c WHERE Storefront__c = :storefront.Id AND Menu_Display_Name__c = 'Standard Menu'];

// Remove attachments from storefront record
List<ContentDocumentLink> attachments = [
    SELECT Id, ContentDocumentId 
    FROM ContentDocumentLink 
    WHERE LinkedEntityId = :storefront.Id
];

if (!attachments.isEmpty()) {
    // Get the ContentDocument IDs to delete
    Set<Id> contentDocumentIds = new Set<Id>();
    for (ContentDocumentLink cdl : attachments) {
        contentDocumentIds.add(cdl.ContentDocumentId);
    }
    
    // Delete the ContentDocuments (this will also remove the ContentDocumentLinks)
    delete [
        SELECT Id, Title 
        FROM ContentDocument 
        WHERE Id IN :contentDocumentIds
    ];
} else {
    System.debug('No attachments found for storefront: ' + STOREFRONT_NAME);
}

System.debug('Menu demo reset completed for storefront: ' + STOREFRONT_NAME);
