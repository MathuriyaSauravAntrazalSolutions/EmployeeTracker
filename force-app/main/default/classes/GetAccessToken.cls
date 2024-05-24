public with sharing class GetAccessToken {
    public static void getAccessToken() {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setEndpoint('https://login.salesforce.com/services/oauth2/token');
        String CLIENT_ID = '3MVG9GCMQoQ6rpzRbNiHLPx2T21WMz5aSvVIfbYQMu7DpoocddkqwwsLr.kduHy5xsU6UsVG3KMsbjQCG5a57';
        String CLIENT_SECRET = '0A33EAD5D7DAE7BC0471F463686CD881F624177770F1178A75E66D9829E7D43D';
        String username='saurav.mathuriya@resilient-otter-vilf2.com';
        String password='Saurav@294208v5K7KOg1aVPKqLGlVkwJ031';
        req.setBody('grant_type=password' + '&client_id='+CLIENT_ID + '&client_secret='+CLIENT_SECRET + +'&username='+username+'&password='+password);
        Http http = new Http();
        try{
            HTTPResponse response = http.send(req);
            System.debug('Body ' + response.getBody());
            System.debug('Status ' + response.getStatus());
            System.debug('Status code ' + response.getStatusCode());
        } catch(Exception ex){
            System.debug('Mydebug:Exception:hitEmployeeAPIMethod || Line Number - '+ ex.getLineNumber() + ' || Error Message - ' + ex.getMessage());
        }
    }
}