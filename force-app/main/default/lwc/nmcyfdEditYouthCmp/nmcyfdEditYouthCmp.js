import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import CONTRACT_ROLE_OBJECT from '@salesforce/schema/Contract_Role__c';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import DISCHARGE_REASON_FIELD from '@salesforce/schema/Contract_Role__c.Discharge_Reason__c';
import REASON_FIELD from '@salesforce/schema/Contract_Role__c.Reason__c';
import getClientPicklistValues from '@salesforce/apex/NM_CYFD_ActivityController.getClientPicklistFields';
import saveContractRole from '@salesforce/apex/NM_CYFD_ContractRoleController.saveContractRole';
import getContractRoleDetails from '@salesforce/apex/NM_CYFD_ContractRoleController.getContractRoleDetails';

export default class NmcyfdEditYouthCmp extends LightningElement {

    @api jcc;
    @api jjac;
    @api mentoring;
    @api member;
    @api contractRoleId;
    @api contractId;
    @track client = {};
    @track errorMsg = '';
    @track isInvalidRisk = false;
   
    // picklist
    @track suffixValues = [];
    @track livingArrangementsValues = [];
    @track schoolValues = [];
    @track employmentStatusValues= [];
    @track notInLaborForceValues = [];
    @track sourceOfIncomeValues = [];
    @track cyfdInvolvedValues = [];
    @track referralSourceValues = [];
    @track arrestInPast30DaysValues  = [];
    @track healthInsuranceValues = []; 
    @track genderValues = [];
    @track mcoValues = [];
    @track primaryLanguageValues = []; 
    @track ethnicityValues = [];
    @track tribalAffiliationValues  = [];
    @track otherTribalAffiliationValues = [];
    @track dischargeReasonValues = []; 
    @track reasonValues = [];
    @track messageValues = [];
    @track raceValues  = [];
    @track otherPhoneMessageValue = [];
    @track educationValues = [];
    @track lgbtqValues = [];
    @track populationServedValues = [];
    @track atRiskFactorsValues = [];
    @track selectedAtRiskFactors = [];
    @track selectedRace = [];
    @track selectedPopulationServed = [];
    //newly added for JJAC
    @track geographicLocationValues = [];
    @track otherPopulationValues = [];
    @track gangActivityValues = [];
    @track currentlyInDetentionValues = [];

     //Variables for checkboxes
     @track isNotHomeless = true;

     @wire(getObjectInfo, {objectApiName: CONTRACT_ROLE_OBJECT })
     accountInfo;
 
     @track reasonOptions = [] ;
     @track dischargeReasonOptions = [];
 
     @wire(getPicklistValues, {recordTypeId: '$accountInfo.data.defaultRecordTypeId', fieldApiName: REASON_FIELD })
     reasonInfo({ data, error }) {
         if (data) this.reasonData = data;
     }
     @wire(getPicklistValues, {recordTypeId:'$accountInfo.data.defaultRecordTypeId', fieldApiName: DISCHARGE_REASON_FIELD })
     dischargeReasonInfo({ data, error }) {
         if (data) this.dischargeReasonOptions = data.values;
     }
     handleDischargeReasonChange(event) {
         let key = this.reasonData.controllerValues[event.target.value];
         this.reasonOptions = this.reasonData.values.filter(opt => opt.validFor.includes(key));
         this.client[event.target.name] = event.target.value;
     }

     handleRiskFactorsSelection(event) {
        this.selectedAtRiskFactors = event.detail;
        var selectedOptions = this.template.querySelector('c-multiselect_picklist').getselectedValues();
        this.client['atRiskFactors'] = selectedOptions;
    }

