// Query all Review__c records
List<Review__c> reviews = [SELECT Id, Customer__c FROM Review__c];

// Query all Contact records
List<Contact> contacts = [SELECT Id FROM Contact];

if (contacts.isEmpty()) {
    System.debug('No contacts found. Cannot assign reviews.');
    return;
}

if (reviews.isEmpty()) {
    System.debug('No reviews found.');
    return;
}

// Randomly assign contacts to reviews
Integer contactCount = contacts.size();
for (Review__c review : reviews) {
    // Generate a random index between 0 and contactCount-1
    Integer randomIndex = Math.mod(Integer.valueOf(Math.random() * 10000), contactCount);
    review.Customer__c = contacts[randomIndex].Id;
}

// Update all reviews
update reviews;

System.debug('Assigned ' + reviews.size() + ' reviews to random contacts.');

