import { LightningElement, track, api } from 'lwc';
import getExistingMembers from '@salesforce/apex/NM_CYFD_ActivityController.getExistingMembers';
//import saveContractRole from '@salesforce/apex/NM_CYFD_ActivityController.saveContractRole';
import getPicklistValues from '@salesforce/apex/NM_CYFD_ActivityController.getStaffPicklistFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NmcyfdAddStaffMembersStep extends LightningElement {

    @track staffMembers  = [];
    @track preferredPronounsOptions = [];
    @track existingMembers = [];
    @track addExisting = false;
    @track addNew = false;
    @track heading = '';
    @track showSpinner = false;
    @api contractId;
    @api contract;
    @api activityData;
    @api month;
    @track selectedRoleId;
    @track selectedRole;
    @track newMember = {};
    @track isEditMode = false;
    @track educationValues = [];
    @track backgroundValues = [];
    @track genderValues = [];
    @track index;
    @track saveButton1 = false;
    @track saveButton2 = false;
    @track errorMsg = '';
    @track selectedIds = [];
    @track searchValue = '';

    @api jccUser;
    @api mentoringUser;
    @api unitType;
    @api activityType;
    @api numberOfYouth;
    @api matchEnabled;
    @api skipStaff;

    @api returnData(){
        return this.staffMembers;
    }

    connectedCallback(){
        getPicklistValues({}).then(result =>{

            this.educationValues = result.education;
            this.backgroundValues = result.backgroundCheck;
            this.genderValues = result.gender;
            this.preferredPronounsOptions = result.preferredPronounsOptions;
        
        }).catch(error=>{
            console.log('error --> ', error);
        });  
        this.formData();
    }

    formData(){
        if(this.activityData.length != 0){
            this.staffMembers = JSON.parse(JSON.stringify(this.activityData));
            var ids = [];
            this.activityData.forEach(function(member){
                ids.push(member.roleId);
            });
            this.selectedIds = ids;
        }        
        this.fetchExistingStaffMembers();  
    }

    fetchExistingStaffMembers(){
        
        getExistingMembers({type : 'staff', contractId : this.contractId, searchKey : this.searchValue, selectedIds : this.selectedIds}).then(result =>{
            this.existingMembers = result;
        }).catch(error=>{
            console.log('error --> ', error);
        });
    }

    addExistingMember(){
        this.addExisting = true;
        this.addNew = false;
        this.heading = 'Add Existing Staff Members';
        this.fetchExistingStaffMembers();
    }   

    searchKeyword(event){
        this.searchValue = event.target.value;
        this.fetchExistingStaffMembers();
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

    handleInputChange(event){
        if(event.target.name == 'status'){
            this.newMember[event.target.name] = event.target.checked;
        }else{
            this.newMember[event.target.name] = event.target.value;
        }
    }

    addExistingStaffs(){
        this.selectedIds = [];
        this.saveButton1 = false;
        this.addExisting = false;
       
        for(var i=0; i<this.existingMembers.length; i++){
            if(this.existingMembers[i].selected){
                this.selectedIds.push(this.existingMembers[i].roleId);
                this.staffMembers.push(this.existingMembers[i]);
            }
        }
        this.searchValue = '';
        this.staffMembers = this.removeDuplicates(this.staffMembers, 'roleId');
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
        if(this.newMember.dob){
            console.log('age');
            var age = this.calculateAge(this.newMember.dob);
            console.log('age ', age);
            if((age < 16)){
                    dob.setCustomValidity("Minimum age for a Staff member is 16");
            }else{
                    dob.setCustomValidity("");
            }
            
        }
        isdobValid =  dob.reportValidity();
        if(isFirstNameValid && isLastNameValid && isdobValid && isBackgrndCheck && isJobTitleValid){
          console.log('fbfjj');
            var err = false;
            this.errorMsg = ''
            /*var fN = this.newMember.firstName;
            var lN = this.newMember.lastName;
            var db = this.newMember.dob;
            this.existingMembers.forEach(function(member){
                if(member.firstName == fN && 
                    member.lastName == lN &&
                    member.dob == db){
                    err = true;
                }
            });
            for(var i=0; i<this.staffMembers.length; i++){
                var member = this.staffMembers[i];
                if(i != this.index){
                    if(member.firstName == fN && 
                        member.lastName == lN &&
                        member.dob == db){
                        err = true;
                    }
                }
            }*/
            if(err){
                this.errorMsg = 'Duplicate contact';
               // return false;
            }else if(this.newMember.backgroundCheck == 'Not Authorized' || this.newMember.backgroundCheck == 'Pending'){
                this.errorMsg = 'This staff member is not authorized, and therefore the record can not be saved. Please consult your CYFD Program Manager if you need further clarification.';
            }else{
                this.errorMsg = '';
                this.addNew = false;
                if(!this.isEditMode){
                    this.newMember['name'] = this.newMember['firstName'] + ' ' + this.newMember['lastName'];
                    this.staffMembers.push(this.newMember);
                }else{
               
                    this.newMember['name'] = this.newMember['firstName'] + ' ' + this.newMember['lastName'];
                    this.staffMembers[this.index] = this.newMember;
                    this.isEditMode = false;
                }
            }
        }else
            return false;
    }

    handleEditRole(event){
        var index  = event.target.dataset.index;
        this.index = index;
        this.newMember = this.staffMembers[index];
        this.isEditMode = true;
        this.addNewMember();
        
    }

    handleRemoveRole(event){
        var roleId = event.target.dataset.id;
        var index  = event.target.dataset.index;
        var role = this.staffMembers[index];
        this.staffMembers.splice(index, 1);
        for(var i=0; i<this.existingMembers.length; i++){
            if(this.existingMembers[i].roleId == roleId){
                this.existingMembers[i].selected = false;
            }
        }
        
        var ind = this.selectedIds.indexOf(roleId);
        console.log('selected id inxed ' , ind);
        if(ind > -1)
            this.selectedIds.splice(ind, 1);
    }

    @api 
    isValid(){
        var msg = '';
        console.log('skip staff  ', this.skipStaff);
        if(!this.matchEnabled && !this.skipStaff){
            if(this.staffMembers.length<1 && (this.activityType != 'Group' || this.contract.Grant__c == 'JJAC')){
                msg = 'Please enter at least one Staff member involved in this activity';
            }else if(this.activityType == 'Group'){
                if(this.contract.Grant__c == 'JCC'){
                    if(this.staffMembers.length < 1 && this.numberOfYouth <=8){
                        msg = 'Please add only 1 staff member involved in this activity';
                    }else if(this.staffMembers.length < 2 && this.numberOfYouth > 8){
                        msg = 'Please add 2 members involved in this activity';
                    }else if(this.staffMembers.length > 2){
                        msg = 'You can only add 2 Staff Members ';
                    }
                }else if(this.contract.Grant__c == 'Mentoring'){
                    if(this.staffMembers.length < 1 || this.staffMembers.length > 1){
                        msg = 'Please enter at least one Staff member involved in this activity';
                    }
                }
            }
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
            this.staffMembers.forEach(function(member){
                if(!member.status){
                    msg = 'One or more Staffs are in inactive status.'
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
    addNewMember(){
        if(!this.isEditMode)
            this.newMember = {};
        this.addExisting = false;
        this.addNew = true;
        this.heading = 'Add Staff Members';
    }
    handleCloseModal(){
        this.addExisting = false;
        this.addNew = false;
        this.isEditMode = false;
        this.saveButton1 = false;
        this.searchValue = '';
    }

    calculateAge(date) {
        var Bday = +new Date(date);
        var today = +new Date();
        var age = ~~((today - Bday) / (31557600000));
        return age;
    }


}