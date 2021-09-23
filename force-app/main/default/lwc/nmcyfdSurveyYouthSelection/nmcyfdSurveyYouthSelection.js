import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getYouthDataForSurvey from '@salesforce/apex/NM_CYFD_SubmitSurveyController.getYouthDataForSurvey'
export default class NmcyfdSurveyYouthSelection extends NavigationMixin(LightningElement){

    @track contractRole = [];
    @track searchTerm = '';
    @api contractId ;

    //Retriving All the Contact Role records from apex method getYouthDataForSurvey to display in Table.
    connectedCallback(){
        console.log("Searching...Data",this.searchTerm, 'contractId ', this.contractId);
        getYouthDataForSurvey({searchKey : this.searchTerm, contractId : this.contractId}).then(data =>{
            console.log("Data ",data);
            this.contractRole = data;
        }).catch(error=>{
            console.log("Error ", error);
        });
    }

    // When Input Text Change, this method call apex class method(getYouthDataForSurvey) to retrive data matched with input text.
    onChange(event){
        console.log("Inside onChange");
        if(event.target.name == 'clientName'){
            this.searchTerm = event.target.value;
        }
        getYouthDataForSurvey({searchKey : this.searchTerm, contractId : this.contractId}).then(data =>{
             this.contractRole = data;         
             
         }).catch(error=>{
             console.log('error', error);
         });
    }

    onYouthClick(event){
        console.log('dbhfy ', event.target.dataset.youthId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
                attributes: {
                    recordId: event.target.dataset.youthId,
                    objectApiName: 'Contract_Role__c',
                    actionName: 'view'
                },
        });

    }

    onStartSurveyClick(event){
        var roleId = event.target.dataset.youthId;
        console.log('role id ' + roleId);
        this.dispatchEvent(new CustomEvent('youthselect', {detail: roleId}));       

    }
    onContinueSurveyClick(event){
        var surveyId = event.target.dataset.surveyId;
        console.log('role id ' + surveyId);
        this.dispatchEvent(new CustomEvent('continuesurvey', {detail: surveyId}));       

    }
}