public class CurrentCustomer {

    private static String customerProfileId;
    
    
    
    
    public static void setCustomerProfileId(String profileId) {
        customerProfileId = profileId;
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
}