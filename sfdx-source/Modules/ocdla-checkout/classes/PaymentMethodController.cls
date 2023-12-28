public class PaymentMethodController extends CommunityController {
    


    public String customerProfileId {public get; private set;}
    
    public String paymentProfileId {public get; private set;}

    public Contact c {get; set;}

    public AuthNetAddress billTo {get; set;}

    public CreditCard card {get; set;}

    public Boolean isDefaultPaymentMethod {get; set;}

    public String title {get; private set;}

    public String action {get; private set;}
    
    
    
   
    public PaymentMethodController() {
        super('CheckoutCommunityConfig');
        
        Map<String,String> params = ApexPages.currentPage().getParameters();
        this.action = params.get('action');
        
        // Only provided when editing.
        paymentProfileId = params.get('paymentProfileId');
        
        // Testing id.
        customerProfileId = CurrentCustomer.getCustomerProfileId();
       
        CustomerPaymentProfile p = action == 'new' ? new CustomerPaymentProfile() : doLoadAction(customerProfileId, paymentProfileId);

        billTo = action == 'new' ? new AuthNetAddress() : p.getBillTo();
        card = action == 'new' ? new CreditCard() : p.getCard();

        
		title = action == 'new' ? 'New Payment Method' : 'Edit Payment Method';
    }
    
    
    
    
    public static CustomerPaymentProfile doLoadAction(String customerProfileId, String paymentProfileId) {
        
	    AuthorizeDotNetClient client = new AuthorizeDotNetClient();
        
        GetCustomerPaymentProfileRequest req = new GetCustomerPaymentProfileRequest();
        req.setCustomerPaymentProfileId(paymentProfileId);
        req.setCustomerProfileId(customerProfileId);

        GetCustomerPaymentProfileResponse resp = (GetCustomerPaymentProfileResponse)client.send(req);
        System.debug(resp.getBody());
        
        return resp.getPaymentProfile();
    }
    
 


    // Calls CreatePaymentProfile
    
    public Pagereference doCreateAction() {

        AuthorizeDotNetClient client = new AuthorizeDotNetClient();
        
        CustomerPaymentProfile p = new CustomerPaymentProfile(card, billTo);
        p.setDefaultPaymentProfile(isDefaultPaymentMethod);

        CreateCustomerPaymentProfileRequest req = new CreateCustomerPaymentProfileRequest(p);
        req.setCustomerProfileId(customerProfileId);

        System.debug('Add controller req.getBody' + req.getBody());

        CreateCustomerPaymentProfileResponse resp = (CreateCustomerPaymentProfileResponse)client.send(req);

        System.debug(resp.success());

        return new PageReference('/SavedPaymentMethods');
    }
    

    

    public Pagereference doEditAction() {

        AuthorizeDotNetClient client = new AuthorizeDotNetClient();

        CustomerPaymentProfile p = new CustomerPaymentProfile();
        p.setBillTo(billTo);
        p.setCard(card);

        //request
        UpdateCustomerPaymentProfileRequest req = new UpdateCustomerPaymentProfileRequest(p);
        req.setCustomerProfileId(customerProfileId);
        req.setCustomerPaymentProfileId(paymentProfileId);
        req.setIsDefault(true);
        
        
        System.debug('XXXX- Payment profile id');
        System.debug(p.getCustomerPaymentProfileId());
        System.debug('XXXX - Payment profile keySet...');
        System.debug(p.keySet());
        System.debug('XXXX - Update request body...');
        System.debug(req.getBody());

        UpdateCustomerPaymentProfileResponse resp = (UpdateCustomerPaymentProfileResponse)client.send(req);
        System.debug(resp.getBody());
        
        // ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'my error msg');
        // 
        // 
        if(!resp.success()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'There was an error.'));
        }

        return resp.success() ? new PageReference('/SavedPaymentMethods') : null;
    }

    
    
    public PageReference cancel() {
        return new PageReference('/SavedPaymentMethods');
    }

}