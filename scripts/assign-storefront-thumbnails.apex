String orgDomain = URL.getOrgDomainURL().toExternalForm().replace('.my.salesforce.com', '.lightning.force.com');
Storefront__c[] stores = [SELECT Thumbnail__c FROM Storefront__c];
Integer i = 0;
for (Storefront__c s : stores) {
    s.Thumbnail__c = orgDomain+ '/resource/storefront_thumbnails/'+ i +'.jpg';
    i ++;
    if (i > 20) {
        i = 0;
    }
}
update stores;