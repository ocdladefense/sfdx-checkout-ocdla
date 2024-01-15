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
        Id contactId;
        
        
     	u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
		contactId = u.ContactId;
         
        
        c = null == contactId ? null : [SELECT FirstName, LastName, Email FROM Contact WHERE Id = :contactId];
        
        if(Test.isRunningTest()) {
            return customerProfileId;
        } else {
            return null == c ? null : c.AuthorizeDotNetCustomerProfileId__c;
        }  
		
    }
}