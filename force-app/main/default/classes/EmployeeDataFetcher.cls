global with sharing class EmployeeDataFetcher implements Queueable {
    private static String EMPLOYEE_API = 'https://antrazal.com/backend/api/v1.0/AntrazalSolutionsPrivatelimited/antrazal/employees';
    
    @future(callout=true)
    global static void hitEmployeeAPI(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(EMPLOYEE_API);
        request.setMethod('GET');
        try{
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            if(response.getStatusCode() == 200) {
                // Deserialize the JSON string into collections of primitive data types.
                List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
                // Cast the values in the 'animals' key as a list
                System.Debug(results);
            }
        }
        catch(Exception ex){
            System.debug('Mydebug:Exception:hitEmployeeAPIMethod || Line Number - '+ ex.getLineNumber() + ' || Error Message - ' + ex.getMessage());
        }
    }



    global void execute(QueueableContext context) {
        EmployeeDataFetcher.hitEmployeeAPI();
    }
}