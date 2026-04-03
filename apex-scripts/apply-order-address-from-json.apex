String deliveryStreet = '87 Judy Center';
String deliveryCity = 'Savannah';
String deliveryStateCode = 'CA';
String deliveryPostalCode = '31416';
String deliveryCountryCode = 'US';

List<Order__c> orders = [
    SELECT Id
    FROM Order__c
];

for (Order__c orderRecord : orders) {
    orderRecord.Delivery_Address__Street__s = deliveryStreet;
    orderRecord.Delivery_Address__City__s = deliveryCity;
    orderRecord.Delivery_Address__StateCode__s = deliveryStateCode;
    orderRecord.Delivery_Address__PostalCode__s = deliveryPostalCode;
    orderRecord.Delivery_Address__CountryCode__s = deliveryCountryCode;
}

if (!orders.isEmpty()) {
    update orders;
}

System.debug('Updated ' + orders.size() + ' Order__c records with the first JSON address.');
