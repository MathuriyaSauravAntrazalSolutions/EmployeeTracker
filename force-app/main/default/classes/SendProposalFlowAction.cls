public class SendProposalFlowAction {
    public class MyCustomException extends Exception {}  
    public Static String recordId;
    public Static List<String> emailList = new List<String>();
    public Static List<String> recipientList =new List<String>();
    
    public class flowInputs{
        @InvocableVariable
        public List<String> recordIds;
    
        @InvocableVariable
        public List<String> recipientEmails;
        
        @InvocableVariable
        public List<String> ccEmails;
    }
    

    @InvocableMethod
    public static List<String>  sendProposalApexAction(List<flowInputs> request) {
        for (FlowInputs input : request) {
            recordId = input.recordIds[0];
            if (input.recipientEmails != null && !input.recipientEmails.isEmpty()) {
                for (String recipientEmails : input.recipientEmails) {
                    emailList.addAll(recipientEmails.split(';'));
                }
            }
            if (input.ccEmails != null && !input.ccEmails.isEmpty()) {
                for (String recipient : input.ccEmails) {
                    recipientList.addAll(recipient.split(','));
                }
            }  
        }
        System.debug('Additional Recipients -> ' + recipientList);
        try{
            SendProposalFlowAction.sendProposal( recordId,  emailList, recipientList);}
        catch(Exception e){
            throw e;
        }
        return null;
    }
    
    public static ContentVersion getContentVersion(ContentDocumentLink cdl) {
        if (cdl != null) {
            return [SELECT Id, Title, VersionData FROM ContentVersion WHERE ContentDocumentId = :cdl.ContentDocumentId LIMIT 1];
        }
        return null;
    }
    
    public Static void sendProposal(String opportunityId, List<String> contactEmail, List<String> ccEmails) {
        ContentDocumentLink attachment = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :opportunityId And ContentDocument.FileExtension='pdf' Order By SystemModstamp DESC LIMIT 1];
        if(attachment!=null){
            ContentVersion cversion = SendProposalFlowAction.getContentVersion(attachment);
            blob WOCFbody = cversion.VersionData;
            system.debug('body : '+WOCFbody+'-----------'+cversion.title);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(contactEmail); // One Or Multiple
            email.setSubject('Proposal Letter From Antrazal');
            email.setPlainTextBody('Please find attached the PDF document of offer letter.');
            Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
            emailAttachment.setFileName(cversion.title+'.pdf');
            emailAttachment.setBody(WOCFbody);
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {emailAttachment});
           
            // Send email
            if(ccEmails.size()>0){
                email.setCcAddresses(ccEmails);
            }
            System.Debug(ccEmails);
            try{
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
            catch(Exception e){
                List<String> str = e.getMessage().split('ccAddresses,');
                System.debug('Unable to Send Mail Due To Invalid Email Address - '+str[1].substring(0, str[1].length()-1));
            }
        } else {
            System.debug('Unable to Send Mail To Contact');
        }
    }
}