     connectedCallback(){
        var grant= '';
        grant = this.jcc ? 'JCC' : 'Mentoring';
        getClientPicklistValues({grant : grant}).then(result =>{           
            this.suffixValues = result.suffixValues;
            this.livingArrangementsValues = result.livingArrangementsValues;
            this.schoolValues = result.schoolValues;
            this.employmentStatusValues= result.employmentStatusValues;
            this.notInLaborForceValues = result.notInLaborForceValues;
            this.sourceOfIncomeValues = result.sourceOfIncomeValues;
            this.cyfdInvolvedValues = result.cyfdInvolvedValues;
            this.referralSourceValues =result.referralSourceValues;
            this.arrestInPast30DaysValues  =result.arrestInPast30DaysValues;
            this.healthInsuranceValues = result.healthInsuranceValues;
            this.genderValues = result.genderValues;
            this.mcoValues = result.mcoValues;
            this.primaryLanguageValues = result.primaryLanguageValues;
            this.ethnicityValues = result.ethnicityValues;
            this.tribalAffiliationValues  = result.tribalAffiliationValues;
            this.otherTribalAffiliationValues = result.otherTribalAffiliationValues;
            this.dischargeReasonValues = result.dischargeReasonValues;
            this.reasonValues = result.reasonValues;
            this.messageValues = result.messageValues;
            this.raceValues  = result.raceValues;
            this.otherPhoneMessageValue = result.otherPhoneMessageValue;
            this.educationValues = result.educationValues;
            this.otherPhoneMessageValues = result.otherPhoneMessageValues;
            this.sexualPreferrenceValues = result.sexualPreferrenceValues;
            this.lgbtqValues = result.lgbtqValues;
            this.populationServedValues = result.populationServedValues;
            this.atRiskFactorsValues = result.atRiskFactorsValues;

            this.geographicLocationValues = result.geographicLocationValues;
            this.otherPopulationValues = result.otherPopulationValues;
            this.gangActivityValues = result.gangActivityValues;
            this.currentlyInDetentionValues = result.currentlyInDetentionValues;


        }).catch(error=>{
            console.log('error --> ', error);
        });
        if(this.contractRoleId){
            getContractRoleDetails({contractRoleId : this.contractRoleId}).then(result =>{
                this.client = result.roleData;
                if(this.client.homeless){
                    this.isNotHomeless = false;
                }
            }).catch(error=>{
                console.log('error --> ', error);
            });
        }
        
     }


   
    handleInputChange(event){
        if(event.target.name == 'noSSN'){
            this.client[event.target.name] = event.target.checked;
        }else if(event.target.name == 'hasMedicalId'){
            this.client[event.target.name] = event.target.checked;
        }else if(event.target.name == 'homeless'){
            this.client[event.target.name] = event.target.checked;
            //this.checkboxValidations();   
            this.isNotHomeless = !event.target.checked ;              

        }else if(event.target.name == 'noPhone'){
            this.client[event.target.name] = event.target.checked;
        }else if(event.target.name == 'status'){
            this.client[event.target.name] = event.target.checked;
        }else{
            this.client[event.target.name] = event.target.value;
        }
        console.log('event.target.name ', event.target.name + ' ' + event.target.value);
        console.log('gangActivity ', this.client['gangActivity']);
    }


