public with sharing class VFPageController {
    public Proposal__c proposal { get; set; }
    public List<Proposal_Line_Items__c> lineItem { get; set; }
    public String imageUrl {get; set;}
    public ContentVersion contentVersion {get; set;}

    public VFPageController() {
        String recordId = ApexPages.currentPage().getParameters().get('id');
        if(String.isNotBlank(recordId)){
            ContentDocumentLink attachment = [SELECT ContentDocumentId , ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =  :recordId Limit 1];
            getContentVersion(attachment);
            proposal = [select Id, Name,Summary__c,Total_Discount__c,Total_Estimated_Cost__c,Price_After_Discount__c, Total_Estimated_Hours__c, Conclusion__c,Delivery_Date__c, (select Id, Name,Challange_Faced__c,Solution__c,Service_Offered__c,Description__c,Estimated_Hours__c,Rate_Per_Hour__c,Total_Cost__c from Proposal_Line_Items__r) from Proposal__c where Id = :recordId];
            lineItem = proposal?.Proposal_Line_Items__r;
            System.debug('recordId -> '+recordId);
            System.debug('ProposalList -> '+proposal);
            System.debug('relatedList -> '+lineItem);
        }
    }

    // Query method to retrieve the ContentVersion record
    public void getContentVersion(ContentDocumentLink cdl) {
        if (cdl != null) {
            contentVersion = [SELECT Id, Title, VersionData FROM ContentVersion WHERE ContentDocumentId = :cdl.ContentDocumentId LIMIT 1];
            imageUrl = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + contentVersion.id;
            System.debug('attachment -> '+contentVersion);
        }
    }
}