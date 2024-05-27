// dynamicInputComponent.js
import { LightningElement, api, track } from 'lwc';

export default class DynamicInputComponent extends LightningElement {
    @api heading;
    keyIndex = 0;
    @track lineItems = [{ Challange_Faced__c: '', Solution__c:'', Service_Offered__c:'', Description__c:'', Estimated_Hours__c:0, Rate_Per_Hour__c:0, Total_Cost__c:0, index:0, isAdded:false, removable: false }];
    
    handleRemoveSection(event) {
        const keyToRemove = parseInt(event.currentTarget.dataset.index, 10);
        const indexToRemove = this.lineItems.findIndex(section => section.index === keyToRemove);
        // console.log('index in removal -> key:'+keyToRemove+' index:'+indexToRemove);
        if (indexToRemove !== -1) {
            this.lineItems.splice(indexToRemove, 1);
        }
        this.lineItems = [...this.lineItems]; // Trigger reactivity
        if (indexToRemove != -1) {
            // const items = {...this.lineItems};
            this.dispatchEvent(new CustomEvent('childchange', { detail: this.lineItems }));
        }
    }
    
    handleLineItem(event) {
        const keyToAdd = parseInt(event.currentTarget.dataset.index, 10);
        const indexToAdd = this.lineItems.findIndex(section => section.index === keyToAdd);
        // console.log('index in addLine -> key:'+keyToAdd+' index:'+indexToAdd);
        console.log(typeof indexToAdd);
        console.log(indexToAdd != -1);
        if (indexToAdd != -1) {
            // const items = {...this.lineItems};
            this.dispatchEvent(new CustomEvent('childchange', { detail: this.lineItems }));
        }
    }

    handleChange(event) {
        const keyToUpdate = parseInt(event.currentTarget.dataset.index, 10);
        const indexToUpdate = this.lineItems.findIndex(section => section.index === keyToUpdate);
        if(indexToUpdate<= -1) return;
        const label = event.target.label;
        const value = event.target.value;
        // console.log('key -> '+keyToUpdate);
        // console.log('label -> '+label);
        // console.log('index -> '+indexToUpdate);
        // console.log('value -> '+value);
        if(label==="Challange Faced"){
            this.lineItems[indexToUpdate].Challange_Faced__c = value;
        }
        else if(label==="Proposed Solution"){
            this.lineItems[indexToUpdate].Solution__c = value;
        }
        else if(label==="Service Offered"){
            this.lineItems[indexToUpdate].Service_Offered__c = value;
        }
        else if(label==="Description"){
            this.lineItems[indexToUpdate].Description__c = value;
        }
        else if(label==="Estimated Time(Hours)"){
            this.lineItems[indexToUpdate].Estimated_Hours__c = parseInt(value)?parseInt(value):0;
        }
        else if(label==="Rate Per Hour"){
            this.lineItems[indexToUpdate].Rate_Per_Hour__c = parseInt(value)?parseInt(value):0;
        }
        const val = parseInt(this.lineItems[indexToUpdate].Rate_Per_Hour__c) * parseInt(this.lineItems[indexToUpdate].Estimated_Hours__c)
        this.lineItems[indexToUpdate].Total_Cost__c = val?val:0;
        // console.log('Total_Cost__c -> '+this.lineItems[indexToUpdate].Total_Cost__c);
    }

    addSection() {
        // console.log('key to add -> '+this.keyIndex);
        this.keyIndex+=1;
        this.lineItems = [...this.lineItems, { Challange_Faced__c: '', Solution__c:'', Service_Offered__c:'', Description__c:'', Estimated_Hours__c:'', Rate_Per_Hour__c:'', Total_Cost__c:0, index:this.keyIndex, isAdded:false, removable: true }];
    }

}