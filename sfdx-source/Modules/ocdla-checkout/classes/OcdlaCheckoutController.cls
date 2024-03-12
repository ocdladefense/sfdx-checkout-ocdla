global without sharing class OcdlaCheckoutController extends CommunityController {
	
    
    public String cartId {get; private set;}
    
    
    // The loaded Shopping cart for this customer.
    private Opportunity cart {get; set;}

    
    // The current customer for this Shopping cart.
    public Contact customer {get; private set;}
    
    
    // Order would be produced on successful transaction.
    // Otherwise we would ideally rollback so that the Order is
    // actually not persisted.
    Order order {get; private set;}

	
    // Whether the current user is a logged in customer.
    // If not then this is the Guest user.
    public Boolean isLoggedIn {get; private set;}
    
    
    // A summary of this Shopping cart's items.
    public String shoppingCartSummary {get;private set;}
    

    // If the Amount of the Opportunity is $0.00 then it is considered free.
    public Boolean isFreeCart {get;private set;}
    
    
    // Boolean indicating whether the Shopping cart contains
    // any shippable products.
    public Boolean hasShippableProducts {get {return hasShippableProducts(this.cartId);}private set;}

    
    // Whether to show payment-related options at checkout.
    // For example, if the Shopping cart contains $0.00 worth of items there 
    // is no need to show payment options, as no payment is required.
    public Boolean renderPayment {get;private set;}

    
    // Whether this Shopping cart has already been paid of.
    // This can be indicated by the Opportunity Status field value of 'Closed Won'.
    public Boolean isPaid {get;private set;} 
  

    // Stores the CustomerPaymentProfile objects.
    // Never used directly on the checkout page.
    // Instead the customer uses the related SelectOption (or otherwise manages them through a separate controller).
	private CustomerPaymentProfileCollection paymentProfiles;
    
    public String selectedPaymentProfileId {get;public set;}
    
    public CustomerPaymentProfile selectedPaymentProfile {get; public set;}
        
    public CustomerProfile customerProfile;
    
    public AuthNetAddress shipTo {get; private set;}
    
    // Add or rename instance variable for shipping to reflect the address the customer has chosen for this interaction.
    // e.g., public Address selectedShippingAddress;
    
    


    
    
    /**
     * @constructor OcdlaCheckoutController
     * 
     * Pay for an Opportunity; convert it to an Order.
     */
    public OcdlaCheckoutController() {
        super('CheckoutCommunityConfig');

		Map<String,String> params = ApexPages.CurrentPage().getParameters();
		this.cartId = params.get('id');
        
        if(null == cartId) {
            throw new CheckoutException('CHECKOUT_INIT_ERROR: No valid cartId provided (NULL).');
        }

        
        this.cart = [SELECT Id, Name, Amount, StageName, AccountId, Contact__c, Pricebook2Id FROM Opportunity WHERE Id = :this.cartId];
        

        // Pulled from Authorize dot net 3/9/2024.
        String customerProfileId = '905372692';
        
        this.customer = CurrentCustomer.getCustomerContact();
        
		this.customerProfile = CurrentCustomer.getCustomerProfile('905372692');
		System.debug(this.customerProfile);
        System.debug(this.customerProfile.getPaymentProfiles());
        // Why do we need to check if Sandbox.  Could be legit, but let's find out the *why!
        // this.isSandbox = CurrentCustomer.isSandbox();

        this.hasShippableProducts = False;
        
        this.isPaid = this.cart.StageName == 'Closed Won';
        
        this.isFreeCart = !(this.cart.Amount > 0.00);
                
        // No need to render payment inputs if the Order was already placed,
        // or if no payment is required.
        this.renderPayment = !this.isPaid && !this.isFreeCart;
    }

    

    public List<SelectOption> getSavedPaymentProfileOptions() {

		System.debug(this.paymentProfiles);
        
		List<SelectOption> options = new List<SelectOption>();

        
        List<CustomerPaymentProfile> profiles = this.customerProfile.paymentProfiles;
        
        for(CustomerPaymentProfile profile : profiles) {
            SelectOption option = profile.toSelectOption();
            	
            options.add(option);
        }
        
		options.add(new SelectOption('',' New Card'));
   
		return options;
	}

    

    
    
    

    
   

    
    
    public String getDefaultPaymentProfileBillingAddressFormatted() {
        
        String addy = CurrentCustomer.formatAddress(new AuthNetAddress(customer.FirstName, customer.LastName, '123 Monroe Ave.', 'Corvallis', 'OR', '97443'));
        System.debug(addy);
        
        return addy;
    }
    
    
    public String getDefaultShippingAddressFormatted() {
        
        String addy = CurrentCustomer.formatAddress(new AuthNetAddress(customer.FirstName, customer.LastName, '123 Monroe Ave.', 'Corvallis', 'OR', '97443'));
        System.debug(addy);
        
        return addy;
    }
    

    

    
    

    
    
    public PageReference checkoutAsGuest() {
        System.debug('am I being called???');
        System.debug('Hallo!!');
        
		
        PageReference nextPage = Page.OcdlaCheckoutPayment;
        Map<String,String> params = nextPage.getParameters();
        
        params.put('id', this.cartId);

        
        // Collect FirstName, LastName, Email, AccountId.
        // 
        // Creating a new Contact in our CRM with the above values.
        

        
        // Creates guest contact, attaches to opportunity, inserts contact, then updates opportunity all in one go
        // customer = ClickpdxCheckoutGuestController.generateGuestCheckoutContact(customer, this.cartId);
        this.customer.AccountId = CurrentCustomer.getGuestCheckoutAccountId();
        upsert this.customer;
        
        // Guest customer now has an Id, which we want to associate with the underlying Opportunity.
        attachAccount(this.customer, this.cartId);
        
        
        // Reading documentation to figure out how to redirect.
        // return Page.Whatever (where Whatever is the name of the next page in the "flow");
        nextPage.setRedirect(False);
        return nextPage;
    }


    public PageReference redirectIfSobjectError(){
		return OrgOcdla.redirectTo(OrgOcdla.SHOPPING_CART_REGENERATE_OPPORTUNITY_PAGE);
    }
    
    @RemoteAction
    global static Boolean attachAccount(Contact c, String oppId){
        Id accountId;
        
        // accountId = 
        Opportunity opp = new Opportunity(Id = oppId, AccountId = c.AccountId, Contact__c=c.Id);
        update opp;
        return True;
    }
    
        
    public String getCartName() {
        return this.cart.Name;
    }
    
    
    public String getCartTotal() {
        return String.valueOf(this.cart.Amount);
    }
    
    
    public String getOrderEmail() {

        return this.customer.Email;
    }


    
    public void preSubmitPayment() {
        System.debug('yoyoyoyo');
        // this.order = this.processOrderStub();
    }
    
    /*
    public PageReference submitPayment() {
        System.debug(this.billingData);
        
        TransactionRequest req = new TransactionRequest();
        req.setAmount(this.opp.Amount);
        req.setCreditCard(this.ccData);
        req.setBillToAddress(this.billingData);
        req.setShipToAddress(this.shippingData);

        AuthorizeDotNetClient client = new AuthorizeDotNetClient(AuthorizeDotNetClient.GATEWAY_SANDBOX_URL);
        
        TransactionResponse resp = client.send(req);

        
        
        //Map<String, String> newData = transact.getResponse();
        
        if (!resp.success()) {
            // do errors
            // noo
            System.debug(this.ccData);
            System.debug(resp.getBody());
            return null;
        }
        
       
        
        // if..else
        // success
		order = this.finalizeOrder(order.Id, resp.getBody());    
        
        
        // 
        // Takes billing and shipping information using billingData and shippingData and ccData
        // Submits all information to the credit card processing controller (OcdlaCCAuthorize controller) using static function
        // Get result from submitting data
        // if..else success, redirect to order confirmation page. else, "you failed"
		// if success, calls processOrderStub first, that gets opportunity (which we wont have to do because we call all of this serverside)
        //         
		PageReference nextPage = Page.OrderConfirmation;
        Map<String,String> params = nextPage.getParameters();
        // processOrderStub() - make sure we can successfully convert the shopping cart into an order
        // Note: This does NOT create order items. We only create order items when we finalize the order.
        // 
        // OcdlaCCAuthorize. - process cc data.
        // 
        // finalizeOrder() - creates the order with the verified data.
        
        
        string theOrderId = order.Id;
        params.put('id', theOrderId);
        
        // Reading documentation to figure out how to redirect.
        // return Page.Whatever (where Whatever is the name of the next page in the "flow");
        nextPage.setRedirect(True);
        return nextPage;        
    }
    
    public Order processOrderStub(){
        // get opportunity id (shopping cart id)
        // format billing data into map<string, string>
        // construct billing data (billingfirstname, billinglastname, billingaddress, etc)
        Order o;
		System.debug(this.billingData);
        System.debug(this.shippingData);
        o = ClickpdxOrder.newFromShoppingCart(this.opp, this.billingData, this.shippingData);
        upsert o;
        
        return [SELECT Id, OrderNumber, EffectiveDate, Status, OpportunityId, AccountId, BillToContactId,
                               ShipToContactId, PriceBook2Id FROM Order WHERE Id = :o.Id];
    }
    */
    public Order finalizeOrder(String orderId, Map<String,String> ccResp){
        
        Order o = new Order();
        o.Id = orderId;
        o.Payment_Info__c = JSON.serialize(ccResp);
        o.Origin__c = 'Web Order';
        
        update o; //actually updates
        
		ClickpdxOrder.draftOrderLinesFromShoppingCart(o.Id);
        
		ClickpdxOrder.activateOrder(orderId);
        
        return [SELECT Id, Payment_Info__c, Origin__c FROM Order WHERE Id = :orderId];
    }

    
    @RemoteAction
    global static List<Contact> checkOrderEmail(String email){
       String out = email.trim();
        
       Map<String,String> resp = new Map<String,String>();
        
       List<Contact> c = [SELECT FirstName, LastName, Email, MailingStreet, MailingPostalCode, MailingCity, Ocdla_Address_Line_1__c, 
                          Ocdla_Address_Line_2__c, MailingStateCode, AccountId, Account.Name FROM Contact WHERE Email = :out OR OrderApi__Work_Email__c = :out];
       
       return c;
    }

    
    
    @RemoteAction
    global static Contact generateGuestCheckoutContact(Contact c, Id oppId){
        String firstName = c.FirstName;
        String lastName = c.LastName;
        String emails = c.Email;
        
        
        
        
        Contact guest = new Contact(AccountId = CurrentCustomer.getGuestCheckoutAccountId(), 
                                    FirstName = c.FirstName,
                                    LastName = c.LastName,
                                    Email = c.Email,
                                    OrderApi__Work_Email__c = c.Email);
        
        insert guest;
        attachAccount(guest,oppId);
        return guest;
 
    }    
    
    

    private static Boolean hasShippableProducts(Id cartId){
        List<OpportunityLineItem> lines = [SELECT Id, Product2.IsShippable__c FROM OpportunityLineItem WHERE OpportunityId = :cartId];
        
        for(OpportunityLineItem line :lines){
            if(line.Product2.IsShippable__c) return True;
        }
        
        return False;
    }

    
    
	// Should also determine if the current User has access rights.
    public Boolean getShowPaymentGatewayOptions() {

        return CurrentCustomer.isSandbox(); // && isAdmin();
    }
  
    public String getSelectedPaymentMethodText() {
        
        CustomerPaymentProfile first = this.getFirst();
        
		return first.cardType + ' ' + first.cardNumber;
    }

    
    
    public Boolean getHasDefaultPaymentProfile() {
        return True;
    }
    
    
    public CustomerPaymentProfile getFirst() {
        
        List<CustomerPaymentProfile> saved = this.customerProfile.getPaymentProfiles();
        
        return null != saved && saved.size() < 1 ? null : saved[0];
    }
	
}