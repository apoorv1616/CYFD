import { LightningElement ,track,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getStaffData from '@salesforce/apex/NM_CYFD_SubmitSurveyController.getStaffData';

export default class NmcyfdFederalStaffSurvey extends LightningElement {
    response={};
    @track dataObj = {};
    @api mentoring;
    @api jcc;
    @api jjac;
    @api response;
    @api surveyId;
    @api noSurveyAvailable;

    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No'},
            { label: 'Not Applicable', value: 'Not Applicable' },
        ];
    }

    get isYouthNoSurvey() {

        return this.noSurveyAvailable === 'Youth';
    }

    changeHandler(event){
        this.dataObj[event.target.name] = event.target.value;
    }
    connectedCallback(event){
        console.log("Federal Servey Youth previous COnnected Call back ",  this.response);

        if (!this.noSurveyAvailable) {
            getStaffData({surveyId : this.surveyId}).then(data =>{
                this.dataObj = data;
            }).catch(error=>{
                console.log("Error ", error);
            });
        }
        //this.dataObj = JSON.parse(JSON.stringify(this.response));
        
    }
    @api returnPartialData(){
        return this.dataObj;
    }
    @api returnData(){
        
        var isValid=true;
        this.template.querySelectorAll('lightning-radio-group').forEach(element => {
            if(!element.value){
                isValid=false;
                if ( !element.checkValidity() ) {
                    element.reportValidity();
                } 
            }
            
        });
        if(isValid){
            this.dataObj.success = 'true';
            return this.dataObj;
        }
        else{
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Please Complete the mandatory Questions!',
                variant :'warning'
            });
            this.dispatchEvent(event);
        }
    }
}