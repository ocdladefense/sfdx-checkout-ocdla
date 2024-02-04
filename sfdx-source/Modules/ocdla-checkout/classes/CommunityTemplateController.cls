public virtual without sharing class CommunityTemplateController {

  
    public EntityConfiguration config;
    
    public User currentUser {get;protected set;}
    
    public HtmlStylesheet[] styles {get;protected set;}
    
    public static HtmlScript[] scripts {get{return null == scripts ? new HtmlScript[]{} : scripts;} protected set;}
     
    public static HtmlScript[] footerScripts {get{return null == footerScripts ? new HtmlScript[]{} : footerScripts;} protected set;}
    
	private static final String DEFAULT_LOGIN_URL = '/secur/frontdoor.jsp';
    
	private static final String DEFAULT_LOGOUT_URL = '/secur/logout.jsp';
    
	private static final String DEFAULT_START_URL = '/Store';  
    
    public String siteDomain {get; protected set;}    
    
    public String cdn {get;protected set;}
    
    public String cacheKey {get;protected set;}
    
    public String communityProfileName {get;protected set;}
    
    public String externalSite {get; protected set;}
    
    public Map<String,String> externalSites {get; protected set;}
    
    public String navMenu {get; protected set;}
    
    public String communityLogo {get; protected set;}
    
    public String communityUserIcon {get; protected set;}

     
    public CommunityTemplateController() {
        this('DefaultCommunityConfig');
    }
    
    
    public CommunityTemplateController(String configKey) {
        
		config = new EntityConfiguration(configKey);
        
        cdn = (String)config.get('cdn');
        cacheKey = (String)config.get('cacheKey');
        communityProfileName = (String)config.get('communityProfileName');

                
        externalSite = (String) config.get('externalSite');
        externalSites = new Map<String,String>{'hub'=>'thehub.iabc.com/home'};
        currentUser = [SELECT Id, FirstName, LastName FROM User WHERE Id = :UserInfo.getUserId()];
        communityLogo = (String) config.get('communityLogo');
        communityUserIcon = (String) config.get('communityUserIcon');
         
        
        
        styles = new HtmlStylesheet[]{};
        scripts = new HtmlScript[]{};
        footerScripts = new HtmlScript[]{};
            
            
		List<Object> cssjson = (List<Object>)config.get('styles');

        List<Object> jsjson = (List<Object>)config.get('scripts');

        List<Object> jsfooter = (List<Object>)config.get('footerScripts');
        
        
        for(Object styledef : cssjson) {
            Map<String,Object> style = (Map<String,Object>)styledef;
            String type = null == style.get('type') ? 'staticresource' : (String) style.get('type');
            String name = (String) style.get('name');
            String path = (String) style.get('path');
            HtmlStylesheet.Type t = type == 'staticresource' ? HtmlStylesheet.Type.STATIC_RESOURCE : HtmlStylesheet.Type.STYLESHEET;
			HtmlStylesheet current = new HtmlStylesheet(path, t);
            styles.add(current);
        }
            
        
        for(Object scriptdef : jsjson) {
            Map<String,Object> script = (Map<String,Object>) scriptdef;
            String type = null == script.get('type') ? 'staticresource' : (String) script.get('type');
            String name = (String) script.get('name');
            String path = (String) script.get('path');
            HtmlScript.Type t = type == 'staticresource' ? HtmlScript.Type.STATIC_RESOURCE : HtmlScript.Type.SCRIPT;
			HtmlScript current = new HtmlScript(name, t);
            scripts.add(current);
        }
    }
    
    
	
    
    
    public virtual String getLoginUrl() {
        // Can link user to the appropriate login page for this Community.
        String loginUrl = null != config.get('loginUrl') ? (String)config.get('loginUrl') : DEFAULT_LOGIN_URL;
        String currentPage = ApexPages.currentPage().getUrl();
        
        return formatLoginLink(loginUrl, currentPage, null);
    }
    
    public virtual String formatLoginLink(String url, String startURL, String retURL) {

        String startUrlEnc;
        String retUrlEnc;
      
        
		startUrlEnc = !String.IsEmpty(startUrl) ? EncodingUtil.urlEncode(startURL, 'UTF-8') : DEFAULT_START_URL;
		retUrlEnc = !String.IsEmpty(retUrlEnc) ? EncodingUtil.urlEncode(retUrl, 'UTF-8') : null;
		
        
		return url + '?sid=&startURL=' + startUrlEnc;      
    }
    
    

    
    
    

    
    @testVisible
    private static String getCommunityDomain() {
        if(Test.isRunningTest()) {
            return 'https://example.com';
        }
		Id networkId = Network.getNetworkId();
        if(null == networkId) return '';
        String communityUrl = Network.getLoginUrl(networkId);
        String[] parts = communityUrl.split('/');
        
        return parts[0];
    }
    
    

    
    
    
    public virtual String getLogoutUrl(){
        String logoutUrl = (String)config.get('logoutUrl');
        
        return null != logoutUrl ? logoutUrl : DEFAULT_LOGOUT_URL;
    }
    
    public virtual String getProfileUrl(){
        String profileUrl = (String)config.get('profileUrl');
        
		return null != profileUrl ? profileUrl : null;  
    }
    
    
    
    
    public Boolean getIsUserLoggedIn(){
    	Id currentUserProfileId;
        String currentProfileName;

        
        
        currentUserProfileId = UserInfo.getProfileId();
        
        currentProfileName = [SELECT Name FROM Profile WHERE Id = :currentUserProfileId].Name;
        
        
        return currentProfileName != this.communityProfileName;
    }

    
}