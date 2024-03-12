public class CurrentCustomer {

    private static String customerProfileId;
    
    private static Id GUEST_CHECKOUT_ACCOUNT_ID;
    
    
    public static void setCustomerProfileId(String profileId) {
        customerProfileId = profileId;
    }
    
    
    public static Id getGuestCheckoutAccountId() {
        if(null != GUEST_CHECKOUT_ACCOUNT_ID) return GUEST_CHECKOUT_ACCOUNT_ID;
        Account a = [SELECT Id, Name FROM Account WHERE NAME LIKE '%Guest Checkout%' LIMIT 1];
        GUEST_CHECKOUT_ACCOUNT_ID = a.Id;
        
        return GUEST_CHECKOUT_ACCOUNT_ID;
    }
    
    
    public static Boolean isSandbox(){
        Organization myOrg = [SELECT Id, IsSandbox FROM Organization WHERE Id = :UserInfo.getOrganizationId()];
        
        return myOrg.IsSandbox;
    }
    
    
    public static String formatAddress(AuthNetAddress addy) {
        
        String format = '{0} {1}<br />{2} {3}';
        
	
        
        List<String> parts = new List<String>();
        parts.add(addy.firstName);
        parts.add(addy.lastName);
        parts.add(addy.address);
        parts.add(addy.city);
        
        return String.format(format,parts);
    }
    
    
    
    public static Contact getLoggedInUserData(String customerId) {
        // will return the contact object of the logged in user, see checkOrderEmail return below
        // because it's a static function we can't use class variables like billToContact
        // UserInfo may be tied to the class and possibly not usable in static functions
        // we will have another function to get the saved CCs after getting the logged in user
        Contact c = [SELECT FirstName, LastName, Email, MailingStreet, MailingPostalCode, MailingCity, Ocdla_Address_Line_1__c, 
                          Ocdla_Address_Line_2__c, MailingStateCode, AccountId, Account.Name FROM Contact WHERE Id = :customerId];
        
        // could probably add a check here to make sure the contact isn't empty or something
        
        return c;
    }
    
    public static Contact getCustomerContact() {
     	   
        return getLoggedInUserData(getCustomerId());
    }
        
    
    /**
     * Return the AuthorizeDotNet CustomerProfileId associated with the 
     *  currently logged-in User.  This should be saved as Contact.AuthorizeDotNetCustomerProfileId__c.
     */
	public static String getCustomerProfileId() {
        
        // Current user.
        User u;
        
        // Current contact.
        Contact c;
        
        // Contact Id associated with the current User.
        Id contactId = getCustomerId(UserInfo.getUserId());
         
        if(null != contactId) {
			c = [SELECT Id, AuthorizeDotNetCustomerProfileId__c, FirstName, LastName, Email FROM Contact WHERE Id = :contactId];
            if(null == c) {
				throw new CheckoutException('INVALID_CUSTOMER_ERROR: Cannot find related contact ('+contactId+').');
            }
        } else {
            c = null;
        }
        
        // In a test context, return a previously-defined customerProfileId value.
        if(Test.isRunningTest()) {
            return customerProfileId;
        } else {
            return null == c ? null : c.AuthorizeDotNetCustomerProfileId__c;
        }  
		
    }
                                                     
	@testVisible                                         
	private static Id getCustomerId(Id userId) {
                                 
		User u = [SELECT Id, LinkedCustomerUser__c, ContactId FROM User WHERE Id = :userId];
        
        return null != u.LinkedCustomerUser__c ? getCustomerId(u.LinkedCustomerUser__c) : u.ContactId;
	}
    
    private static Id getCustomerId() {
        
        return getCustomerId(UserInfo.getUserId());
    }
    

    public static CustomerProfile getCustomerProfile() {
        String customerProfileId = CurrentCustomer.getCustomerProfileId();   
        
        return getCustomerProfile(customerProfileId);
    }
    
    
    public List<CustomerPaymentProfile> getPaymentProfiles() {
        /*
        // System.debug('PAYMENTS:');
        CustomerPaymentProfileCollection paymentProfiles = new CustomerPaymentProfileCollection(this.customerProfile.getPaymentProfiles());


        
        if(paymentProfiles.size() > 0) {
        	PaymentProfile selectedPaymentProfile = this.paymentProfiles.getDefault();
        } else {
            throw new CheckoutException('No payment profiles found for.');
        }
	*/
		return null;
    }
    
    
    public static CustomerProfile getCustomerProfile(String customerProfileId) {
 
        AuthorizeDotNetClient client = new AuthorizeDotNetClient();

        GetCustomerProfileRequest req = new GetCustomerProfileRequest();
        req.setCustomerProfileId(customerProfileId);

        GetCustomerProfileResponse resp = (GetCustomerProfileResponse)client.send(req);
        
        return resp.success() ? resp.getProfile() : null;
    }
}