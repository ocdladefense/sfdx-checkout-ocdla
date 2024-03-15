public without sharing class OrderContainer {

    
    Id orderId;
    
    List<OrderItem> lines;
    
    Order o;
    
    // The legacy ClickpdxOrder class was probably being 
    // called here.
    public static Boolean TRIGGER_IS_EXECUTING = False;
    
	
    public OrderContainer() {
        Order o = new Order();
        o.Pricebook2Id = ClickpdxCore.Application.config.getStdPriceBookId();
        o.EffectiveDate = System.today();
        o.Status = 'Draft';
        
        this.o = o;
        
        this.lines = new List<OrderItem>();
    }
    
    
    public OrderContainer(Order o) {

        this.o = o;
        
        this.lines = new List<OrderItem>();
    }
    
    public Id getId() {
        
        return this.o.Id;
    }
    
    
    // Originally an alternate constructor.
    public void setAccountId(Id accountId) {
        // this();
        this.o.AccountId = accountId;
    }
    


    
    public static OrderContainer newFromShoppingCart(Id cartId) {

        Opportunity cart = [SELECT Id, AccountId, Pricebook2Id FROM Opportunity WHERE Id = :cartId];
        
        List<Order> related = [SELECT Id, OpportunityId FROM Order WHERE OpportunityId = :cartId LIMIT 1];
        String orderId = null == related ? null : (0 == related.size() ? null : related[0].Id);

        Order o 			= null == orderId ? new Order() : new Order(Id=orderId);
        o.EffectiveDate 	= System.today();
        o.Status 			= 'Attempted Payment';
        o.OpportunityId 	= cart.Id;
        o.AccountId 		= cart.AccountId;
        o.PriceBook2Id 		= cart.Pricebook2Id;
 
        return new OrderContainer(o);
    }
    
    
    
    public void setBillingAddress(Map<String,String> addy) {
        // List of Billing fields to update on the Order.
        
        
        // this.o.BillToContactId = opp.Contact__c;
        this.o.BillingStreet = addy.get('BillingStreet');
        this.o.BillingCity = addy.get('BillingCity');
        this.o.BillingPostalCode = addy.get('BillingPostalCode');
        this.o.BillingStateCode = addy.get('BillingStateCode');
        this.o.BillingCountryCode = 'US';
        // o.CCNumber__c = addy.get('ccNum') == null ? null : addy.get('ccNum').substring(12);
        
    }
    
    public void setShippingAddress(Map<String,String> addy) {
        // List of Shipping fields to update on the Order.
        // o.ShipToContactId = opp.Contact__c;
        this.o.ShippingStreet = addy.get('ShippingStreet');
        this.o.ShippingCity = addy.get('ShippingCity');
        this.o.ShippingStateCode = addy.get('ShippingStateCode');
        this.o.ShippingPostalCode = addy.get('ShippingPostalCode');
		this.o.ShippingCountryCode = 'US';
 
    }
    
    
    public static Id draftOrderFromShoppingCart(Id oppId) {
        Opportunity theOpp = [SELECT Id, Pricebook2Id, AccountId FROM Opportunity WHERE Id = :oppId];
        List<Order> related = [SELECT Id, OpportunityId FROM Order WHERE OpportunityId = :oppId LIMIT 1];
        
        System.debug(theOpp);
        
        Contact c = [SELECT Id, Name, Email FROM Contact where AccountId = :theOpp.AccountId LIMIT 1];
        Order theOrder;
         

        theOrder = new Order();
        theOrder.Id = null == related ? null : (0 == related.size() ? null : related[0].Id);
        theOrder.OpportunityId = oppId;
        theOrder.AccountId = theOpp.AccountId;
        theOrder.BillToContactId = c.Id;
        theOrder.EffectiveDate = System.today();
        theOrder.Status = 'Draft';
        if(null == related || 0 == related.size()){
            theOrder.Pricebook2Id = theOpp.Pricebook2Id;
        }
        
        upsert theOrder;
        
        draftOrderLinesFromShoppingCart(theOrder.Id);
        
        return theOrder.Id;
    }
          
    
    public static Map<Id,Boolean> hasShippableItems(Map<Id,Order> orders){
        Boolean PRODUCT_NEEDS_SHIPPING = True;
        
        List<OrderItem> lines;
        Map<Id,Boolean> isShippableMap = new Map<Id,Boolean>();
        
        for(Id oId :orders.keySet()){
            isShippableMap.put(oId,False); // Start by assuming no Shippable Items.
        }
        
        lines = new List<OrderItem>();
        
        lines.addAll([SELECT Id, OrderId, Product2.IsShippable__c FROM OrderItem WHERE OrderId = :orders.keySet()]);
        
        for(OrderItem line :lines){
            if(line.Product2.IsShippable__c) {
                isShippableMap.put(line.OrderId,PRODUCT_NEEDS_SHIPPING);
            }
        }
        
        return isShippableMap;
    }

    public static void draftOrderLinesFromShoppingCart(Id orderId){
        Order thisOrder;
        List<OrderItem> orderLines;
        Contact c = null;

        thisOrder = null == orderId ? new Order() : [SELECT Id, OpportunityId, BillToContactId, Status FROM Order WHERE Id = :orderId];
            
        if(null != thisOrder && null != thisOrder.BillToContactId){
            c = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :thisOrder.BillToContactId];
        }   
            
        orderLines = [SELECT Id FROM OrderItem WHERE OrderId = :orderId];
        
        if(null != orderLines && orderLines.size() > 0) {
            delete orderLines;
            // Why are we saving the Order if it doesn't have any lines
            //   alternatively, why are we saving the Order if are only nuking it's related Order Products?
            upsert thisOrder;
        }
        


        Map<Id,OpportunityLineItem> cartItems = new Map<Id,OpportunityLineItem>([SELECT Id, Data__c, FirstName__c, LastName__c, Email__c, 
					Quantity, Product2Id, Description, PricebookEntryId, UnitPrice, Contact__c, ParentLineId__c,
					Product2.IsShippable__c FROM OpportunityLineItem
					WHERE OpportunityId = :thisOrder.OpportunityId]);
        
        Map<Id,OrderItem> oppLineItemsToOrderItems = new Map<Id,OrderItem>();
        
        
        for(OpportunityLineItem li :cartItems.values()){
            OrderItem o = new OrderItem();

            o.OrderId = thisOrder.Id;
            o.Quantity = li.Quantity;
            o.Data__c = li.Data__c;
            o.Description = li.Description;
            o.UnitPrice = li.UnitPrice;
            o.Contact__c = li.Contact__c != null ? li.Contact__c : (c == null ? null : c.Id);
            o.FirstName__c = li.FirstName__c != null ? li.FirstName__c : (c == null ? null : c.FirstName);
            o.LastName__c = li.LastName__c != null ? li.LastName__c : (c == null ? null : c.LastName);
			o.Email__c = li.Email__c;
            o.Product2Id = li.Product2Id;
            o.PricebookEntryId = li.PricebookEntryId;
            o.ParentLineId__c = li.ParentLineId__c;
            oppLineItemsToOrderItems.put(li.Id,o);
        }
        
        insert oppLineItemsToOrderItems.values();
        
        for(Id relatedOppId : oppLineItemsToOrderItems.keySet()){
            Id parentIdKey; // The key to retrieving the actual Parent Line ID.
            Id actualParentId; // The actual Id value of the retrieved Parent Line record.
            
            parentIdKey = oppLineItemsToOrderItems.get(relatedOppId).ParentLineId__c;
            
            // No need to update this line if there was never a reference to a Parent Line.
            if(null == parentIdKey || null == oppLineItemsToOrderItems.get(parentIdKey)) continue; 
            
            actualParentId = oppLineItemsToOrderItems.get(parentIdKey).Id;
            OrderItem forUpdate = oppLineItemsToOrderItems.get(relatedOppId);
            forUpdate.ParentLineId__c = actualParentId;
        }

        upsert oppLineItemsToOrderItems.values();
    }
    
    
    
    public void activateOrder() {
        this.o.Status = 'Posted Payment';
        update this.o; 
    }
    
    
    public void addLine(OrderItem line){
        
        this.lines.add(line);
    }
    

    
    public void put(String key, Object o) {
        this.o.put(key,o);
    }
    
    public Id save() {
        upsert this.o;
        
        for(OrderItem line :this.lines){
            line.OrderId = this.o.Id;
        }
        
		insert this.lines;
        
        return this.o.Id;
    }
    
    public Order getSObject() {
        return this.o;
    }
    
    public static Order createPaidOfficeEventOrder(Id eventId, Id accountId){
        OrderContainer o = new OrderContainer();
        o.setAccountId(accountId);
        
        OcdlaEvent theEvent = new OcdlaEvent(eventId);
        
        List<Contact> contacts = [SELECT Id, Ocdla_Member_Status__c, FirstName, LastName, Email FROM Contact WHERE AccountId = :accountId 
                                 AND Ocdla_Current_Member_Flag__c = True ORDER BY LastName];
        
        for(Contact c :contacts){
            OrderItem item;
            if(null == c.Ocdla_Member_Status__c) continue;
            item = theEvent.createOrderItem(c);
            if(null != item) o.lines.add(item);
        }
        
        o.save();
        
        return o.getSObject();
    }
    
}