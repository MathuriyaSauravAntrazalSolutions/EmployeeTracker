import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import INVOKE_GENERATE_CHANNEL  from '@salesforce/messageChannel/Invoke_Generate__c';

export default class HeadlessComponent extends LightningElement {

    @wire(MessageContext)
    messageContext;

    
    @api invoke() {
        const payload ={
            isModalOpen : true
        } 
        // Dispatch a custom event to notify the parent component or another LWC to open the modal
        publish(this.messageContext, INVOKE_GENERATE_CHANNEL, payload)

        console.log('headless event fired');
        // Optionally show a toast message
    }
}