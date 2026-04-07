# Prompt 1 - Count the number of storefronts

How many storefronts are registered in my org?

# Prompt 2 - Create LWC with latest order

Create a latestOrderCard LWC that displays the latest confirmed customer order for a given storefront.
Create an OrderController.getLatestOrder AuraEnabled Apex method that takes the Storefront record ID and fetches these Order fields: name, status, total amount, order time.
The LWC should go on the Storefront record page flexipage on top of the right column.
Grab the record ID from the current page and use a wire to call getLatestOrder with the record ID.
Skip tests.
Deploy the metadata.

# Prompt 3 - Write and run Apex tests

Write the related Apex test, skip the LWC tests.
Deploy the metadata and run the OrderController Apex tests.

# Prompt 4 - Run Code Analyzer

Run Code Analyzer on the OrderController class.

# Prompt 5 - Add open record button to the LWC

Add a button that opens the order record page.
Use the standard:order_item icon for the card.
Place button in the "action" section of the card and make it a button icon.

# Prompt 6 - Create opening hours LWC from image

Create an openingHoursCard LWC that displays the hours of operation for a given storefront.
Use the attached image to build the UI.
Use the existing StoreController.getHoursOfOperation AuraEnabled Apex method that takes the Storefront record ID and returns the hours of operations for the store.
The LWC should go on the Storefront record page flexipage on top of the right column.
Grab the record ID from the current page and use a wire to call getHoursOfOperation with the record ID.
Skip tests.
Deploy the metadata.
