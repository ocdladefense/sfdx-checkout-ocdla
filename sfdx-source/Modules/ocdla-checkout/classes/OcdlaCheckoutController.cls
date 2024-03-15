public without sharing class OcdlaCheckoutController extends CommunityController {
    
    
    // The loaded Shopping cart for this customer.
    private CartContainer cart {get; set;}
    
    // The loaded Shopping cart for this customer.
    private Id cartId {get {return this.cart.getId();} private set;}

    
    // The current customer for this Shopping cart.
    public Contact customer {get; private set;}
    
    
    // Order would be produced on successful transaction.
    // Otherwise we would ideally rollback so that the Order is
    // actually not persisted.
    // Order order {get; private set;}

	
    // Whether the current user is a logged in customer.
    // If not then this is the Guest user.
    public Boolean isLoggedIn {get; private set;}
    
    
    // A summary of this Shopping cart's items.
    public String shoppingCartSummary {get;private set;}
    

    // If the Amount of the Opportunity is $0.00 then it is considered free.
    public Boolean isFreeCart {get;private set;}
    
    
    // Boolean indicating whether the Shopping cart contains
    // any shippable products.
    public Boolean hasShippableProducts {get {return this.cart.hasShippableProducts();} private set;}

    
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
		Id cartId = params.get('id');
        
        if(null == cartId) {
            throw new CheckoutException('CHECKOUT_INIT_ERROR: No valid cartId provided (NULL).');
        }

        
        this.cart = new CartContainer(this.cartId);
        

        // Pulled from Authorize dot net 3/9/2024.
        String customerProfileId = '905372692';
        
        this.customer = CurrentCustomer.getCustomerContact();
        
		this.customerProfile = CurrentCustomer.getCustomerProfile('905372692');
		System.debug(this.customerProfile);
        System.debug(this.customerProfile.getPaymentProfiles());
        // Why do we need to check if Sandbox.  Could be legit, but let's find out the *why!
        // this.isSandbox = CurrentCustomer.isSandbox();

        this.hasShippableProducts = False;
        
        this.isPaid = (String)this.cart.get('StageName') == 'Closed Won';
        
        this.isFreeCart = !((Decimal)this.cart.get('Amount') > 0.00);
                
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
    
        
    public String getCartName() {
        return (String)this.cart.get('Name');
    }
    
    
    public String getCartTotal() {
        return String.valueOf(this.cart.get('Amount'));
    }
    
    
    public String getOrderEmail() {

        return this.customer.Email;
    }


    
    public PageReference submitPayment() {

        Boolean processedPayment = True;
        Boolean hasErrors = False;
        AuthorizeDotNetResponse resp;
        OrderContainer ordr;
        
        
        // Creates guest contact, attaches to opportunity, inserts contact, then updates opportunity all in one go
        // customer = ClickpdxCheckoutGuestController.generateGuestCheckoutContact(customer, this.cartId);
        // this.customer.AccountId = CurrentCustomer.getGuestCheckoutAccountId();
        // upsert this.customer;
        
        // Guest customer now has an Id, which we want to associate with the underlying Opportunity.
        // this.cart.attachAccount(this.customer);
        
        
        try {
                

            
            AuthNetTransaction tx = new AuthNetTransaction(40.00);
            tx.payWith('4111111111111111','10/2027');

            CreateTransactionRequest req = new CreateTransactionRequest(tx);
    
            AuthorizeDotNetClient client = new AuthorizeDotNetClient();
            
            resp = client.send(req);
			System.debug('AUTH_NET_CLIENT_RESPONSE_RECEIVED');
            System.debug(resp.getBody());
            
			processedPayment = resp.success();
            
        } catch(Exception e) {
            
            hasErrors = True;
	        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, e.getMessage()));
        }
            
        
        this.cart.put('Contact__c', CurrentCustomer.getCustomerId());
        this.cart.save();
        

        	
        ordr = OrderContainer.newFromShoppingCart(this.cartId);
        // OrderContainer.draftOrderFromShoppingCart(this.cart.Id);
        Id orderId = ordr.save();
           
        SavePoint sp = Database.setSavePoint();
	
        try {
                
	        // Make a payment using AuthorizeDotNetApi.
            if(processedPayment) {
                
                ordr.put('Status', 'Posted Payment');
                ordr.put('Payment_Info__c', resp.getBody());
                ordr.put('Origin__c', 'Web Order');
	            // OrderContainer.activateOrder(orderId);
                ordr.save();
                
                this.cart.put('StageName', 'Closed Won');
                this.cart.save();
                        
                PageReference nextPage = Page.OrderConfirmation;
                Map<String,String> params = nextPage.getParameters();
        
                params.put('id', ordr.getId());
                
                // Reading documentation to figure out how to redirect.
                // return Page.Whatever (where Whatever is the name of the next page in the "flow");
                nextPage.setRedirect(True);
                
                return nextPage;  
            }
            // If successful 
        } catch(Exception e) {
            
            hasErrors = True;
            // Rollback if issue. 
            Database.rollback(sp);
	        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, e.getMessage()));
        }
        

    
    
		return null;
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