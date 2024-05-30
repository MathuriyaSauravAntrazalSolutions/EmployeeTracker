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


export default class ViewProposalFlowLwc extends LightningElement {
    @api content;
    @track proposals=[]
    listResult=[]
    @track loading = false;
    updatedData = [];
    columns = COLUMNS;

    connectedCallback() {
        if (this.content) {
            console.log(this.content);
            const parsedData = this.parseContent(this.content);
            console.log(parsedData);
            
            // Iterate over each row of parsedData
            if(!parsedData || parsedData.length<0){
                return;
            }
            console.log(parsedData[0].length);
            if(parsedData[0].length>0){
                this.loading = true;
            }
            for (let i = 0; i < parsedData[0].length; i++) {
                const Id = parsedData[0][i];
                const Name = parsedData[1][i];
                const Status__c = parsedData[2][i];
                let row = {Id, Name, Status__c}
                row.index = i;
                console.log(row);
                this.updatedData.push(row);
            }
            this.proposals = this.updatedData;
        }
    }

    parseContent(content) {
        const rows = content.substring(4, content.length - 4).split('][');
        const result = [];
        for (let i = 0; i < rows.length; i++) {
            result.push(rows[i].replace('[', '').replace(']', '').split(','));
        }
        return result;
    }


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