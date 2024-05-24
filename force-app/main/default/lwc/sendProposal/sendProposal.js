import { LightningElement, wire, api} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getUserEmail from '@salesforce/apex/OpportunityController.getUserEmail';
import sendProposal from '@salesforce/apex/SendProposalController.sendProposal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';


const FIELDS = ['Opportunity.OwnerId', 'Opportunity.AccountId'];

export default class SendProposal extends LightningElement {
    selectedValue;
    picklistValues = [];
    @api recordId;
    ownerEmail;
    accountId;
    selectedLookupContacts=[];
    selectedLookupEmails=[];

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            console.log('data');
            console.log(data);
            const ownerId = data.fields.OwnerId.value;
            this.accountId = data.fields.AccountId.value;
            this.fetchOwnerEmail(ownerId);
        } else if (error) {
            console.error('Error fetching record:', error);
        }
    }

    fetchOwnerEmail(ownerId) {
        getUserEmail({ ownerId: ownerId })
            .then(result => {
                this.ownerEmail = result;
            })
            .catch(error => {
                console.error('Error fetching user email:', error);
            });
    }

    lookupRecord(event){
        // alert('Selected Record Value on Parent Component is ' +  JSON.stringify(event.detail.selectedRecord));
        this.selectedValue = event.detail.selectedRecord;
    }

    handleSend() {
        // Send selected picklist value
        console.log(this.selectedValue);
        console.log(this.selectedLookupEmails);
        console.log(this.selectedLookupContacts);
        if(!this.selectedValue){
            this.handleError("Please Select A Contact");
        }
        sendProposal({ opportunityId: this.recordId , contactEmail: this.selectedValue.Email, ccIds: this.selectedLookupContacts, eeIds:this.selectedLookupEmails})
            .then(result => {
                console.log("Mail Has Sent Successfully");
                this.handleSuccess();
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                console.error('Error saving Proposal PDF', error);
                console.log(error);
                this.handleError(error.body.message);
            });
    }


    handleLookupContactSubmit(event){
        console.log(event);
        this.selectedLookupContacts = event.detail;
    }

    handleLookupEmailSubmit(event){
        console.log(event);
        this.selectedLookupEmails = event.detail;
    }

    handleSuccess() {
        // Display a success toast message
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Mail Has Sent Successfully',
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    handleError(error) {
        // Display an error toast message
        const evt = new ShowToastEvent({
            title: 'Error',
            message: error,
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }
}