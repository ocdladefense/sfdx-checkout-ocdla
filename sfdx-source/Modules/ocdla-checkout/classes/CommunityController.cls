public without sharing virtual class CommunityController implements ICommunityController {

    public PageReference template {get; protected set;}
    
    
    protected EntityConfiguration config;
      
        
    public CommunityController() {
        this('DefaultCommunityConfig');
    }
    
    
    public CommunityController(String configName){
			config = new EntityConfiguration(configName);
			
        
	      if(null != config.get('template')) {
			
				String tName = (String)config.get('template');
				List<ApexPage> templates = [SELECT Id, Name FROM ApexPage WHERE Name = :tName LIMIT 1];
	      this.template = null == templates || templates.size() == 0 ? Page.CommunityTemplate : new PageReference(templates[0]);
	      
			} else {
				this.template = Page.CommunityTemplate;
			}
    }
    
    public PageReference getTemplate(){
        return this.template;
    }
    
    public Map<String,Object> getConfig(){
         
        return (Map<String,Object>)this.config.getConfig();
    }
}