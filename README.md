# OCDLA Checkout
OCDLA Checkout is an Org-dependent Salesforce unlocked package implementing standard ecommerce checkout facilities for customers.   These facilities can be divided into a main controller for converting a Salesforce Opportunity object to an Order object; and related Apex classes and Visualforce pages for managing the customer's payment and shipping methods.

## Installation Notes

### Conflicting package: Communities
These classes were either required as dependencies or had naming conflicts names with existing classes.  They were temporarily removed from the installed Communities package and included as part of this OCDLACheckout package.
* PaymentMethodController.cls
* CommunityController.cls
* CommunityTemplateController.cls
* OrderConfirmationController.cls


## Relevant links
* More information on [dynamic DML](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dynamic_dml.htm)
* [Sandbox checkout page](https://ocdla--ocdpartial.sandbox.my.site.com/OcdlaCheckoutPayment?id=006VC000003TnBhYAK)
* [Sandbox saved payment methods](https://ocdla--ocdpartial.sandbox.my.site.com/SavedPaymentMethods)
* [Sandbox saved shipping addresses](https://ocdla--ocdpartial.sandbox.my.site.com/SavedShippingAddresses)



## Authors
OCDLA would like to thank our spring and fall '23 web development interns for their work on this project.  Fall '23 interns also worked on the related [Authorize.net API Apex SDK](https://github.com/ocdladefense/sfdx-ecommerce/tree/development) (on which this package depends).

### Spring '23 interns
* Zaelin Bull, LCC
* Isaac Lewis, LCC

### Fall '23 interns
* Mara Williams, LCC, [@maracw](https://github.com/maracw)
* Steven Brady, LCC, [@bradysteven06](https://github.com/bradysteven06)
* Alex Bedney, LCC, [@AlexBedney](https://github.com/AlexBedney)


## Dependencies
This package depends on the Salesforce [@ocdladefense/AuthorizeDotNet](https://github.com/ocdladefense/sfdx-ecommerce/tree/development) unlocked package to process Transactions against the Authorize.net payment gateway.

## Version History

### 0.2.13
Create two new classes:
* CartContainer, Description of CartContainer
* OrderContainer, Description of OrderContainer


### 0.2.12
The next minor version should continue progress on the checkout page and the <code>submitPayment()</code> method.  Use DML to create an Order from the Opportunity Object.  Insert the Order object.  Set the Order object to Active. The following classes will be updated:
* OcdlaCheckoutController.cls - Outline a complete Transaction flow in <code>submitPayment()</code>.
* OrderConfirmationController.cls
* OcdlaCheckoutPayment.vfp

### 0.2.11
Consolidate customer and profile functions into the <code>CurrentCustomer</code> and <code>CustomerProfile</code> classes.  The checkout page should display details of the customer's shopping cart and enough payment details to process a transaction and resulting Order for the cart.
* Simplify checkout page and related controller.
* Move functionality for retrieving specific attributes of checkout to the most appropriate classes.
* Process a <code>preSubmitPayment()</code> controller method on checkout page submit.
### 0.2.10
* First stable released version.
* Include components for editing saved payment and shipping addresses.

