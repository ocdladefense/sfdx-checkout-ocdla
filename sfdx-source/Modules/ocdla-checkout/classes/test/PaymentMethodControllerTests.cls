@isTest
public class PaymentMethodControllerTests {
  
    @isTest
    private static void loadRecordController() {
        
        AuthorizeDotNetServiceMock mock = new AuthorizeDotNetServiceMock();
        List<CustomerPaymentProfile> profiles = sampleCustomerPaymentProfileList();
        
		CurrentCustomer.setCustomerProfileId('527262');
        
        Map<String,String> data = new Map<String,String>();
        data.put('profileType', 'regular');
        data.put('customerProfileId', '527262');
        data.put('merchantCustomerId', 'sforceContactId');
        data.put('descriptiion', 'Customer description');
        data.put('email', 'jbernal.web.dev@gmail.com');
         
        String init = JSON.serialize(data);
        
        CustomerProfile profile = (CustomerProfile)JSON.deserialize(init, CustomerProfile.class);        
		profile.setPaymentProfiles(profiles);

        
        // mock.addCustomerProfile(profile);
            
        
        if (Test.isRunningTest()){
            Test.setMock(HttpCalloutMock.class, mock);
        }

        Test.setCurrentPage(Page.PaymentMethod);
        


        
        Map<String,String> params = ApexPages.currentPage().getParameters();
		params.put('paymentProfileId', '905264263');
        params.put('action', 'new');

         
        PaymentMethodController con = new PaymentMethodController();
        
        params.put('action', 'edit');
		con = new PaymentMethodController();
        
        con.doEditAction();
        con.doCreateAction();
        con.cancel();

        con.getTemplate();
        con.getConfig();
    }
    
    
    
    @isTest
    private static void loadListController() {
        
        CheckoutServiceMock mock = new CheckoutServiceMock();
        List<CustomerPaymentProfile> profiles = sampleCustomerPaymentProfileList();
        
		CurrentCustomer.setCustomerProfileId('527262');
        
        Map<String,String> data = new Map<String,String>();
        data.put('profileType', 'regular');
        data.put('customerProfileId', '527262');
        data.put('merchantCustomerId', 'sforceContactId');
        data.put('descriptiion', 'Customer description');
        data.put('email', 'jbernal.web.dev@gmail.com');
         
        String init = JSON.serialize(data);
        
        CustomerProfile profile = (CustomerProfile)JSON.deserialize(init, CustomerProfile.class);        
		profile.setPaymentProfiles(profiles);

        
        mock.addCustomerProfile(profile);
            
        
        if (Test.isRunningTest()){
            Test.setMock(HttpCalloutMock.class, mock);
        }

        Test.setCurrentPage(Page.SavedPaymentMethods);
        
        SavedPaymentMethodsController con = new SavedPaymentMethodsController();
        con.getPaymentProfiles();
        
        Map<String,String> params = ApexPages.currentPage().getParameters();
		params.put('paymentProfileId', '905264263');
        
        con.setDefaultPaymentProfile();
        con.redirectToPaymentMethod();
        con.deletePaymentProfile();
    }
    
    
    
    // Test method
    public static List<CustomerPaymentProfile> sampleCustomerPaymentProfileList(){
        List<CustomerPaymentProfile> profiles = new List<CustomerPaymentProfile>();

        //default valid Visa card
        String customerPaymentProfileId2 ='905264263';
        CreditCard card2 = new CreditCard('4444111144441111', '2025-11');
        AuthNetAddress billToAddress2 = new AuthNetAddress('Testy', 'Tester', 'blah 123', 'Springfield', 'OR', '97477');
        CustomerPaymentProfile profile2 = new CustomerPaymentProfile(card2, billToAddress2);
        profile2.setCustomerPaymentProfileId(customerPaymentProfileId2);
        profile2.setDefaultPaymentProfile(true);

        //valid Mastercard card
        String customerPaymentProfileId3 ='905264264';
        CreditCard card3 = new CreditCard('5555111144441111', '2027-02');
        AuthNetAddress billToAddress3 = new AuthNetAddress('Testy', 'Tester', 'blah 123', 'eugene', 'OR', '97477');
        CustomerPaymentProfile profile3 = new CustomerPaymentProfile(card3, billToAddress3);
        profile3.setCustomerPaymentProfileId(customerPaymentProfileId3);
        profile3.setDefaultPaymentProfile(false);

        //valid card number and type expired 

        String customerPaymentProfileId4 ='905264265';
        CreditCard card4 = new CreditCard('5544111155559999', '2023-06');
        AuthNetAddress billToAddress4 = new AuthNetAddress('Testy', 'Tester', 'office park 123', 'Eugene', 'OR', '97454');
        CustomerPaymentProfile profile4 = new CustomerPaymentProfile(card4, billToAddress4);
        profile3.setCustomerPaymentProfileId(customerPaymentProfileId3);
        profile3.setDefaultPaymentProfile(false);

        //add to list
        profiles.add(profile2);
        profiles.add(profile3);
        profiles.add(profile4);
        
        //return list
        return profiles;
    } 
}