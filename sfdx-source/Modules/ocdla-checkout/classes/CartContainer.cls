global class CartContainer {

    
    private Id cartId = null;
    
    private Opportunity cart;
    
    private List<OpportunityLineItem> lines;
    
    
    
    public void put(String key, Object val) {
        this.cart.put(key,val);
    }
    
    public Object get(String key) {
        return this.cart.get(key);
    }
    
    
    public CartContainer(Id cartId) {
        this.lines = new List<OpportunityLineItem>();
		this.cart = [SELECT Id, Name, Amount, StageName, AccountId, Contact__c, Pricebook2Id FROM Opportunity WHERE Id = :this.cartId];
    }
    
    
    public Id getId() {
        
        return null;
    }
    
    

    public Boolean hasShippableProducts(){
        List<OpportunityLineItem> lines = [SELECT Id, Product2.IsShippable__c FROM OpportunityLineItem WHERE OpportunityId = :cartId];
        
        for(OpportunityLineItem line :lines){
            if(line.Product2.IsShippable__c) return True;
        }
        
        return False;
    }
    
    
    
    public void attachAccount(Contact c) {
        Id accountId;
        
        // accountId = 
        this.cart.Contact__c = c.Id;
    }


    
    @RemoteAction
    global static List<Contact> checkOrderEmail(String email) {
       String out = email.trim();
        
       Map<String,String> resp = new Map<String,String>();
        
       List<Contact> c = [SELECT FirstName, LastName, Email, MailingStreet, MailingPostalCode, MailingCity, Ocdla_Address_Line_1__c, 
                          Ocdla_Address_Line_2__c, MailingStateCode, AccountId, Account.Name FROM Contact WHERE Email = :out OR OrderApi__Work_Email__c = :out];
       
       return c;
    }

    
    public Id save() {
        upsert this.cart;
        
        for(OpportunityLineItem line :this.lines){
            line.OpportunityId = this.cart.Id;
        }
        
		insert this.lines;
        
        return this.cart.Id;
    }
    
    
    
    public Contact generateGuestCheckoutContact(Contact c, Id oppId) {
        String firstName = c.FirstName;
        String lastName = c.LastName;
        String emails = c.Email;

        Contact guest = new Contact(AccountId = CurrentCustomer.getGuestCheckoutAccountId(), 
                                    FirstName = c.FirstName,
                                    LastName = c.LastName,
                                    Email = c.Email,
                                    OrderApi__Work_Email__c = c.Email);
        
        insert guest;
        this.attachAccount(guest);
        return guest;
 
    }    
    

    

}