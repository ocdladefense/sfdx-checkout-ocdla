@isTest
public class CheckoutServiceMock implements HttpCalloutMock {
    

	private List<CustomerProfile> profiles = new List<CustomerProfile>();

    
    
    
    public CheckoutServiceMock() {}

    
    
    public void addCustomerProfile(CustomerProfile profile) {
        this.profiles.add(profile);
    }
    
    

    public HttpResponse respond(HttpRequest req) {
        //System.debug('making a respond request');

        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type', 'application/json');
        
        String requestType = req.getHeader('X-Request-Type');

        Messages theMessages = new Messages();
        Message m = new Message();
        m.setCode('I00001');
        m.setText('Successful');

        theMessages.setResultCode(AuthorizeDotNetResponse.RESPONSE_SUCCESS);
        theMessages.setMessage(new List<Message>{m});

        Map<String,Object> data = new Map<String,Object>();
        data.put('profile', this.profiles[0]);
        data.put('messages', theMessages);

        String respBody = JSON.serialize(data);
  
   
        resp.setBody(respBody);
        resp.setStatusCode(200);
        resp.setStatus('Apex generated Mock HttpResponse.');

        return resp;
    }

}