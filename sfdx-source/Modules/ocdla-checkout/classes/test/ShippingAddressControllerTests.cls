@isTest
public class ShippingAddressControllerTests {

    

    @testVisible
    private static String customerProfileId = '527262';
    
    
    @isTest
    private static void createShippingAddress() {
        
        AuthorizeDotNetServiceMock mock = new AuthorizeDotNetServiceMock();

        
        List<CustomerPaymentProfile> profiles = getCustomerPaymentProfileList();
        List<AuthNetAddress> shipToList = getShippingAddressList();
        

        
        CustomerProfile profile = loadSampleCustomerProfile();
		profile.setPaymentProfiles(profiles);
        profile.setShipToList(shipToList);

        if(Test.isRunningTest()) {
            Test.setMock(HttpCalloutMock.class, mock);
        }

        Test.setCurrentPage(Page.PaymentMethod);
		CurrentCustomer.setCustomerProfileId(customerProfileId);
        
        // Test creating a new customer shipping address.
        Map<String,String> params = ApexPages.currentPage().getParameters();
        params.put('action', 'new');

        ShippingMethodController con = new ShippingMethodController();
        con.doCreateAction();
        con.cancel();
    }


    
    @isTest
    private static void editShippingAddress() {
        
        AuthorizeDotNetServiceMock mock = new AuthorizeDotNetServiceMock();
        
        List<CustomerPaymentProfile> profiles = getCustomerPaymentProfileList();
        List<AuthNetAddress> shipToList = getShippingAddressList();
        

        
        CustomerProfile profile = loadSampleCustomerProfile();
		profile.setPaymentProfiles(profiles);
        profile.setShipToList(shipToList);

        
        if(Test.isRunningTest()) {
            Test.setMock(HttpCalloutMock.class, mock);
        }

        Test.setCurrentPage(Page.PaymentMethod);
		CurrentCustomer.setCustomerProfileId(customerProfileId);
        
        // Test editing an existing customer shipping address.
        Map<String,String> params = ApexPages.currentPage().getParameters();
        params.put('action', 'edit');
		params.put('customerAddressId', shipToList[0].getCustomerAddressId());

        // Make some changes to the address that will be saved.
        ShippingMethodController con = new ShippingMethodController();
        con.shipTo.address = '123 My Lane';
        con.shipTo.zip = '97330';
        
        // Commit the changes.
        con.doUpdateAction();
    }
    
      
    
    @testVisible
    private static CustomerProfile loadSampleCustomerProfile() {
        
        Map<String,String> data = new Map<String,String>();
        data.put('profileType', CustomerProfile.CUSTOMER_TYPE_INDIVIDUAL);
        data.put('customerProfileId', CurrentCustomer.getCustomerProfileId());
        data.put('merchantCustomerId', 'idFromContact');
        data.put('description', 'Salesforce customer.');
        data.put('email', 'jbernal.web.dev@gmail.com');
         
        String init = JSON.serialize(data);
        
        return (CustomerProfile)JSON.deserialize(init, CustomerProfile.class);   
    }

    
    
    @isTest
    private static void listSavedShippingAddresses() {
        
        CheckoutServiceMock mock = new CheckoutServiceMock();
        
        List<CustomerPaymentProfile> profiles = getCustomerPaymentProfileList();
        List<AuthNetAddress> shipToList = getShippingAddressList();
        
		CurrentCustomer.setCustomerProfileId(customerProfileId);
        
        CustomerProfile profile = loadSampleCustomerProfile();
		profile.setPaymentProfiles(profiles);
        profile.setShipToList(shipToList);

        
        mock.addCustomerProfile(profile);
            
        
        if(Test.isRunningTest()) {
            Test.setMock(HttpCalloutMock.class, mock);
        }

        Test.setCurrentPage(Page.SavedShippingAddresses);
        
        SavedShippingAddressesController con = new SavedShippingAddressesController();
        
        Map<String,String> params = ApexPages.currentPage().getParameters();
		params.put('customerAddressId', shipToList[0].getCustomerAddressId());
        
        con.setShippingMethod();
        con.editThisAddress();
        con.deleteThisAddress();
    }


 
        

    
    
	@testVisible
    private static List<AuthNetAddress> getShippingAddressList() {
        List<AuthNetAddress> addresses = new List<AuthNetAddress>();
        
        AuthNetAddress addy1 = new AuthNetAddress('Jose', 'Bernal', '118 NW Jackson Ave.', 'Corvallis', 'OR', '97330');
        AuthNetAddress addy2 = new AuthNetAddress('Jose', 'Bernal', '118 NW Jackson Ave.', 'Corvallis', 'OR', '97330');
        
        addy1.setCustomerAddressId('123');
        addy2.setCustomerAddressId('124');
        
        return new List<AuthNetAddress>{addy1, addy2};
    }
    
    
    
    @testVisible
    private static List<CustomerPaymentProfile> getCustomerPaymentProfileList() {
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