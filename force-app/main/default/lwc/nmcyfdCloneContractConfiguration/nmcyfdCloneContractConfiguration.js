import { LightningElement,api,track } from 'lwc';
import getPreviousConfiguration from '@salesforce/apex/NmcyfdCloneCCController.getPreviousConfiguration';
import saveContractConfiguration from '@salesforce/apex/NmcyfdCloneCCController.saveContractConfiguration';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class NmcyfdCloneContractConfiguration extends NavigationMixin(LightningElement)  {

    @api recordId;
    @track data = {};

    connectedCallback() {
        //this.recordId = window.location.href.match(/[a-z0-9]\w{4}0\w{12}|[a-z0-9]\w{4}0\w{9}/g)[0];
        if (this.recordId) {

            this.getPreviousConfiguration();
        }
    }

    getPreviousConfiguration() {

        getPreviousConfiguration({
            recordId : this.recordId
        })
        .then(result => {
            if (result) {
                this.data = JSON.parse(JSON.stringify(result));
            }
            else {
                this.ShowToastEvent('No Record Found!','','error');
            }

        })
        .catch(error => {
            let err = error.message || error.body.message;
            console.log('error-->',JSON.stringify( err ));
            this.ShowToastEvent(err,'','error');
        }); 
    }

    handleChange(event) {
        this.data[event.target.name] = event.target.value;
    }

    handleSave() {

        this.saveContractConfiguration();
    }

    saveContractConfiguration() {

        saveContractConfiguration({
            recordId : this.recordId,
            wrapperData : JSON.stringify(this.data)
        })
        .then(result => {
            if (result) {
                let clonedId = JSON.parse( JSON.stringify( result ) );
                this.ShowToastEvent('Success!','','success');
                
                this.navigateToContractConfiguration( clonedId );
            }
            else {
                this.ShowToastEvent('No Record Found!','','error');
            }
        })
        .catch(error => {
            let err = error.message || error.body.message;
            console.log('error-->',JSON.stringify( err ));
            this.ShowToastEvent(err,'','error');
        });
    }

    handleCancel() {

        this.navigateToContractConfiguration( this.recordId );
    }

    //Toast 
    ShowToastEvent(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    //navigation
    navigateToContractConfiguration( recordId ) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Contract_Configuration__c',
                actionName: 'view'
            }
        });
    }

}