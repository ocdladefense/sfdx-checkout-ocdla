public class SavedPaymentMethodsController extends CommunityController {
    


    private String customerProfileId;

    public Contact c {get; set;}

    public AuthNetAddress billingInfo {get; set;}

    public Boolean isDefaultPaymentMethod {get; set;}

    public CustomerProfile customerProfile {public get; private set;}

    transient private List<CustomerPaymentProfile> paymentProfiles;
    
    private CustomerPaymentProfileCollection paymentProfileCollection;    
    
    
    
 

    public SavedPaymentMethodsController() {  
        super('CheckoutCommunityConfig');
        
        billingInfo = new AuthNetAddress();
        paymentProfiles = new List<CustomerPaymentProfile>();
        
        this.customerProfile = CurrentCustomer.getCustomerProfile();
        this.paymentProfiles = this.customerProfile.getPaymentProfiles();
        this.paymentProfileCollection = new CustomerPaymentProfileCollection(this.paymentProfiles);
    }

    
    public Pagereference setDefaultPaymentProfile() {
        
        AuthorizeDotNetClient client = new AuthorizeDotNetClient();
        
        Map<String,String> params = ApexPages.currentPage().getParameters();
        String paymentProfileId = params.get('paymentProfileId');
        
        // Gets a paymentProfile from the paymentProfileCollection by paymentProfileId
        CustomerPaymentProfile selected = this.paymentProfileCollection.get(paymentProfileId);
        selected.setDefault();
        
        UpdateCustomerPaymentProfileRequest req = new UpdateCustomerPaymentProfileRequest(selected);
        req.setCustomerProfileId(this.customerProfileId);

        UpdateCustomerPaymentProfileResponse resp = (UpdateCustomerPaymentProfileResponse)client.send(req);
        
        return null;
    }
    
    
    
    public List<CustomerPaymentProfile> getPaymentProfiles() {
        return this.paymentProfileCollection.getAsList();
    }
    
    

    public void deletePaymentProfile() {
        AuthorizeDotNetClient client = new AuthorizeDotNetClient();
        
        Map<String,String> params = ApexPages.currentPage().getParameters();
        String selectedPaymentProfileId = params.get('paymentProfileId');

        DeleteCustomerPaymentProfileRequest req = new DeleteCustomerPaymentProfileRequest();
        req.setCustomerProfileId(customerProfileId);
        req.setCustomerPaymentProfileId(selectedPaymentProfileId);

        DeleteCustomerPaymentProfileResponse resp = (DeleteCustomerPaymentProfileResponse)client.send(req);
    }

    
    
    public Pagereference redirectToPaymentMethod() {
        Map<String,String> params = ApexPages.currentPage().getParameters();
        String action = params.get('action');
        String selectedPaymentProfileId = params.get('paymentProfileId');

        Pagereference redirect = new PageReference('/PaymentMethod');
        redirect.setRedirect(True);
        redirect.getParameters().put('action', action);
        redirect.getParameters().put('paymentProfileId', selectedPaymentProfileId);

        return redirect;
    }
    

}