global without sharing class OcdlaCheckoutController extends CommunityController {
	
    public static Id GUEST_CHECKOUT_ACCOUNT_ID;

    public Contact customer {get; private set;}
    
    Opportunity opp {get; private set;}
    
    Order order {get; private set;}


      

      
    public Boolean isLoggedIn {get; private set;}
    
    public String shoppingCartSummary {get;private set;}
    
    public String cartId {get; public set;}
    
    public Boolean isFreeCart {get;private set;}
    
    public Boolean hasShippableProducts {get {return hasShippableProducts(this.cartId);}private set;}
    
    public Boolean renderPayment {get;private set;}

    public Boolean isPaid {get;private set;} 
  

    // Stores the CustomerPaymentProfile objects.
    // Never used directly on the checkout page.
    // Instead the customer uses the related SelectOption (or otherwise manages them through a separate controller).
	private CustomerPaymentProfileCollection paymentProfiles;
    
    public List<SelectOption> savedPaymentProfileOptions {get; private set;}
    
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
		Id cartId = params.get('id') != null ? params.get('id') : '0060500000CtPBoAAN';

        try {
        	this.opp = [SELECT Id, Name, Amount, StageName, AccountId, Contact__c, Pricebook2Id FROM Opportunity WHERE Id = :this.cartId];
        } catch(System.SObjectException e) {
            // ApexPages.
        }
        

        
        String customerProfileId = '916376196';
		this.customerProfile = getCustomerProfile(customerProfileId);


        
        
        // Why do we need to check if Sandbox.  Could be legit, but let's find out the *why!
        // this.isSandbox = isSandbox();

        
        this.isPaid = this.opp.StageName == 'Closed Won';
        
        this.isFreeCart = !(this.opp.Amount > 0.00);
        
        this.hasShippableProducts = False;
        
        this.renderPayment = !this.isPaid ? True : False;
    }


    
    public List<CustomerPaymentProfile> getPaymentProfiles() {
        
        // System.debug('PAYMENTS:');
        this.paymentProfiles = new CustomerPaymentProfileCollection(this.customerProfile.getPaymentProfiles());

  
        
		this.savedPaymentProfileOptions = this.getSavedPaymentProfileOptions();
        
        if(this.paymentProfiles.size() > 0) {
            this.selectedPaymentProfile = this.paymentProfiles.getDefault();
        } else {
            throw new CheckoutException('No payment profiles found for.');
        }

		return null;
    }
    
    
    
    public List<AuthNetAddress> getShippingAddresses() {
		AuthNetAddressCollection shipToList = new AuthNetAddressCollection(this.customerProfile.getShipToList()); 
        
        if(shipToList.size() > 0) {
            this.shipTo = shipToList.getDefault();
        } else {
            throw new CheckoutException('No shipping profiles found.');
        }
        
        return null;
    }
    
    
    
    public static CustomerProfile getCustomerProfile(String customerProfileId) {
        
        AuthorizeDotNetClient client = new AuthorizeDotNetClient();
        
        GetCustomerProfileRequest req = new GetCustomerProfileRequest();
        req.setCustomerProfileId(customerProfileId);

        GetCustomerProfileResponse resp = (GetCustomerProfileResponse)client.send(req);
        
        return resp.getProfile();
    }    
    
    
    
    public AuthNetAddress getDefaultBillingAddress() {
        
        return new AuthNetAddress(customer.FirstName, customer.LastName, '123 Monroe Ave.', 'Corvallis', 'OR', '97443');
    }
    
    public AuthNetAddress getDefaultShippingAddress() {
        
        return new AuthNetAddress(customer.FirstName, customer.LastName, '123 Monroe Ave.', 'Corvallis', 'OR', '97443');
    }
      
    public List<SelectOption> getSavedPaymentProfileOptions() {

		System.debug(this.paymentProfiles);
        
		List<SelectOption> options = new List<SelectOption>();

        
        List<CustomerPaymentProfile> profiles = this.paymentProfiles.getAsList();
        
        for(CustomerPaymentProfile profile : profiles) {
            SelectOption option = profile.toSelectOption();
            	
            options.add(option);
        }
        
		options.add(new SelectOption('',' New Card'));
   
		return options;
}
    
    
    
    public Boolean getRenderPayment(){
        return this.renderPayment;
    }
    
    public Boolean getIsPaid(){
        return this.IsPaid;
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
        this.customer.AccountId = getGuestCheckoutAccountId();
        upsert this.customer;
        
        // Guest customer now has an Id, which we want to associate with the underlying Opportunity.
        attachAccount(this.customer, this.cartId);
        
        
        // Reading documentation to figure out how to redirect.
        // return Page.Whatever (where Whatever is the name of the next page in the "flow");
        nextPage.setRedirect(False);
        return nextPage;
    }

    
   
    
    /*
    private List<SelectOption> getStateOptions() {
        return States.getAsSelectOptions();
    }
*/

    

    
    


 
    
    


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
    
        
    public String getCartName(){
        return this.opp.Name;
    }
    
    public String getCartSummary(){
        return this.shoppingCartSummary;
    }
    
    public String getCartTotal(){
        return String.valueOf(this.opp.Amount);
    }
    
    public String getOrderEmail(){
        Boolean isGuestAccount = False;
        String email = this.customer.Email;
        
        return email;
    }

    
    public Contact getLoggedInUserData(string customerId) {
        // will return the contact object of the logged in user, see checkOrderEmail return below
        // because it's a static function we can't use class variables like billToContact
        // UserInfo may be tied to the class and possibly not usable in static functions
        // we will have another function to get the saved CCs after getting the logged in user
        Contact c = [SELECT FirstName, LastName, Email, MailingStreet, MailingPostalCode, MailingCity, Ocdla_Address_Line_1__c, 
                          Ocdla_Address_Line_2__c, MailingStateCode, AccountId, Account.Name FROM Contact WHERE Id = :customerId];
        
        // could probably add a check here to make sure the contact isn't empty or something
        
        return c;
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
        
        
        
        
        Contact guest = new Contact(AccountId = getGuestCheckoutAccountId(), 
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

    
    
    private static Id getGuestCheckoutAccountId(){
        if(null != GUEST_CHECKOUT_ACCOUNT_ID) return GUEST_CHECKOUT_ACCOUNT_ID;
        Account a = [SELECT Id, Name FROM Account WHERE NAME LIKE '%Guest Checkout%' LIMIT 1];
        GUEST_CHECKOUT_ACCOUNT_ID = a.Id;
        return GUEST_CHECKOUT_ACCOUNT_ID;
    }
  
    private static Boolean isSandbox(){
        Organization myOrg = [SELECT Id, IsSandbox FROM Organization WHERE Id = :UserInfo.getOrganizationId()];
        
        return myOrg.IsSandbox;
    }
	
}