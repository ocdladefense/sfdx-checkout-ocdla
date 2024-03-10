# OCDLA Checkout
OCDLA Checkout is an Org-dependent unlocked package implementing standard ecommerce checkout facilities for customers.   These facilities can be divided into a main controller for converting a Salesforce Opportunity object to an Order object; and related Apex classes and Visualforce pages for managing the customer's payment and shipping methods.

## Installation Notes
### Conflicting packages

### Communities
These classes were either required as dependencies or had name conflicts names with existing classes.  They were temporarily removed from the installed Communities package and included as part of this OCDLACheckout package.
* PaymentMethodController
* CommunityController


## Relevant links
* More information on [dynamic DML](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dynamic_dml.htm)
* [Sandbox checkout page](https://ocdla--ocdpartial.sandbox.my.site.com/OcdlaCheckoutPayment)
* [Sandbox saved payment methods](https://ocdla--ocdpartial.sandbox.my.site.com/SavedPaymentMethods)
* https://ocdla--ocdpartial--c.sandbox.vf.force.com/apex/PaymentMethodManager?core.apexpages.request.devconsole=1


## About intern projects

## Authors
OCDLA would like to thank our spring and fall '23 web development interns for their work on this project and work on the related Authorize.net API Apex SDK (on which this package depends).

### Spring '23 interns


### Fall '23 interns
* Mara Williams, LCC, [@maracw](https://github.com/maracw)
* Steven Brady, LCC, [@bradysteven06](https://github.com/bradysteven06)
* Alex Bedney, LCC, [@AlexBedney](https://github.com/AlexBedney)


## Dependencies

## Screenshots

## Version History
### 0.2.11
* Simplify checkout page and related controller.
### 0.2.10
* First stable released version.
* Include components for editing saved payment and shipping addresses.

