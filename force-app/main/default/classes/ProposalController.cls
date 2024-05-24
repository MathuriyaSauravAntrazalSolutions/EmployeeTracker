public with sharing class ProposalController {
    public class MyCustomException extends Exception {}
    @AuraEnabled
    public static void createRecord(Map<String, Object> proposalFields, List<Map<String, Object>> lineItems) {
            // System.Debug(proposalFields);
            // System.Debug(lineItems);
            Proposal__c newProposal = new Proposal__c();

            // Create a new Proposal record

            // Set Proposalcount field values
            newProposal.Name = 'Proposal_' + proposalFields.get('Opportunity__c') + '_' + Datetime.now();
            newProposal.Status__c = 'Draft';
            newProposal.Conclusion__c = (String)proposalFields.get('Conclusion__c');
            List<String> dateParts = new List<String>();
            try{
                String proposed_date = String.valueOf(proposalFields.get('Delivery_Date__c'));
                dateParts = proposed_date.split('-');
            }catch(Exception e){
                throw new MyCustomException('Please Provide A Date');
            }
            Integer year = Integer.valueOf(dateParts[0]);
            Integer month = Integer.valueOf(dateParts[1]);
            Integer day = Integer.valueOf(dateParts[2]);
            Date dateInstance = Date.newInstance(year, month, day);
            newProposal.Delivery_Date__c = dateInstance;
            newProposal.Summary__c = (String)proposalFields.get('Summary__c');
            newProposal.Total_Discount__c = (Double)proposalFields.get('Total_Discount__c');
            newProposal.Opportunity__c = (ID)proposalFields.get('Opportunity__c');
            // newProposal.Total_Estimated_Cost__c = (Number)proposalFields.get('Total_Estimated_Cost__c'); // come up from rollup
            // newProposal.Total_Estimated_Hours__c = (Number)proposalFields.get('Total_Estimated_Hours__c'); // come up from rollup
            // Insert the Proposal record
            try {    
                insert newProposal;
            } catch (Exception e) {
                throw new MyCustomException('Something Went Wrong From Opportunity Controller');
            }


            try{
                ProposalController.uploadFile(newProposal.Id, (Id)proposalFields.get('file'));
            }catch(Exception e){
                throw new MyCustomException('Please Provide A Logo');
            }
            // Extract LineItems records
            List<Proposal_Line_Items__c> lineItemsList = new List<Proposal_Line_Items__c>();

            // Create lineItem records
            for (Map<String, Object> lineItemFields : lineItems) {
                Proposal_Line_Items__c newLineItem = new Proposal_Line_Items__c();
                newLineItem.Name = ' LineItem_'+lineItemFields.get('index')+'_Proposal_'+newProposal.Id;
                newLineItem.Challange_Faced__c = (String)lineItemFields.get('Challange_Faced__c');
                newLineItem.Description__c = (String)lineItemFields.get('Description__c');
                newLineItem.Estimated_Hours__c = (Double)lineItemFields.get('Estimated_Hours__c');
                newLineItem.Rate_Per_Hour__c = (Double)lineItemFields.get('Rate_Per_Hour__c');
                newLineItem.Service_Offered__c = (String)lineItemFields.get('Service_Offered__c');
                newLineItem.Solution__c = (String)lineItemFields.get('Solution__c');
                newLineItem.Total_Cost__c = (Double)lineItemFields.get('Total_Cost__c');

                // You might want to set the ProposalId on each LineItem to link them to the Account
                newLineItem.Proposal__c = newProposal.Id;
                lineItemsList.add(newLineItem);
            }

            // Insert the Contact records
            if (!lineItemsList.isEmpty()) {
                try {
                    insert lineItemsList;
                } catch (Exception e) {
                    throw new MyCustomException('Unable to Insert Record');
                }
            }
    }

    public static void uploadFile(Id parentId, Id file) {        
        ContentDocumentLink linkToProposal = new ContentDocumentLink();
        linkToProposal.ContentDocumentId = file;
        linkToProposal.LinkedEntityId = parentId;
        linkToProposal.ShareType = 'V';
        linkToProposal.Visibility = 'AllUsers';
        insert linkToProposal;
    }
}