public with sharing class SavedShippingAddressesController extends CommunityController {


    public List<AuthNetAddress> shipToList {get; set;}

    
    public String defaultShippingAddressId {get; set;}
   
    
    
    
    
    
    public SavedShippingAddressesController() {
        super('CheckoutCommunityConfig');
        
        
        AuthorizeDotNetClient client = new AuthorizeDotNetClient();
     
        String customerProfileId = CurrentCustomer.getCustomerProfileId();


        CustomerProfile theProfile = CurrentCustomer.getCustomerProfile();

        if(theProfile == null) {
            throw new CheckoutException('GATEWAY_STATE_ERROR: No customer profile found in this context.');
        }

        AuthNetAddressCollection theCollection = theProfile.getShipToCollection();
  
        //use collection's getDefault method to get the default
        AuthNetAddress theAddress = theCollection.getDefault();
        this.defaultShippingAddressId = null == theAddress ? null : theAddress.getCustomerAddressId();

        this.shipToList = theCollection.getAsList();   
    }


    

    public PageReference setShippingMethod() {
        Map<String,String> params = ApexPages.currentPage().getParameters();
        String action = params.get('action');
        String customerAddressId = params.get('customerAddressId');


        Pagereference redirect = new PageReference('/ShippingMethod');
        redirect.getParameters().putAll(params);
        redirect.setRedirect(True);

        return redirect;
    }
    
    
    // Used when the customer clickes "edit"
    // for a given address.
    public PageReference editThisAddress() {
        
        String customerAddressId = Apexpages.currentPage().getParameters().get('customerAddressId');

        Boolean isEdit = customerAddressId != null;
        
        PageReference redirect = isEdit ? new PageReference('/ShippingMethod') : new PageReference('/AddShippingAddress');

        if(isEdit) {
            redirect.getParameters().put('customerAddressId', customerAddressId);
            redirect.getParameters().put('action', 'edit');
            redirect.setRedirect(True);
        }
        
        return redirect;
    }
    
    

    public PageReference deleteThisAddress() {

        AuthorizeDotNetClient client = new AuthorizeDotNetClient();
        

        String customerProfileId = CurrentCustomer.getCustomerProfileId();
        String customerAddressId = Apexpages.currentPage().getParameters().get('customerAddressId');

        DeleteCustomerShippingAddressRequest req = new DeleteCustomerShippingAddressRequest();
        req.setCustomerProfileId(customerProfileId);
        req.setCustomerAddressId(customerAddressId);



        AuthorizeDotNetResponse resp = (AuthorizeDotNetResponse)client.send(req);
        Messages messages = resp.getMessages();
        Message message = messages.getFirstMessage();
        
        String errorText = 'API_ERROR: ' + message.getText();
        
        if(!resp.success()) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.WARNING, errorText));
        }
        
        
        return resp.success() ? new Pagereference(ApexPages.currentPage().getUrl()).setRedirect(True) : null;
    }
    
    
    
    public PageReference doCreateShippingAddress() {
        PageReference redirect = new PageReference('/ShippingMethod');
        
        Map<String,String> params = new Map<String,String>{'action' => 'new'};

        redirect.getParameters().putAll(params);

        return redirect;
    }

    
    
    public PageReference redirectToSavedShippingAddresses() {
        return new Pagereference('/SavedShippingAddresses');
    }

}