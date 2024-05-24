public with sharing class OpportunityController {
    public class MyCustomException extends Exception {}
    @AuraEnabled(cacheable=true)
    public static String getUserEmail(Id ownerId) {
        User owner = [SELECT Email FROM User WHERE Id = :ownerId];
        return owner.Email;
    }

    @AuraEnabled(cacheable=true)
    public static List<sObject> getProposalList(Id opportunityId) {
        return [SELECT Id, Name, Status__c FROM Proposal__c WHERE Opportunity__c = :opportunityId];
    }

    @AuraEnabled
    public static void saveProposalPDF(String proposalId) {
        try {
            // Retrieve proposal data and associated opportunity
            Proposal__c proposal = [SELECT Id, Name ,CreatedDate, Status__c ,Opportunity__c FROM Proposal__c WHERE Id = :proposalId LIMIT 1];

            // Generate PDF content using Visualforce page
            PageReference pdfPage = Page.ProposalPdf;
            pdfPage.getParameters().put('id', proposalId);
            Blob pdfBlob;
            if (!Test.isRunningTest()) {
                pdfBlob = pdfPage.getContentAsPDF();
            }
            if(proposal.Status__c=='Draft') proposal.Status__c ='Send(Active)';
            else{
                throw new MyCustomException('Proposal Pdf Is Already Saved');
            }
            String formattedFileName = proposal.Name;

            ContentVersion contentVersionRec = new ContentVersion();
            contentVersionRec.Title =formattedFileName;
            contentVersionRec.PathOnClient = formattedFileName + '.pdf';
            contentVersionRec.VersionData = pdfBlob;

            // Inserting the ContentVersion record
            insert contentVersionRec;

            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionRec.Id].ContentDocumentId;

            //Create ContentDocumentLink
            ContentDocumentLink linkToRecord = new ContentDocumentLink();
            linkToRecord.ContentDocumentId = contentDocumentId;
            linkToRecord.LinkedEntityId = proposal.Opportunity__c; 
            linkToRecord.ShareType = 'I'; 
            insert linkToRecord;
            
            update proposal;
        } catch (Exception e) {
            if(e.getMessage()=='Proposal Pdf Is Already Saved') throw e;
            throw new MyCustomException('Unable To Save Pdf In Opportunity Controller');
        }
    }
}