    saveRole(){
        //this.addNew = false;
        this.client.name = this.client.firstName + ' ' + this.client.lastName;
        let firstName = this.template.querySelector(".firstName");
        let lastName = this.template.querySelector(".lastName");
        var dob = this.template.querySelector(".dob");
        var referralSource = this.template.querySelector(".referralSource");
        var gender = this.template.querySelector(".gender");
        var ethnicity = this.template.querySelector(".ethnicity");
        var race = this.template.querySelector(".race");
        var city = this.template.querySelector(".city");
        var state = this.template.querySelector(".state");
        var addressLine1 = this.template.querySelector(".addressLine1");
        var zipCode = this.template.querySelector(".zipCode");
        
        var riskFactors = this.client['atRiskFactors'];
        
        var isFirstNameValid = firstName.reportValidity();
        var isLastNameValid = lastName.reportValidity();
        var isdobValid =  dob.reportValidity();     
        if(!this.jjac)
            var isReferralSourceValid = referralSource.reportValidity();

        
        var isGenderValid = gender.reportValidity();
        var isEthnicityValid = ethnicity.reportValidity();
        var isRaceValid = race.reportValidity();
        var isStateValid = state.reportValidity();
        var isCityValid = city.reportValidity();
        var isZipCodeValid = zipCode.reportValidity();
        var isAddressLine1Valid = addressLine1.reportValidity();
        if(!riskFactors){
            this.isInvalidRisk = true;
        }else{
            this.isInvalidRisk = false;
        }
       
       
        if(this.client.dob){
            var age = this.calculateAge(this.client.dob);
            if(this.jcc){
                if(!(age >= 10 && age <=21)){
                    dob.setCustomValidity("Youth must be between the ages of 10 and 21");
                }else{
                    dob.setCustomValidity("");
                }
            }else if(this.mentoring){
                if(!(age >= 5 && age <=18)){
                    dob.setCustomValidity("Youth must be between the ages of 5 and 18 ");
                    }
                    else{
                        dob.setCustomValidity("");
                    }
            }else if(this.jjac){
                if(!(age >= 9 && age <=19)){
                    dob.setCustomValidity("Youth must be between the ages of 10 and 19");
                }
                else{
                    dob.setCustomValidity("");
                }
            }
            
        }
        isdobValid =  dob.reportValidity();
        var fN = this.client.firstName;
        var lN = this.client.lastName;
        var db = this.client.dob;  
        var valid = false;
        if(isFirstNameValid && isLastNameValid  && isdobValid && isRaceValid && isEthnicityValid
            && isGenderValid && isStateValid && isCityValid
            && isZipCodeValid && isAddressLine1Valid){
                if(this.mentoring){
                    var initialRegistrationDate = this.template.querySelector(".initialRegistrationDate");
                    var isInitialRegistrationDateValid = initialRegistrationDate.reportValidity();
                    if(isInitialRegistrationDateValid && !this.isInvalidRisk && isReferralSourceValid ){
                        
                        valid = true;
                    }
                }else if (this.jcc){
                    var populationServed = this.template.querySelector(".populationServed");
                    var isPopulationServedValid = populationServed.reportValidity();
                    var livingArrangements = this.template.querySelector(".livingArrangements");
                    var isLivingArrangementsValid = livingArrangements.reportValidity();
                    var localSelectionPanelDate = this.template.querySelector(".localSelectionPanelDate");
                    var isLocalSelectionPanelDateValid = localSelectionPanelDate.reportValidity();

                    if(isPopulationServedValid && isLivingArrangementsValid 
                        && isLocalSelectionPanelDateValid && isReferralSourceValid )
                        valid = true;
                }
                else if(this.jjac){
                    var isGangActivityValid = this.template.querySelector(".gangActivity").reportValidity();
                    var isCurrentlyInDetentionValid = this.template.querySelector(".currentlyInDetention").reportValidity();
                    var isGeographicLocationValid = this.template.querySelector(".geographicLocation").reportValidity();
                    if(isGeographicLocationValid && isCurrentlyInDetentionValid && isGangActivityValid)
                        valid = true;
                }
            }
        if(valid){
           this.saveClientData();    
        } else
            return false;
    }

    calculateAge(date) {
        var Bday = +new Date(date);
        var age = ~~((Date.now() - Bday) / (31557600000));
        return age;
    }

    saveClientData(){
        saveContractRole({roleJSON : JSON.stringify(this.client), roleType : 'Client', contractId : this.contractId, contractRoleId : this.contractRoleId}).then(result =>{
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
        
        }).catch(error=>{
            console.log('error --> ', error);
        });
    }

    handleClose(){
        const custEvent = new CustomEvent(
            'close', {
                detail: ''
            });
        this.dispatchEvent(custEvent);
    }
}