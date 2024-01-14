public class SavedPaymentMethodsController extends CommunityController {
    
    private AuthorizeDotNetClient client;

    private String customerProfileId;

    public Contact c {get; set;}

    public AuthNetAddress billingInfo {get; set;}

    public Payment paymentInfo {get; set;}

    public Boolean isDefaultPaymentMethod {get; set;}

    public CustomerProfile customerProfile {public get; private set;}

    transient private List<CustomerPaymentProfile> paymentProfiles;
    
    private CustomerPaymentProfileCollection paymentProfileCollection;    
    
 

    public SavedPaymentMethodsController() {  
        super('CheckoutCommunityConfig');
        billingInfo = new AuthNetAddress();
        paymentInfo = new Payment();
        Boolean useMock = False;
        

        client = new AuthorizeDotNetClient();
        
        paymentProfiles = new List<CustomerPaymentProfile>();
        // pretend that logged in users Authorize.net customer profile id is called.
        customerProfileId = CurrentCustomer.getCustomerProfileId();
        

        GetCustomerProfileRequest req = new GetCustomerProfileRequest();
        req.setCustomerProfileId(customerProfileId);

        GetCustomerProfileResponse resp = (GetCustomerProfileResponse)client.send(req);
        this.customerProfile = resp.getProfile();
        this.paymentProfiles = this.customerProfile.getPaymentProfiles();
        this.paymentProfileCollection = new CustomerPaymentProfileCollection(this.paymentProfiles);
    }

    
    public Pagereference setDefaultPaymentProfile() {
        
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

        Pagereference PaymentMethodPage = new PageReference('/PaymentMethod');
        PaymentMethodPage.setRedirect(true);
        PaymentMethodPage.getParameters().put('action', action);
        PaymentMethodPage.getParameters().put('paymentProfileId', selectedPaymentProfileId);

        return PaymentMethodPage;
    }
    

}