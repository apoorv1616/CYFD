import { LightningElement, track, api, wire} from 'lwc';
import getExistingMembers from '@salesforce/apex/NM_CYFD_ActivityController.getExistingMembers';
import getClientPicklistValues from '@salesforce/apex/NM_CYFD_ActivityController.getClientPicklistFields';
import checkDuplicateContractRole from '@salesforce/apex/NM_CYFD_ActivityController.checkDuplicateContractRole';
//import saveContractRole from '@salesforce/apex/NM_CYFD_ActivityController.saveContractRole';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import CONTRACT_ROLE_OBJECT from '@salesforce/schema/Contract_Role__c';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import DISCHARGE_REASON_FIELD from '@salesforce/schema/Contract_Role__c.Discharge_Reason__c';
import REASON_FIELD from '@salesforce/schema/Contract_Role__c.Reason__c';

export default class NmcyfdAddClientStep extends LightningElement {

    @track clients = [];
    @track existingMembers = [];
    @track selectedIds = [];
    @track searchValue = '';

    @track addExisting = false;
    @track addNew = false;
    @track heading = '';
    @track showSpinner = false;
    @api contractId;
    @api contract;
    @api month;
    @api activityData;
    @api activityLabel;
    @track selectedRoleId;
    @track selectedRole;
    @track newMember = {};
    @track isEditMode = false;
    @track index;
    @track saveButton1 = false;
    @track saveButton2 = false;
    @track errorMsg = '';

    @api jccUser;
    @api mentoringUser;
    @api numberOfYouth;
    @api matchEnabled;
    @api jjac;
    @api jcc;
    @api mentoring;
    @api grant;
    
    @track suffixValues = [];
    @track preferredPronounsOptions = [];
    @track livingArrangementsValues = [];
    @track schoolValues = [];
    @track employmentStatusValues= [];
    @track notInLaborForceValues = [];
    @track sourceOfIncomeValues = [];
    @track cyfdInvolvedValues = [];
    @track referralSourceValues = [];
    //@track criminalJusticeReferralValues = []; 
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
    //@track statusOfClientValues  = [];
    @track messageValues = [];
    @track raceValues  = [];
    @track otherPhoneMessageValue = [];
    @track educationValues = [];
    @track lgbtqValues = [];
    @track populationServedValues = [];
    @track atRiskFactorsValues = [];
    @track selectedAtRiskFactors = [];

    //newly added for JJAC
    @track geographicLocationValues = [];
    @track otherPopulationValues = [];
    @track gangActivityValues = [];
    @track currentlyInDetentionValues = [];

    @api unitType;
    @api activityType;
    @api staffLength;
    @track isInvalidRisk = false;
    @track addNewButtonDisabled = false;
   

    @track selectedRace = [];
    @track selectedPopulationServed = [];

    //Variables for checkboxes
    @track isNotHomeless = true;

    @wire(getObjectInfo, {objectApiName: CONTRACT_ROLE_OBJECT })
    accountInfo;

