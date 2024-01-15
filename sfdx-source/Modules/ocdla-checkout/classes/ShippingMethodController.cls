public with sharing class ShippingMethodController extends CommunityController {
    
    


    public String customerProfileId {get; set;}

    public AuthNetAddress shipTo {get; set;}

    public Boolean defaultShippingAddress {get; set;}

    public String title {get; private set;}

    public String action {get; set;}

    
    
    
    
    public ShippingMethodController() {
        super('CheckoutCommunityConfig');
        this.customerProfileId = CurrentCustomer.getCustomerProfileId();

        Map<String,String> params = ApexPages.currentPage().getParameters();
        this.action = params.get('action');
        
        String customerAddressId = params.get('customerAddressId');
        


        GetCustomerShippingAddressResponse resp;
        
        if(customerAddressId != null) {
            resp = doLoadAction(customerProfileId, customerAddressId);
        }
    
        this.shipTo = action == 'edit' ? resp.getAddress() : new AuthNetAddress();

        this.title = action == 'edit' ? 'Edit Shipping Address' : 'Add a new shipping address';   
        
        this.defaultShippingAddress = action == 'edit' ? resp.getDefaultShippingAddress() : False;
    }
    
    
    
    /**
     * Load the Customer shipping address (AuthNetAddress) for the specified customerAddressId.
     */
    public static GetCustomerShippingAddressResponse doLoadAction(String customerProfileId, String customerAddressId) {

		AuthorizeDotNetClient client = new AuthorizeDotNetClient();
        
        GetCustomerShippingAddressRequest req = new GetCustomerShippingAddressRequest();
        req.setCustomerAddressId(customerAddressId);
        req.setCustomerProfileId(customerProfileId);
        
        GetCustomerShippingAddressResponse resp = (GetCustomerShippingAddressResponse)client.send(req);

        System.debug(resp.getBody());

        return resp;
    }
    
 
    
    public Pagereference doUpdateAction() {
        
		AuthorizeDotNetClient client = new AuthorizeDotNetClient();
        
        UpdateCustomerShippingAddressRequest req = new UpdateCustomerShippingAddressRequest(shipTo);
        req.setCustomerProfileId(this.customerProfileId);
        req.setDefaultShippingAddress(this.defaultShippingAddress);
        

        UpdateCustomerShippingAddressResponse resp = (UpdateCustomerShippingAddressResponse)client.send(req);


        // Messages messages = resp.getMessages();
        // Message message = messages.getFirstMessage();
        // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Unable to update this address. ' + message.getText()));

        return resp.success() ? new PageReference('/SavedShippingAddresses') : null;
    }



    
    public Pagereference doCreateAction() {
        
        if(String.isEmpty(this.shipTo.zip)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Please enter a zip code.'));
            
            return null;
        }
        
		AuthorizeDotNetClient client = new AuthorizeDotNetClient();
        
        CreateCustomerShippingAddressRequest req = new CreateCustomerShippingAddressRequest(shipTo);
        req.setCustomerProfileId(customerProfileId);
        req.setDefaultShippingAddress(defaultShippingAddress);

        /*
            Messages messages = resp.getMessages();
            Message message = messages.getFirstMessage();
            String messageText = message.getText();
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Unable to add this address. ' + messageText));
            return null;
		*/
        
        CreateCustomerShippingAddressResponse resp = (CreateCustomerShippingAddressResponse)client.send(req);

        if(resp.success()) {
            system.debug('new address id is ' + resp.getCustomerAddressId());
            
        }
        
        return resp.success() ? new PageReference('/SavedShippingAddresses') : null;
    }
    

    
    
    public PageReference cancel() {
        return new PageReference('/SavedShippingAddresses');
    }

}