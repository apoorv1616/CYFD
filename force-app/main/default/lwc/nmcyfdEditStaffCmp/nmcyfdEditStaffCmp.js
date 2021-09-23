import { LightningElement, track, api } from 'lwc';
import getPicklistValues from '@salesforce/apex/NM_CYFD_ActivityController.getStaffPicklistFields';
import saveContractRole from '@salesforce/apex/NM_CYFD_ContractRoleController.saveContractRole';
import getContractRoleDetails from '@salesforce/apex/NM_CYFD_ContractRoleController.getContractRoleDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NmcyfdEditStaffCmp extends LightningElement {

    @api jcc;
    @api jjac;
    @api mentoring;
    @api member;
    @api contractRoleId;
    @track staff = {};
    @track errorMsg = '';
    @track educationValues = [];
    @track backgroundValues = [];
    @track genderValues = [];

    connectedCallback(){
        console.log('fnjfbf , ' , this.contractRoleId);
        getContractRoleDetails({contractRoleId : this.contractRoleId}).then(result =>{
            console.log('dbdbhbhf' + JSON.stringify(result.roleData));
            this.staff = result.roleData;
        }).catch(error=>{
            console.log('error --> ', error);
        });
        getPicklistValues({}).then(result =>{

            this.educationValues = result.education;
            this.backgroundValues = result.backgroundCheck;
            this.genderValues = result.gender;
        
        }).catch(error=>{
            console.log('error --> ', error);
        });
        
        
        
    }

    handleInputChange(event){

        if(event.target.name == 'status'){
            this.staff[event.target.name] = event.target.checked;
        }else{
            console.log()
            this.staff[event.target.name] = event.target.value;
        }
    }


    saveRole(){
        let firstName = this.template.querySelector(".firstName");
        let lastName = this.template.querySelector(".lastName");
        var dob = this.template.querySelector(".dob");
        var backgrndCheck = this.template.querySelector(".backgroundCheck");
        var jobTitle = this.template.querySelector(".jobTitle");
        var isFirstNameValid;
        var isLastNameValid;
        var isdobValid;
        var isBackgrndCheck;
        var isJobTitleValid;
        
        isFirstNameValid = firstName.reportValidity();
        isLastNameValid = lastName.reportValidity();
        isdobValid =  dob.reportValidity();
        isBackgrndCheck =  backgrndCheck.reportValidity();
        isJobTitleValid =  jobTitle.reportValidity();      
        console.log('jsin  ', JSON.stringify(this.staff))
        if(isFirstNameValid && isLastNameValid && isdobValid && isBackgrndCheck && isJobTitleValid){
            saveContractRole({roleJSON : JSON.stringify(this.staff), roleType : 'Staff', contractRoleId : this.contractRoleId}).then(result =>{
                var variant ;
                if(result.success)
                    variant = 'success';
                else 
                    variant = 'error';
                var msg = result.msg;

                const event = new ShowToastEvent({
                    title: '',
                    message: msg,
                    variant : variant
                });
                this.dispatchEvent(event);
                this.handleClose();
                window.reload();
            
            }).catch(error=>{
                console.log('error --> ', error);
            });
        }else
            return false;
    }

    handleClose(){
        const custEvent = new CustomEvent(
            'close', {
                detail: ''
            });
        this.dispatchEvent(custEvent);
    }
}