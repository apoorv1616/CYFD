import { LightningElement ,track,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPicklistFields from '@salesforce/apex/NM_CYFD_SubmitSurveyController.getPicklistFields';
import getYouthData from '@salesforce/apex/NM_CYFD_SubmitSurveyController.getYouthData';

export default class NmcyfdFederalYouthSurvey extends LightningElement {
    response={};
    @track dataObj = {};
    @api mentoring;
    @api jcc;
    @api jjac;
    @api response;
    @api surveyId;
    @track programValues = [];
    @api youthId;
    @api contractId ;

    get options() {
        return [
            { label: 'Agree', value: 'Agree' },
            { label: 'Stayed Same', value: 'Stayed Same'},
            { label: 'Disagree', value: 'Disagree' },
            { label: 'Unsure', value: 'Unsure' },
        ];
    }
    get options2() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No'},
            { label: 'Not Applicable', value: 'Not Applicable' }
        ];
    }

    get options3() {
        return [
            { label: 'Agree', value: 'Agree' },
            { label: 'Stayed Same', value: 'Stayed Same'},
            { label: 'Disagree', value: 'Disagree' },
            { label: 'Unsure', value: 'Unsure' },
            { label: 'Not Applicable', value: 'Not Applicable' },
        ];
    }

    changeHandler(event){
        this.dataObj[event.target.name] = event.target.value;
    }

    connectedCallback(event){

       /* if(this.response != undefined){
            this.dataObj = JSON.parse(JSON.stringify(this.response));
        }*/
        getPicklistFields({youthId : this.youthId, contractId : this.contractId}).then(data =>{
            this.programValues = data.programValues;
        }).catch(error=>{
            console.error('error',error);
        });

        if(this.surveyId){
            getYouthData({surveyId : this.surveyId}).then(data =>{
                this.dataObj = data;
                console.log('dataObj---', this.dataObj.program);
                console.log('this.programValues ---', this.programValues);

            }).catch(error=>{
                console.error('error',error);

            });
        }
        
       
    }
    
    @api returnData(){
        var isValid=true;
        // if(!this.dataObj.program && this.jjac){
        //     const event = new ShowToastEvent({
        //         title: 'Warning',
        //         message: 'Please select a program!',
        //         variant :'warning'
        //     });
        //     this.dispatchEvent(event);
        // }else{
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
        //}
        
    }
    @api returnPartialData(){
        return this.dataObj;
    }
}