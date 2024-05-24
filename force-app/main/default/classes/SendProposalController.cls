public with sharing class SendProposalController {
    public class MyCustomException extends Exception {}
    
    @AuraEnabled(cacheable=true)
    public static List<String> getContactsEmails(List<ID> ccIds) {
        if (ccIds.size()>0) {
            List<Contact> ctList = [SELECT Email FROM Contact WHERE Id IN :ccIds And Email != NULL];
            List<String> contactEmails = new List<String>();
            for (Contact contact : ctList) {
                contactEmails.add(contact.Email);
            }
            return contactEmails;
        }
        return null;
    }


    // Query method to retrieve the ContentVersion record
    @AuraEnabled(cacheable=true)
    public static ContentVersion getContentVersion(ContentDocumentLink cdl) {
        if (cdl != null) {
            return [SELECT Id, Title, VersionData FROM ContentVersion WHERE ContentDocumentId = :cdl.ContentDocumentId LIMIT 1];
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static void sendProposal(Id opportunityId, String contactEmail, List<ID> ccIds, List<String> eeIds) {
        // Retrieve PDF attachment from Opportunity's Notes and Attachments
        ContentDocumentLink attachment = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :opportunityId And ContentDocument.FileExtension='pdf' Order By SystemModstamp DESC LIMIT 1];

        if(attachment!=null){
            ContentVersion cversion = SendProposalController.getContentVersion(attachment);
            blob WOCFbody = cversion.VersionData;
            system.debug('body : '+WOCFbody+'-----------'+cversion.title);
            // Create email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {contactEmail}); // One Or Multiple
            email.setSubject('Offer Letter From Antrazal');
            email.setPlainTextBody('Please find attached the PDF document of offer letter.');

            // Attach PDF to email
            Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
            emailAttachment.setFileName(cversion.title+'.pdf');
            emailAttachment.setBody(WOCFbody);
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {emailAttachment});
            List<String> ccEmails = new List<String>();
            if(eeIds!=NULL && eeIds.size()>0) {
                for(String em: eeIds){
                	ccEmails.add(em);
            	}
            }
            List<String> ctEmails = SendProposalController.getContactsEmails(ccIds);
            if(ctEmails!=NULL){
                for(String em: ctEmails){
                	ccEmails.add(em);
            	}
            }
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
                throw new MyCustomException('Unable to Send Mail Due To Invalid Email Address - '+str[1].substring(0, str[1].length()-1));
            }
        } else {
            throw new MyCustomException('Unable to Send Mail To Contact');
            // Handle case where no PDF attachment is found
        }
    }
}