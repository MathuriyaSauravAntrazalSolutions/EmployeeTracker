import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/** Apex methods from SampleLookupController */
import search from '@salesforce/apex/MultiSelectLookupController.search';
import getRecentlyViewed from '@salesforce/apex/MultiSelectLookupController.getRecentlyViewed';

export default class MultiSelectLuookup extends LightningElement {
    // Use alerts instead of toasts (LEX only) to notify user
    @api notifyViaAlerts = false;
    @api label;
    selectedContactIds=[];
    selectedEmailIds = [];
    isMultiEntry = true;
    maxSelectionSize = 10000;
    initialSelection = [];
    errors = [];
    recentlyViewed = [];
    newRecordOptions = [
        { value: 'Contact', label: 'New Contact' },
    ];

    /**
     * Loads recently viewed records and set them as default lookup search results (optional)
     */
    @wire(getRecentlyViewed)
    getRecentlyViewed({ data }) {
        if (data) {
            this.recentlyViewed = data;
            this.initLookupDefaultResults();
        }
    }

    connectedCallback() {
        this.initLookupDefaultResults();
    }

    /**
     * Initializes the lookup default results with a list of recently viewed records (optional)
     */
    initLookupDefaultResults() {
        // Make sure that the lookup is present and if so, set its default results
        const lookup = this.template.querySelector('c-custom-multi-select-lookup');
        if (lookup) {
            lookup.setDefaultResults(this.recentlyViewed);
        }
    }

    /**
     * Handles the lookup search event.
     * Calls the server to perform the search and returns the results to the lookup.
     * @param {event} event `search` event emitted by the lookup
     */
    async handleLookupSearch(event) {
        const lookupElement = event.target;
        // Call Apex endpoint to search for records and pass results to the lookup
        try {
            const results = await search(event.detail); // searched contacts
            console.log(event.detail);
            lookupElement.setSearchResults(results);
        } catch (error) {
            this.notifyUser('Lookup Error', 'An error occurred while searching with the lookup field.', 'error');
            // eslint-disable-next-line no-console
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        }
    }

    /**
     * Handles the lookup selection Enter
     * @param {event} event `Keydown` event emitted by the lookup.
     * The event contains the list of selected ids.
     */
    // eslint-disable-next-line no-unused-vars

    /**
     * Handles the lookup selection change
     * @param {event} event `selectionchange` event emitted by the lookup.
     * The event contains the list of selected ids.
     */
    // eslint-disable-next-line no-unused-vars
    handleLookupSelectionChange(event) {
        this.selectedContactIds = event.detail;
        this.checkForErrors();
        this.dispatchEvent(new CustomEvent('submitcontacts', { detail: this.selectedContactIds }));
    }

    handleLookupEmailSelectionChange(event) {
        this.selectedEmailIds = event.detail;
        this.checkForErrors();
        this.dispatchEvent(new CustomEvent('submitemails', { detail: this.selectedEmailIds }));
    }

    // All functions below are part of the sample app form (not required by the lookup).

    handleLookupTypeChange(event) {
        this.initialSelection = [];
        this.errors = [];
        this.isMultiEntry = event.target.checked;
    }

    handleMaxSelectionSizeChange(event) {
        this.maxSelectionSize = event.target.value;
    }

    // handleSubmit() {
    //     console.log(this.initialSelection);
    //     this.checkForErrors();
    //     console.log(this.selectedContactIds);
    //     if (this.errors.length === 0) {
    //         this.notifyUser('Success', 'The form was submitted.', 'success');
    //     }
    //     this.dispatchEvent(new CustomEvent('submit', { detail: this.selectedContactIds }));
    // }

    handleClear() {
        this.selectedContactIds = [];
        this.selectedEmailIds = [];
        console.log(this.initialSelection);
        this.initialSelection = [];
        this.errors = [];
    }

    handleFocus() {
        this.template.querySelector('c-custom-multi-select-lookup').focus();
    }

    checkForErrors() {
        this.errors = [];
        const selection = this.template.querySelector('c-custom-multi-select-lookup').getSelection();
        // Custom validation rule
        if (this.isMultiEntry && selection.length > this.maxSelectionSize) {
            this.errors.push({ message: `You may only select up to ${this.maxSelectionSize} items.` });
        }
        // Enforcing required field
        if (selection.length === 0) {
            this.errors.push({ message: 'Please make a selection.' });
        }
    }

    notifyUser(title, message, variant) {
        if (this.notifyViaAlerts) {
            // Notify via alert
            // eslint-disable-next-line no-alert
            alert(`${title}\n${message}`);
        } else {
            // Notify via toast (only works in LEX)
            const toastEvent = new ShowToastEvent({ title, message, variant });
            this.dispatchEvent(toastEvent);
        }
    }
}