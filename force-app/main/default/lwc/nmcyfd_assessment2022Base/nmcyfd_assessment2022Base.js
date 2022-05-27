import { LightningElement,track,api } from 'lwc';
import getAllAssessmentQuestions from '@salesforce/apex/Nmcyfd_Assessment2022Controller.getAllAssessmentQuestions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Nmcyfd_assessment2022Base extends LightningElement {

    @track showSpinner = false;
    @api assessmentId;
    @api currentStep;
    @track result = [];
    @track naivgationSidebar = [];

    connectedCallback() {
        this.showSpinner = true;
        this.getAllAssessmentQuestions();
    }

    getAllAssessmentQuestions() {

        getAllAssessmentQuestions({

        })
        .then( result => {
            this.result = JSON.parse(JSON.stringify( result ));

            this.naivgationSidebar = this.result.reduce((acc,item) => {
                if (acc && !acc.includes(item.Section_Name__c)) {
                    acc.push(item.Section_Name__c)
                }
                return acc;
                
            }, []);
        })
        .catch( error => {
            let msg = error.message || error.body.message;
            console.log({error});
            this.showToast('Error',msg,'error');
        })
        .finally( () => {
            this.showSpinner = false;
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({  
              title: title,
              message: message,
              variant: variant
            })
          );
    }
}