public class OrderConfirmationController extends CommunityController {
 
    public Boolean hasError { get; private set;}
    
    public OrderConfirmationController() {
        super('CheckoutCommunityConfig');
        
        Map<String,String> params = ApexPages.currentPage().getParameters();
        hasError = false;
       	hasError = null != params.get('error');
    }
}