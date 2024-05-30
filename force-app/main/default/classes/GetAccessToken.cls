/* Class for getting account record from other salesforce org through rest api integration
by calling class and its method from other org*/

public class GetAccessToken{

    public Contact con {get;set;}
    public String s1 {get;set;}
    public String accessToken;
    public String instanceUrl;
    public Wrapper wrapObj{get;set;}
    // Wrapper Class to Store the value from the Jason.
    public class Wrapper{
        String id;
        String instance_url;
        String access_token;
        String issued_at;
        String signature;
    }

    // sf env var set clientId = 3MVG9GCMQoQ6rpzRbNiHLPx2T21WMz5aSvVIfbYQMu7DpoocddkqwwsLr.kduHy5xsU6UsVG3KMsbjQCG5a57 clientSecret = 0A33EAD5D7DAE7BC0471F463686CD881F624177770F1178A75E66D9829E7D43D securityToken = WyabbcwVbQ9xk88H6Qv9KYlU username = saurav.mathuriya@resilient-otter-vilf2.com password = Saurav@2942 -e MyComputeEnv
    public void getAccessToken(){
        //You will get "clientId","clientSecret" when creating connected app in salesforce
        String clientId = '3MVG9GCMQoQ6rpzRbNiHLPx2T21WMz5aSvVIfbYQMu7DpoocddkqwwsLr.kduHy5xsU6UsVG3KMsbjQCG5a57';
        String clientSecret = '0A33EAD5D7DAE7BC0471F463686CD881F624177770F1178A75E66D9829E7D43D';
        String securityToken = 'your security token';
        //We can also store our username password in custom setting.
        String username='your username';//salesforce username 
        String password='Your Password'+securityToken;
        // Generating the Access Token
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://resilient-otter-vilf2-dev-ed.trailblaze.my.salesforce.com/services/oauth2/token');// this is the OAuth endpoint where this request will be hit
        req.setBody('grant_type=client_credentials&client_id='+clientId+'&client_secret='+clientSecret);
        
        Http http = new Http();
        try{
            HTTPResponse res = http.send(req);
            String str = res.getBody();
            wrapObj = (Wrapper)Json.deserialize(str,Wrapper.class);
            accessToken = wrapObj.access_token;
            instanceUrl = wrapObj.instance_url;
        }catch(Exception ex){
            System.debug('Mydebug:Exception:getAccessToken || Line Number - '+ ex.getLineNumber() + ' || Error Message - ' + ex.getMessage());
        }
    }
}