    @track reasonOptions;
    @track dischargeReasonOptions;

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
        this.newMember[event.target.name] = event.target.value;
    }

    @api returnData(){
        return this.clients;
    }

    connectedCallback(){
        var selectedRoles = this.formData();
        var activityLabel = ''
        if(this.activityLabel == 'Initial Casey Life Skills Assessment and Service Plan' 
        || this.activityLabel == 'Closing Casey Life Skills Assessment and Discharge Plan'){
            this.addNewButtonDisabled = true;
            activityLabel = this.activityLabel;
        }
        this.showSpinner = true;
        //alert('this.grant ' , this.grant);
        getExistingMembers({type : this.grant + ' client', contractId : this.contractId, activityLabel : activityLabel}).then(result =>{
            this.existingMembers = result;
            if(selectedRoles && selectedRoles.length>0){
                for(var i=0; i<this.existingMembers.length; i++){
                    
                    if(selectedRoles.includes(this.existingMembers[i].roleId)){
                        this.existingMembers.splice(i, 1);
                        i--;
                    }
                }     
            }
        
        }).catch(error=>{
            this.showSpinner = false;
            console.log('error --> ', error);
        });

       
        getClientPicklistValues({grant : this.grant}).then(result =>{           
            this.suffixValues = result.suffixValues;
            this.preferredPronounsOptions = result.preferredPronounsOptions;
            this.livingArrangementsValues = result.livingArrangementsValues;
            this.schoolValues = result.schoolValues;
            this.employmentStatusValues= result.employmentStatusValues;
            this.notInLaborForceValues = result.notInLaborForceValues;
            this.sourceOfIncomeValues = result.sourceOfIncomeValues;
            this.cyfdInvolvedValues = result.cyfdInvolvedValues;
            this.referralSourceValues =result.referralSourceValues;
            //this.criminalJusticeReferralValues = result.criminalJusticeReferralValues;
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
            //this.statusOfClientValues  = result.statusOfClientValues;
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
        this.formData();
    }

    formData(){
        if(this.activityData.length != 0){
            this.clients = JSON.parse(JSON.stringify(this.activityData));
            var ids = [];
            this.activityData.forEach(function(member){
                ids.push(member.roleId);
            });
            this.selectedIds = ids;
        }  
        this.showSpinner = true;
        this.fetchExistingClientMembers();  
    }

    fetchExistingClientMembers(){
        getExistingMembers({type : this.grant + ' client', contractId : this.contractId, searchKey : this.searchValue, selectedIds : this.selectedIds}).then(result =>{
            this.existingMembers = result;
            this.showSpinner = false;
            
        }).catch(error=>{
            this.showSpinner = false;
            console.log('error --> ', error);
        });
    }

    addExistingMember(){
        this.addExisting = true;
        this.addNew = false;
        this.heading = 'Add Existing Clients';
        this.showSpinner = true;

        this.fetchExistingClientMembers();  
    }

    searchKeyword(event){
        this.searchValue = event.target.value;
        this.showSpinner = true;

        this.fetchExistingClientMembers();
    }

    addNewMember(){
        if(!this.isEditMode){
            this.newMember = {};
            this.selectedAtRiskFactors = [];
            this.isNotHomeless = true;  
        }   
              
        this.addExisting = false;
        this.addNew = true;
        this.heading = 'Add Clients';
    }
    handleSelection(event){
        var roleId = event.target.name;
        var checked = event.target.checked;
        for(var i=0; i<this.existingMembers.length; i++){
            if(this.existingMembers[i].roleId == roleId){
                this.existingMembers[i].selected = checked;
            }
        } 
    }

    handleCloseModal(){
        this.addExisting = false;
        this.addNew = false;
        this.isEditMode = false;
        this.searchValue = '';
    }

    handleInputChange(event){
        // if(event.target.name == 'noSSN'){
        //     this.newMember[event.target.name] = event.target.checked;
        // }else if(event.target.name == 'hasMedicalId'){
        //     this.newMember[event.target.name] = event.target.checked;
        // }else if(event.target.name == 'homeless'){
        //     this.newMember[event.target.name] = event.target.checked;
        //     //this.checkboxValidations();   
        //     this.isNotHomeless = !event.target.checked ;              

        // }else if(event.target.name == 'noPhone'){
        //     this.newMember[event.target.name] = event.target.checked;
        // }else if(event.target.name == 'status'){
        //     this.newMember[event.target.name] = event.target.checked;
        // }else{
        //     this.newMember[event.target.name] = event.target.value;
        // }

        /*  
            * Author : Apoorv Anand
            * Desc   : Above hard-coded lines are commented as below code can be used to dynamically assign the values.
        */ 
        if ( event.target.type === 'checkbox') {
            this.newMember[event.target.name] = event.target.checked;
        }
        else if ( event.target.value.trim() ) {
            this.newMember[event.target.name] = event.target.value.trim();
        }
    }

    addExistingClients(){
        this.selectedIds = [];
        this.saveButton1 = false;
        this.addExisting = false;
       
        for(var i=0; i<this.existingMembers.length; i++){
            if(this.existingMembers[i].selected){
                this.selectedIds.push(this.existingMembers[i].roleId);
                this.clients.push(this.existingMembers[i]);
            }
        }
        this.searchValue = '';
        this.clients = this.removeDuplicates(this.clients, 'roleId');
    }

    removeDuplicates(originalArray, prop) {
        var newArray = [];
        var lookupObject  = {};
        for(var i in originalArray) {
            lookupObject[originalArray[i][prop]] = originalArray[i];
        }

        for(i in lookupObject) {
            newArray.push(lookupObject[i]);
        }
        return newArray;
    }

    handleNewRoleSave(){
        //this.addNew = false;
        this.newMember.name = this.newMember.firstName + ' ' + this.newMember.lastName;
        let firstName = this.template.querySelector(".firstName");
        let lastName = this.template.querySelector(".lastName");
        var dob = this.template.querySelector(".dob");
        
        var gender = this.template.querySelector(".gender");
        var ethnicity = this.template.querySelector(".ethnicity");
        var race = this.template.querySelector(".race");
        var city = this.template.querySelector(".city");
        var state = this.template.querySelector(".state");
        var addressLine1 = this.template.querySelector(".addressLine1");
        var zipCode = this.template.querySelector(".zipCode");

        var riskFactors = this.newMember['atRiskFactors'];
     
        var isFirstNameValid = firstName.reportValidity();
        var isLastNameValid = lastName.reportValidity();
        var isdobValid =  dob.reportValidity();  
        
       
        var isGenderValid = gender.reportValidity();
        var isEthnicityValid = ethnicity.reportValidity();
        var isRaceValid = race.reportValidity();
        var isStateValid = state.reportValidity();
        var isCityValid = city.reportValidity();
        var isZipCodeValid = zipCode.reportValidity();
        var isAddressLine1Valid = addressLine1.reportValidity();
        
        var referralSource = this.template.querySelector(".referralSource");  
        if(!this.jjac)
            var isReferralSourceValid = referralSource.reportValidity(); 
        var initialRegistrationDate = this.template.querySelector(".initialRegistrationDate");
        var isInitialRegistrationDateValid = initialRegistrationDate.reportValidity();

        if(!riskFactors){
            this.isInvalidRisk = true;
        }else{
            this.isInvalidRisk = false;
        }

        if(this.newMember.dob && this.newMember.initialRegistrationDate){
            var age = this.calculateAge(this.newMember.dob, this.newMember.initialRegistrationDate);
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
                console.log('this.isEditMode',this.isEditMode);
                //insert of new record
                if(!this.isEditMode) {
                    if(!(age >= 9 && age <18)){
                        dob.setCustomValidity("Youth must be between the ages of 10 and 17");
                    }
                    else{
                        dob.setCustomValidity("");
                    }
                }
                //edit of existing record
                else {
                    var age1 = this.calculateAge( this.newMember.dob, new Date());
                    if(!(age1 >= 9 && age1 <19)){
                        dob.setCustomValidity("Youth must be between the ages of 10 and 19");
                    }
                    else{
                        dob.setCustomValidity("");
                    }
                }
            }
            
        }
        
        isdobValid =  dob.reportValidity();
        var fN = this.newMember.firstName;
        var lN = this.newMember.lastName;
        var db = this.newMember.dob;  
        var valid = false;

        if(isFirstNameValid && isLastNameValid  && isdobValid && isRaceValid && isEthnicityValid
            && isGenderValid && isStateValid && isCityValid && isInitialRegistrationDateValid
            && isZipCodeValid && isAddressLine1Valid){
                if(this.mentoring){
                   if(!this.isInvalidRisk && isReferralSourceValid ){
                        valid = true;
                    }
                }else if (this.jcc){
                    var populationServed = this.template.querySelector(".populationServed");
                    var isPopulationServedValid = populationServed.reportValidity();
                    var livingArrangements = this.template.querySelector(".livingArrangements");
                    var isLivingArrangementsValid = livingArrangements.reportValidity();
                    var localSelectionPanelDate = this.template.querySelector(".localSelectionPanelDate");
                    var isLocalSelectionPanelDateValid = localSelectionPanelDate.reportValidity();

                    if(isPopulationServedValid && isLivingArrangementsValid && isLocalSelectionPanelDateValid && isReferralSourceValid )
                        valid = true;
                }else if(this.jjac){
                    /*
                        * Author  : Apoorv Anand
                        * Issue   : I-38309 
                        * Desc    : Make populationServed field valid for jjac also.
                    */
                    var populationServed = this.template.querySelector(".populationServed");
                    var isPopulationServedValid = populationServed.reportValidity();

                    var isGangActivityValid = this.template.querySelector(".gangActivity").reportValidity();
                    var isCurrentlyInDetentionValid = this.template.querySelector(".currentlyInDetention").reportValidity();
                    var isGeographicLocationValid = this.template.querySelector(".geographicLocation").reportValidity();
                    if(isPopulationServedValid && isGeographicLocationValid && isCurrentlyInDetentionValid && isGangActivityValid)
                        valid = true;
                }

            }
            
        if(valid){
            var err = false;
            this.errorMsg = ''
            checkDuplicateContractRole({type : 'client' , contractId : this.contractId, 
            name : this.newMember.name, dob : this.newMember.dob, roleId : this.newMember.roleId}).then(result =>{
               console.log('fbbjj ', result);
               if(result)
                err = true;

                if(err){
                    console.log('eerr');
                    this.errorMsg = 'Contract role with same details already exists.';
                   // return false;
                }else{
                    this.errorMsg = '';
                    this.addNew = false;
                    if(!this.isEditMode){
                        
                        this.clients.push(this.newMember);
                    }else{
                        this.newMember['name'] = this.newMember['firstName'] + ' ' + this.newMember['lastName'];
                        this.clients[this.index] = this.newMember;
                        this.isEditMode = false;
                    }
                }                

            }).catch(error=>{
                console.log('error --> ', error);
            });

            console.log('err ', err);
           /* this.existingMembers.forEach(function(member){
                if(member.firstName == fN && 
                    member.lastName == lN &&
                    member.dob == db){
                    err = true;
                }
            });
            for(var i=0; i<this.clients.length; i++){
                var member = this.clients[i];
                if(i != this.index){
                    if(member.firstName == fN && 
                        member.lastName == lN &&
                        member.dob == db){

                        err = true;
                    }
                }
            }*/
        }  
    }

    // checkRequiredComponents() {
    //     let valid = false;
    //     let isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
    //         input.reportValidity();
    //         return validSoFar && input.checkValidity();
    //     }, true);
    //     let isAllValidCheckbox = [...this.template.querySelectorAll('lightning-combobox')].reduce((validSoFar, input) => {
    //         input.reportValidity();
    //         return validSoFar && input.checkValidity();
    //     }, true);
    //     valid = isAllValid && isAllValidCheckbox;
    //     console.log('valid : ' + valid);
    //     return valid;
    // }

    calculateAge(date, date2) {
        var Bday = +new Date(date);
        var initialRegDate = +new Date(date2);
        var age = ~~((initialRegDate - Bday) / (31557600000));
        console.log('age',age);
        return age;

        // Below one is the single line logic to calculate the no. of years...
        // var years = new Date(date - new Date(date2)).getFullYear() - 1970;
        // console.log('years : ',years);
        // return Integer.parseInt(years);

        // var ageDifMs = date - date2;
        // console.log('ageDifMs',ageDifMs);
        // var ageDate = new Date(ageDifMs); // miliseconds from epoch
        // console.log('ageDate',ageDate);
        // console.log('Math.abs(ageDate.getUTCFullYear() - 1970)',Math.abs(ageDate.getUTCFullYear() - 1970));
        

        //return Math.abs(ageDate.getUTCFullYear() - 1970);
    }

    handleEditRole(event){
        var index  = event.target.dataset.index;
        this.index = index;
        this.newMember = this.clients[index];
        var options = this.newMember['atRiskFactors'];
        this.isNotHomeless = !this.newMember.homeless ;    
        if(options){
            var values = options.split(';');
            this.selectedAtRiskFactors = [];
            values.forEach(item =>{
                this.selectedAtRiskFactors.push({label : item , value : item});
            });
        }
        this.isEditMode = true;
        this.addNewMember();
        
    }

    handleRemoveRole(event){
        var roleId = event.target.dataset.id;
        var index  = event.target.dataset.index;
        var role = this.clients[index];
        this.clients.splice(index, 1);
        for(var i=0; i<this.existingMembers.length; i++){
            if(this.existingMembers[i].roleId == roleId){
                this.existingMembers[i].selected = false;
            }
        }
        
        var ind = this.selectedIds.indexOf(roleId);
        if(ind > -1)
            this.selectedIds.splice(ind, 1);
    }

    handleRiskFactorsSelection(event) {
        this.selectedAtRiskFactors = event.detail;
        var selectedOptions = this.template.querySelector('c-multiselect_picklist').getselectedValues();
        this.newMember['atRiskFactors'] = selectedOptions;
    }

    @api 
    isValid(){
        var msg ;
        
        if(this.clients.length != this.numberOfYouth){
            msg = 'Please add a total of ' + this.numberOfYouth + ' youth/s';
        }
        
        
        if(msg){
            const event = new ShowToastEvent({
                title: '',
                message: msg,
                variant :'error'
            });
            this.dispatchEvent(event);
            return false;
        }else{
            this.clients.forEach(function(member){
                if(!member.status){
                    msg = 'One or more youths are in inactive status.'
                }
            });

            if(msg){
                const event = new ShowToastEvent({
                    title: '',
                    message: msg,
                    variant :'error'
                });
                this.dispatchEvent(event);
                return false;
            }
            
            return true;
        }
    
    }



}