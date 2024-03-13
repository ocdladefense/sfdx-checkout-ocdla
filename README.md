# OCDLA Checkout
OCDLA Checkout is an Org-dependent Salesforce unlocked package implementing standard ecommerce checkout facilities for customers.   These facilities can be divided into a main controller for converting a Salesforce Opportunity object to an Order object; and related Apex classes and Visualforce pages for managing the customer's payment and shipping methods.

## Installation Notes

### Conflicting package: Communities
These classes were either required as dependencies or had naming conflicts names with existing classes.  They were temporarily removed from the installed Communities package and included as part of this OCDLACheckout package.
* PaymentMethodController.cls
* CommunityController.cls
* CommunityTemplateController.cls


## Relevant links
* More information on [dynamic DML](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dynamic_dml.htm)
* [Sandbox checkout page](https://ocdla--ocdpartial.sandbox.my.site.com/OcdlaCheckoutPayment)
* [Sandbox saved payment methods](https://ocdla--ocdpartial.sandbox.my.site.com/SavedPaymentMethods)
* [Sandbox saved shipping addresses](https://ocdla--ocdpartial.sandbox.my.site.com/SavedShippingAddresses)



## Authors
OCDLA would like to thank our spring and fall '23 web development interns for their work on this project.  Fall '23 interns also worked on the related Authorize.net API Apex SDK (on which this package depends).

### Spring '23 interns
* Zaelin Bull, LCC
* Isaac Lewis, LCC

### Fall '23 interns
* Mara Williams, LCC, [@maracw](https://github.com/maracw)
* Steven Brady, LCC, [@bradysteven06](https://github.com/bradysteven06)
* Alex Bedney, LCC, [@AlexBedney](https://github.com/AlexBedney)


## Dependencies
This package depends on the Salesforce [@ocdladefense/AuthorizeDotNet](https://github.com/ocdladefense/sfdx-ecommerce/tree/development).

## Screenshots

## Version History
### 0.2.11
Consolidate customer and profile functions into the <code>CurrentCustomer</code> and <code>CustomerProfile</code> classes.  The checkout page should display details of the customer's shopping cart and enough payment details to process a transaction and resulting Order for the cart.
* Simplify checkout page and related controller.
* Move functionality for retrieving specific attributes of checkout to the most appropriate classes.
* Process a <code>preSubmitPayment()</code> controller method on checkout page submit.
### 0.2.10
* First stable released version.
* Include components for editing saved payment and shipping addresses.

