global without sharing class ClickpdxShoppingCartController extends CommunityController {
	
    Opportunity opp {get; private set;}
    
    Contact defaultContact;
    
    Map<Contact,List<ClickpdxCartItem>> orderLines = new Map<Contact,List<ClickpdxCartItem>>();
    
    public String shoppingCartSummary {get;private set;}
    
    public Boolean isTest {get;private set;}
    
    public Boolean isEmptyOrder {get;private set;}
    
    public Boolean allowManageCart {get;private set;}
    
    public String cartId {get;private set;}
    
    public Boolean getIsEmptyOrder(){
        return this.isEmptyOrder;
    }
    
    public String getCartName(){
        return this.opp.Name;
    }
    
    public String getCartSummary(){
        return this.shoppingCartSummary;
    }
    
    public String getCartTotal(){
        return String.valueOf(this.opp.Amount);
    }
    
    public Map<Contact,List<ClickpdxCartItem>> getOrderLines(){
        return this.orderLines;
    }
    
    public void setDefaults(){
        this.allowManageCart = True;
        this.defaultContact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE AccountId = :OrgOcdla.getGuestCheckoutAccountId() LIMIT 1];
        Map<String,ClickpdxCartItem> cart = new Map<String,ClickpdxCartItem>();
        this.shoppingCartSummary = '';
        this.isEmptyOrder = True;
    } 
    
    public ClickpdxShoppingCartController(ApexPages.StandardController controller){}
    
    public ClickpdxShoppingCartController() {
		Map<String,String> params = ApexPages.CurrentPage().getParameters();
        this.isTest = null != params.get('test') ? True : False;
        
        List<Opportunity> opps = [SELECT Id, Name, Amount, StageName, AccountId, Contact__c FROM Opportunity WHERE Id = :params.get('Id')];
        
        
        if(null == opps || opps.size() < 1){
            setDefaults();
            return;
        } else {
            this.opp = opps[0];
            this.allowManageCart = opps[0].Name != 'Paid Office Membership Renewal';
        }
        
        this.cartId = this.opp.Id;
        
        List<ClickpdxCartItem> theLines = ClickpdxCartItem.loadOpportunityLineItemsFromOpportunityId(this.opp.Id);

        if(null == theLines || theLines.size() < 1) {
            this.isEmptyOrder = True;
            
        } else {
            this.isEmptyOrder = False;

            String otherItemsText = theLines.size() == 2 ? String.valueOf(theLines.size()-1) + ' other item.' : String.valueOf(theLines.size()-1) + ' other items.'; 
            String orderSizeSummary = theLines.size() > 1 ? ' and '+ otherItemsText : '';
            this.shoppingCartSummary = theLines[0].getProductName() + orderSizeSummary;
            
			this.groupShoppingCartLines(theLines);
        }
    }
    
    private void groupShoppingCartLines(List<ClickpdxCartItem> theLines){
        
        List<Id> theContactIds = new List<Id>();
        Map<Id,Contact> orderContacts = new Map<Id,Contact>();
        
        for(ClickpdxCartItem line :theLines){
            if(null == line.contactId) continue;
            theContactIds.add(line.contactId);
        }
        
        orderContacts.putAll(new Map<Id,Contact>([SELECT Id, Name, FirstName, LastName FROM Contact WHERE Id = :theContactIds]));
        
        for(ClickpdxCartItem line :theLines){
            Contact c = null == orderContacts.get(line.contactId) ? this.defaultContact : orderContacts.get(line.contactId);
            
        	if(orderLines.get(c) == null){
                orderLines.put(c,new List<ClickpdxCartItem>{line});
            } else { 
                orderLines.get(c).add(line);
            }
        }
    }
    
}