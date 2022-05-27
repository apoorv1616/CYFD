import { LightningElement ,track,api} from 'lwc';
import getAssessments from '@salesforce/apex/NM_CYFD_SubmitAssessmentController.getAssessment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NmcyfdPermanencyAssessment extends LightningElement {

    response ={};
    @track dataObj = {};
    @api assessmentId;
    @api options;
    @api currentStep;
    @api questionLabel;
    @api totalStepsCount;


    // get options() {
    //     return [
    //         { label: 'No', value: '1' },
    //         { label: 'Mostly No', value: '2' },
    //         { label: 'Somewhat', value: '3' },
    //         { label: 'Mostly Yes', value: '4'},
    //         { label: 'Yes', value: '5' },
    //     ];
    // }
    @api assessmentQuestions;


    connectedCallback(){

        getAssessments({stepNumber : this.currentStep,assessmentId:this.assessmentId}).then(data=>{
            this.dataObj = JSON.parse(JSON.stringify(data));

            let assessmentQuestions = JSON.parse(JSON.stringify(  this.assessmentQuestions ));
            assessmentQuestions.map( item =>  {
                if ( this.dataObj.hasOwnProperty(item.Assement_API__c)) {
                    item['value'] = this.dataObj[item.Assement_API__c]

                }
            } );
            this.assessmentQuestions = JSON.parse(JSON.stringify(  assessmentQuestions ));


        }).catch(error=>{
            let msg = error.message || error.body.message;
            const event = new ShowToastEvent({
                title: 'Error',
                message: msg,
                variant :'error'
            });
            this.dispatchEvent(event);
        });

    }
    changeHandler(event){
        this.dataObj[event.target.name] = event.target.value;
    }

    @api returnData(){
        var temp=false;
        this.template.querySelectorAll('lightning-radio-group').forEach(element => {
            if(!element.value){
                temp=true;
                if ( !element.checkValidity() ) {
                    element.reportValidity();
                }
            }
            
        });
        if(!temp){
            this.dataObj.success = 'true';
            return this.dataObj;
        }
        else{
            this.dataObj.success = 'false';
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Please Complete the mandatory Questions!',
                variant :'error'
            });
            this.dispatchEvent(event);
            return this.dataObj;

        }
    }
    @api 
    returnPartialData(){
        return this.dataObj;

    }
}