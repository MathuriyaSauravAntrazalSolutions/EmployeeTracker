import { LightningElement, wire, api, track } from 'lwc';
import getProposalList from '@salesforce/apex/OpportunityController.getProposalList';
import saveProposalPDF from '@salesforce/apex/OpportunityController.saveProposalPDF';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';


const COLUMNS = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Status', fieldName: 'Status__c', type: 'text' },
    { label: 'View Proposal', type: 'button', typeAttributes: { label: 'View', name: 'view', title: 'View', variant: 'brand' } },
    { label: 'Save Proposal', type: 'button', typeAttributes: { label: 'Save', name: 'save', title: 'Save', variant: 'brand' } }
];

export default class ViewProposal  extends LightningElement {
    // Opportunity Id
    @api recordId;
    @track proposals=[]
    listResult=[]
    updatedData = [];
    //@track proposalsList;
    
    @wire(getProposalList, { opportunityId: '$recordId' })
    getProposals({data, error}){
        if(data){
            this.listResult = JSON.parse(JSON.stringify(data));
            for(let i = 0; i < data.length; i++){
                let row = this.listResult[i];
                row.index = i;
                console.log(row);
                this.updatedData.push(row);
            }
            this.proposals = this.updatedData;
        }
        else if (error){
            this.handleError('No Row Available For Selection');
        }
    }

    columns = COLUMNS;

    openProposal(recordId){
        let url = `https://resilient-otter-vilf2-dev-ed--c.trailblaze.vf.force.com/apex/ProposalPdf?Id=${recordId}`;
        window.open(url, '_blank');
    }

    handleSuccess() {
        // Display a success toast message
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Proposal PDF saved successfully',
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    handleError(error) {
        console.log('error');
        console.log(error);
        // Display an error toast message
        const evt = new ShowToastEvent({
            title: 'Error',
            message: error,
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }

    handleRowAction(event) {
        console.log(event);
        const action = event.detail.action;
        const row = event.detail.row;
        console.log("action->",action);
        const proposalId = row.Id;
        switch (action.name) {
            case 'view':
                this.openProposal(proposalId);
            break;
            case 'save':
                if(row.Status__c==='Send(Active)'){
                    this.handleError('Proposal Pdf Alredy Saved');
                    break;
                }
                saveProposalPDF({ proposalId: proposalId })
                    .then(result => {
                        console.log('Proposal PDF saved successfully');
                        this.proposals[row.index].Status__c = 'Send(Active)';
                        this.proposals = [...this.proposals];
                        this.handleSuccess();
                        this.dispatchEvent(new CloseActionScreenEvent());
                    })
                    .catch(error => {
                        console.error('Error saving Proposal PDF', error);
                        this.handleError(error.body.message);
                    });
                break;
            default:
                break;
        }
    }
}