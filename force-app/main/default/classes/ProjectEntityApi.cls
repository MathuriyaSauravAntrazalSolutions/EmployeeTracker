@RestResource(urlMapping='/Antazal/Internal/V1/Project/*')
global with sharing class ProjectEntityApi {
    @HttpGet
    global static List<Project_Entity__c> getAllProjectEntities() {
        RestRequest request = RestContext.request;
        // grab the caseId from the end of the URL
        String email = request.requestURI.substring(
          request.requestURI.lastIndexOf('/')+1);
        return [SELECT Id, Name, Actual_Hours__c, Contact_Employee__c, CreatedById, Description__c, 
                      Estimated_Hours__c, OwnerId, LastModifiedById, Parent__c, Planned__c, 
                      Project__c, Project_Allocation__c, Status__c, User_Stories__c, RecordType.Name 
               FROM Project_Entity__c WHERE Contact_Employee__r.Email = :email];
    }
}