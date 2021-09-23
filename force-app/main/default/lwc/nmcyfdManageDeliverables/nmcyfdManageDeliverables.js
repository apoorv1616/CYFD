import { LightningElement, track } from 'lwc';
import getContractDetails from '@salesforce/apex/NM_CYFD_ContractController.getContractRecord';
import getActivities from '@salesforce/apex/NM_CYFD_ContractController.getContractActivities';
import statusUpdate from '@salesforce/apex/NM_CYFD_ContractController.updateContractActivityStatus';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NmcyfdManageDeliverables extends NavigationMixin(LightningElement){

    @track contractId;
    @track contract;
    @track contractActivities=[];
    @track contractName;

    connectedCallback(){
        let testURL = window.location.href;
        let newURL = new URL(testURL).searchParams;
        this.contractId = newURL.get('contractId');

        getContractDetails({contractId : this.contractId}).then(data =>{
            
            if(data){
                this.contract  = data;
                console.log('contract ', JSON.stringify(this.contract));
                this.contractName=this.contract.Name__c;
            } 
        }).catch(error=>{
            console.log('error', error);
        });

        getActivities({contractId : this.contractId}).then(data=>{

            if(data){
                this.contractActivities = data.Activities;
                console.log('contractActivities ', JSON.stringify(this.contractActivities));
            }
        }).catch(error=>{
            console.log('error ',error.body.message);
        })
    }

    get acceptedFormats() {
        return ['.pdf', '.png'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        console.log('hi '+JSON.stringify(event.detail.files));
        var index=event.target.dataset.id;
        console.log('id '+index);
        console.log(this.contractActivities[index].activityName);
        this.contractActivities[index].docName = event.detail.files[0].name;
        this.contractActivities[index].Status = 'Submitted';
        //this.contractActivities[index].activityId = event.detail.files[0].documentId;
        console.log('name '+JSON.stringify(this.contractActivities[index]));
        var actId = this.contractActivities[index].activityId
        statusUpdate({activityId : actId ,status : 'Submitted'}).then(data=>{
            console.log('data '+ JSON.stringify(data));
            if(data)
            {
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'Uploaded file successfully',
                    variant : 'success'
                });
                this.dispatchEvent(event);
            }

        }).catch(error=>{
            console.log('error ',error.body.message);
        })
        //alert("No. of files uploaded : " + uploadedFiles.length);

    }

    handleBackToContract(event){
        this[NavigationMixin.Navigate]({
            /*type: 'comm__namedPage',
            attributes: {
                pageName: 'my-contracts'
            },
            state: {
                'contractId': this.contractId
               }*/

            type: 'standard__recordPage',
            attributes: {
                recordId: this.contractId,
                objectApiName: 'Contract__c',
                actionName: 'view'
            },
        });
    }
}