import { LightningElement, wire, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createRecord from '@salesforce/apex/ProposalController.createRecord';//
import { CloseActionScreenEvent } from 'lightning/actions';
import { subscribe, MessageContext } from 'lightning/messageService';
import INVOKE_GENERATE_CHANNEL  from '@salesforce/messageChannel/Invoke_Generate__c';

export default class GenerateProposal extends NavigationMixin(
    LightningElement
){



    @api recordId; // OpportunityId
    @track proposal
    @track proposal = {proposalFields:{file:null, Opportunity__c:'',Price_After_Discount__c:0, Total_Estimated_Hours__c:0, Total_Discount__c:0, Total_Estimated_Cost__c:0, Delivery_Date__c:null, Conclusion__c:'', Summary__c:''}, lineItems:[]};
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        // console.log(currentPageReference);
        if (currentPageReference.type === "standard__quickAction") {
            let quickActionPath = currentPageReference.attributes.apiName; // ex: Opportunity.My_Quick_Action
            console.log(quickActionPath.split('.')[1]); // Ex: My_Quick_Action
            this.isShowModal = true;
        }
    }

    get acceptedFormats() {
        return ['.png','.jpg','.jpeg'];
    }

    // Initialize other section variables
    handleSummaryChange(event) {
        this.proposal.proposalFields.Summary__c = event.target.value;
    }

    handleConclusionChange(event) {
        this.proposal.proposalFields.Conclusion__c = event.target.value;
    }

    handleTimelineChange(event) {
        this.proposal.proposalFields.Delivery_Date__c = event.target.value;
    }

    handleTotalDiscount(event) {
        this.proposal.proposalFields.Total_Discount__c = parseInt(event.target.value)?parseInt(event.target.value):0;
        this.proposal.proposalFields.Price_After_Discount__c = this.proposal.proposalFields.Total_Estimated_Cost__c - (this.proposal.proposalFields.Total_Estimated_Cost__c * this.proposal.proposalFields.Total_Discount__c)/100;
    }

    handleChildChange(event){
        const sections = event.detail;
        let totalAm = 0;
        let totalH = 0;
        for(let i = 0; i < sections.length; i++){
            totalAm += sections[i].Total_Cost__c;
            totalH += sections[i].Estimated_Hours__c;
        }
        this.proposal.lineItems = event.detail;
        this.proposal.proposalFields.Total_Estimated_Cost__c = totalAm;
        this.proposal.proposalFields.Total_Estimated_Hours__c = totalH;
        this.proposal.proposalFields.Price_After_Discount__c = totalAm - (totalAm * this.proposal.proposalFields.Total_Discount__c)/100;
    }
    // Implement other handle methods for additional sections

    createProposal() {
        // Call Apex method to create the proposal record with the provided data
        this.proposal.proposalFields.Opportunity__c = this.recordId;
        createRecord({...this.proposal})
        .then(result => {
            // Handle success
            this.handleSuccess();
            this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch(error => {
            // Handle error
            this.handleError(error);
            console.log('error');
            console.log(error);
        });
        this.handleClose();
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        const contentVersionId = uploadedFiles[0].documentId;
        this.proposal.proposalFields.file = contentVersionId;
        console.log(uploadedFiles);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFiles[0].name,
                variant: 'success',
            }),
        );
    }



    @api
    flag = false;
    @track isModalOpen = false;
    @track isMinimized = false;
    @track isNonMinimized = false;
    @wire(MessageContext)
    messageContext;

    @api
    openModal() {
        this.isModalOpen = true;
        this.isMinimized = false;
        this.isNonMinimized = true;
        setTimeout(()=>{
            console.log("In Open Modal");
            const IconBtns = document.querySelector(".c-generate-proposal");
            console.log(IconBtns);
            if(IconBtns) IconBtns.style.position = "relative";
        }, 200)
    }

    handleMinimize() {
        this.isMinimized = !this.isMinimized;
        this.isNonMinimized = !this.isNonMinimized
        this.updateModalClass();
        console.log('minimized');
    }

    handleClose() {
        this.isModalOpen = false;
        this.isNonMinimized = false;
    }

    updateModalClass() {
        const modalElement = this.template.querySelector('.slds-modal');
        if (modalElement) {
            console.log(modalElement);
            modalElement.classList.toggle('minimized', this.isMinimized);
            console.log(modalElement);
        }
    }

    @api
    get modalClass() {
        return this.isMinimized ? 'slds-modal minimized slds-fade-in-open' : 'slds-modal slds-fade-in-open';
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
          this.messageContext,
          INVOKE_GENERATE_CHANNEL,
          (message) => this.handleMessage(message)
        );
    }


    connectedCallback() {
        if(!this.flag){
            this.subscribeToMessageChannel();
        }
        else{
            this.isModalOpen = true;
        }
    }


    handleMessage(message){
        if(message.isModalOpen){
            this.openModal();
        }
    }


    handleSuccess() {
        // Display a success toast message
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Record created successfully',
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
            message: error.body.message,
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }
}