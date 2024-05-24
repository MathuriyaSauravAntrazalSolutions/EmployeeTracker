/*
*********************************************************
*  @Class Name    :    CustomLookupLwcController 
*  @Author         :   <Saurav Mathuriya>(saurav.mathuriya@antrazal.com)
*  @Company        :   Antrazal
*  @Date           :   24-05-2024
*  @description    :   Used In Send Proposal LWC For Searching Recipient Contact Lookup By Name
*********************************************************
*/
public class CustomLookupLwcController {
    // Method to fetch lookup search result   
     @AuraEnabled(cacheable=true)
     public static list<sObject> fetchLookupData(string accountId, string searchKey , string sObjectApiName) {    
         List < sObject > returnList = new List < sObject > ();
 
         string sWildCardText = '%' + searchKey + '%';
         System.Debug(accountId);
         System.Debug(sObjectApiName);
         string sQuery = 'Select Id,Name, Email From ' + sObjectApiName + ' Where Name Like : sWildCardText And AccountId = \''+accountId+'\' order by createdDate DESC LIMIT 5';
         for (sObject obj: database.query(sQuery)) {
             returnList.add(obj);
         }
         return returnList;
     }
     
     // Method to fetch lookup default value 
     @AuraEnabled
     public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
         string sRecId = recordId;    
         string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
         for (sObject obj: database.query(sQuery)) {
             return obj;
         }
         return null;
     }
     
 }