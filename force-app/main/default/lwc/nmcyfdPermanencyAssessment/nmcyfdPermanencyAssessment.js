import { LightningElement ,track,api} from 'lwc';
import getAssessments from '@salesforce/apex/NM_CYFD_SubmitAssessmentController.getAssessment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class NmcyfdPermanencyAssessment extends LightningElement {

    @track dataObj=  {};
    @api assessmentId;
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
        console.log('assessmentId ** ', this.assessmentId)
        getAssessments({stepNumber : '2',assessmentId:this.assessmentId}).then(data=>{
            console.log('data '+JSON.stringify(data));
            this.dataObj = data;
            //this.dataObj = data;

        }).catch(error=>{
            console.log('error '+JSON.stringify(error));
        });

    }
    changeHandler(event){
        this.dataObj[event.target.name] = event.target.value;
        console.log(JSON.stringify(this.dataObj));
    }

    @api returnData(){
        var isValid=true;
        this.template.querySelectorAll('lightning-radio-group').forEach(element => {
            if(!element.value){
                isValid=false;
            }
            
        });
        if(isValid){
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