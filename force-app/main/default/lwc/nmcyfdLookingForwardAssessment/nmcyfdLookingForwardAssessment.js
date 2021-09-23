import { LightningElement ,track,api} from 'lwc';
import getAssessments from '@salesforce/apex/NM_CYFD_SubmitAssessmentController.getAssessment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NmcyfdPermanencyAssessment extends LightningElement {

    response ={};
    @track dataObj = {};
    @api assessmentId
    get options() {
        return [
            { label: 'No', value: '1' },
            { label: 'Mostly No', value: '2' },
            { label: 'Somewhat', value: '3' },
            { label: 'Mostly Yes', value: '4'},
            { label: 'Yes', value: '5' },
        ];
    }

    connectedCallback(){

        getAssessments({stepNumber : '8',assessmentId:this.assessmentId}).then(data=>{
            console.log('data '+JSON.stringify(data));
            this.dataObj = data;
            //this.dataObj = data;

        }).catch(error=>{
            console.log('error '+JSON.stringify(error));
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
        }
    }
    @api 
    returnPartialData(){
        return this.dataObj;

    }
}