@isTest
private class CommunityTemplateControllerTests {
  
           
	@isTest
    private static void loadTemplateController() {
         
        PageReference thePage;
        CommunityTemplateController controller;
        String loginUrl;
        
        // Prepare our example page with at least one parameter.
        //  Facilitates testing of variables set using ApexPages.currentPage();
        thePage = Page.Default;
        thePage.getParameters().put('id','someId');  
        Test.setCurrentPage(thePage);

        controller = new CommunityTemplateController('DefaultCommunityConfig');
    	controller.getProfileUrl();
        controller.getLogoutUrl();
        CommunityTemplateController.getCommunityDomain();
        Url.formatQueryString(new Map<String,String>{'foo'=>'bar'});

        Boolean isUserLoggedIn = controller.getIsUserLoggedIn();
        
        loginUrl = controller.getLoginURL();
        
        System.debug('Login URL is: ' + loginUrl);
    }   
}