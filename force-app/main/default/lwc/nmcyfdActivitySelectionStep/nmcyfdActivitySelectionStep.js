import { LightningElement, track, api, wire} from 'lwc';
import getSelectedActivityDetails from '@salesforce/apex/NM_CYFD_ActivityController.getSelectedActivityDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACTIVITY_DETAIL from '@salesforce/schema/Contract_Activity__c.Activity_Detail__c';
import CONTRACT_ACTIVITY_OBJ from '@salesforce/schema/Contract_Activity__c';
import NM_CYFD_AllowDatesSmallerThanFiscalStartDate from '@salesforce/label/c.NM_CYFD_AllowDatesSmallerThanFiscalStartDate';

export default class NmcyfdActivitySelectionStep extends LightningElement {

    @api contractId;
    @api contract;
    @api activityData;
    @track dataObj = {};
    @api month;
    @track error = '';
    @track activityExpenditure = 0;
    @track programExpenditure = 0;
    @track limit = 0;
    @track fieldToValidate = 0;
    @track validate = false;
    @track subContractExpenditure = 0;
    @track isAmountValid = true;
    @track validationError = '';
    @track selectedRecord = [];
    //@track activityDetailValues = [];
    @api jccUser;
    @api mentoringUser;
    @api jjacUser;
    @api subContractorUser ;
    @track recordTypeId = '';
    @api jjac;
    @api jcc;
    @api mentoring;
    @api grant;
    @track matchReadOnly = false;
    @api fiscalYearStartDate;
    @track youthRequired = true;

    @api awardAmount = 0;
    @api startDate;
    @api endDate;
    @api totalInvoiceAmount = 0;
    @track isAwardAmountValid = true;
    

    @api returnData(){
        return this.dataObj;
    }

    @api activityDetailValues;

    connectedCallback(){
        if(this.activityData.saved){
            this.dataObj = JSON.parse(JSON.stringify(this.activityData));

            this.selectedRecord.activityLabel = this.dataObj['activityLabel'];
            this.selectedRecord['activityId'] = this.dataObj['activityId'];
            this.selectedRecord['lineItemId'] = this.dataObj['lineItemId'];
            
        }
            
    }

    handleInputChange(event){
        this.dataObj[event.target.name] = event.target.value;

        let numberOfYouth = this.template.querySelector(".numberOfYouth");
        if(event.target.name == 'matchEnabled'){
            this.dataObj[event.target.name] = event.target.checked;
            this.youthRequired = !event.target.checked;
            if(event.target.checked){
                this.dataObj['numberOfYouth'] = 0 ;
                this.dataObj['matchAmount'] = this.dataObj['amount'];
                this.dataObj['amount'] = null;
                this.dataObj['activityExpenditure'] = this.dataObj['activityExpenditureOriginal'];
                
                if(this.dataObj['program'])
                    this.dataObj['programExpenditure'] = this.dataObj['programExpenditureOriginal'];
                if(this.dataObj['subContractor'])
                    this.dataObj['subContractExpenditure'] = this.dataObj['subContractExpenditureOriginal'];
            }else{
                this.dataObj['amount'] = this.dataObj['matchAmount'];
                this.dataObj['matchAmount'] = null;
                this.dataObj['activityExpenditure'] = parseFloat(this.dataObj['activityExpenditureOriginal'])  + parseFloat(this.dataObj['amount']);
                
                if(this.dataObj['program'])
                this.dataObj['programExpenditure'] = parseFloat(this.dataObj['programExpenditureOriginal'])  + parseFloat(this.dataObj['amount']);
                
                if(this.dataObj['subContractor'])
                this.dataObj['subContractExpenditure'] = parseFloat(this.dataObj['subContractExpenditureOriginal'])  + parseFloat(this.dataObj['amount']);
            }
            this.validations();
        }
        if(event.target.name == 'numberOfYouth' && this.dataObj['activityRate']){
            if(this.dataObj['activityType'] == 'Individual'){
                if(this.dataObj['numberOfYouth'] == 0){
                    numberOfYouth.setCustomValidity("Please add 1 Youth");
                }else if(this.dataObj['numberOfYouth'] > 1){
                    numberOfYouth.setCustomValidity("You can add only 1 Youth for an Individual Activity");
                }  else{
                    numberOfYouth.setCustomValidity("");
                }          
            }else if(this.dataObj['activityType'] == 'Group'){
                if(this.contract.Grant__c == 'Mentoring' && (this.dataObj['numberOfYouth'] < 2 || this.dataObj['numberOfYouth'] > 6)){
                    numberOfYouth.setCustomValidity("You can add between 2-6 Youths");
                }else if(this.contract.Grant__c == 'JCC' && (this.dataObj['numberOfYouth'] < 2 || this.dataObj['numberOfYouth'] > 16)){
                    numberOfYouth.setCustomValidity("You can add between 2-16 Youths");
                }else{
                    numberOfYouth.setCustomValidity("");
                } 
            }else{
                numberOfYouth.setCustomValidity("");
            }  

        }
        
        if(event.target.name == 'units' || event.target.name == 'numberOfYouth'){
            if(this.dataObj['activityRate']){

                if(!this.dataObj['multipliedByYouth']){
                    if(this.dataObj['matchEnabled']){
                        this.dataObj['matchAmount'] = this.dataObj['activityRate']*this.dataObj['units'];
                    }else{
                        this.dataObj['amount'] = this.dataObj['activityRate']*this.dataObj['units'];
                    }
                    
                }else{
                    if(!this.dataObj['numberOfYouth']){
                        this.dataObj['amount'] = this.dataObj['activityRate']*this.dataObj['units'];
                    }else{
                        this.dataObj['amount'] = this.dataObj['activityRate']*this.dataObj['units']*this.dataObj['numberOfYouth'];
                    }
                    
                }
                
                this.dataObj['activityExpenditure'] = parseFloat(this.dataObj['activityExpenditureOriginal']) + parseFloat(this.dataObj['amount']);

                if(this.dataObj['subContractor'])
                    this.dataObj['subContractExpenditure'] = parseFloat(this.dataObj['subContractExpenditureOriginal']) + parseFloat(this.dataObj['amount']);
                if(this.dataObj['program'])
                    this.dataObj['programExpenditure'] = parseFloat(this.dataObj['programExpenditureOriginal']) + parseFloat(this.dataObj['amount']);
                this.validations();
            }           
        }
    }

    validations(){
       // alert('fnjf')
        var error = '';
        var unitsError = false;
        var unitType = this.dataObj['unitType'];
        var units = this.dataObj['units'];
        var amt = this.dataObj['amount'];
        var unitsLimit = this.dataObj['unitsLimit'];
        var amountLimit = this.dataObj['amountLimit'];
        var youthLimit = this.dataObj['youthLimit'];
        var youthRequired = (this.dataObj['youthRequired'] && this.youthRequired);
        var activityLabel = this.dataObj['activityLabel'];
        var minimumYouth = this.dataObj['minimumYouth'];
        let numberOfYouth = this.template.querySelector(".numberOfYouth");
        var unitsClass = this.template.querySelector(".units");
        
        if (!minimumYouth) {
            minimumYouth = 0;
        }
       
        if(this.dataObj['activityExpenditure'] > this.dataObj['activityAllocatedAmt'])
            error = 'Activity Expenditure cannot be more than Allocated Amount. ';
        
        if(this.subContractorUser && this.dataObj['subContractExpenditure'] > this.dataObj['subContractAllocatedAmt'])
            error += 'Sub Contract Expenditure cannot be more than Allocated Amount. ';
        
        if(!this.mentoringUser && this.dataObj['programExpenditure'] > this.dataObj['programAllocatedAmt'])
            error += 'Program Expenditure cannot be more than Allocated Amount. ';

        if(units < 0.01)
            error += 'Units must be greater than 0.'

            
        if(this.dataObj['validation']){
            if(amountLimit && amt > amountLimit){
                error += 'Amount cannot be more than $'+ amountLimit;
            }
            if(unitsLimit && units > unitsLimit){
                error += 'Not allowed to enter more than ' + unitsLimit + ' units';
            }
            numberOfYouth.setCustomValidity("");
            if(youthRequired){    
                if((youthLimit == 1 || this.dataObj['activityType'] == 'Individual') && this.dataObj['numberOfYouth'] != 1){
                    numberOfYouth.setCustomValidity("You can add only 1 Youth");
                }else if(!youthLimit && !this.jjac){
                    if(this.contract.Grant__c == 'Mentoring' && (this.dataObj['numberOfYouth'] < 2 || this.dataObj['numberOfYouth'] > 6)){
                        numberOfYouth.setCustomValidity("You can add between 2-6 Youths");
                    }else if(this.contract.Grant__c == 'JCC' && (this.dataObj['numberOfYouth'] < 2 || this.dataObj['numberOfYouth'] > 16)){
                        numberOfYouth.setCustomValidity("You can add between 2-16 Youths");
                    }
                }else if(youthLimit && this.dataObj['numberOfYouth'] < minimumYouth || this.dataObj['numberOfYouth'] > youthLimit){
                    numberOfYouth.setCustomValidity("You can add between " + minimumYouth + '-' + youthLimit + " Youth/s");
                }else if(!youthLimit && this.jjac && this.dataObj['numberOfYouth'] < minimumYouth){
                    numberOfYouth.setCustomValidity("Please add at least " + minimumYouth + " Youth/s");
                }
            }else if(!youthRequired){
                if(youthLimit && this.dataObj['numberOfYouth'] > youthLimit){
                    numberOfYouth.setCustomValidity("You can add only upto 1 Youth");
                }
            }

           
        }
        //alert('bjf', unitType)
        if(unitType == 'Per Hour'){            
            unitsClass.step = "0.25";             
        }else if(unitType == 'Per Mile' || unitType == null || unitType == ''){
            unitsClass.step = "0.01"; 
        }else{
            unitsClass.step = "1"; 
        }
       unitsClass.reportValidity();
       /* if(unitType == 'Per Hour'){
            
            unitsClass.step = "0.25";
            unitsError = unitsClass.reportValidity();
        }*/
    
        if(error == ''){
            
            this.isAmountValid = true;
        }else{
            this.isAmountValid = false;          
        }
        this.validationError = error;
            
    }

    handleActivitySelection(event){
        var selectedRecord = event.detail;
        this.selectedRecord = event.detail;
        this.dataObj['activityId'] = selectedRecord.activityId;
        this.dataObj['lineItemId'] = selectedRecord.lineItemId;
        this.dataObj['activityRate'] = selectedRecord.activityRate;
        getSelectedActivityDetails({lineItemId : selectedRecord.lineItemId,  contractId : this.contractId}).then(data =>{
            this.dataObj = JSON.parse(JSON.stringify(data));
           // this.dataObj['numberOfYouth'] =1;

            this.activityExpenditure = data.activityExpenditure;
            this.programExpenditure = data.programExpenditure;
            this.subContractExpenditure = data.subContractExpenditure;
            var unitType = this.dataObj['unitType'];
          
            //Add variables for original Expenditues
            this.dataObj['activityExpenditureOriginal'] = data.activityExpenditure;
            this.dataObj['programExpenditureOriginal'] = data.programExpenditure;
            this.dataObj['subContractExpenditureOriginal'] = data.subContractExpenditure;

            //this.awardAmount = JSON.parse(JSON.stringify(data.awardAmount));
            // this.totalInvoiceAmount = data.totalInvoiceAmount;

            this.validate = data.validation;
            this.limit = data.unitsLimit;
            //this.fieldToValidate = data.validationField;

            var unitsClass = this.template.querySelector(".units");
            if(unitType == 'Per Hour'){            
                unitsClass.step = "0.25";             
            }else if(unitType == 'Per Mile' || unitType == '' || unitType == null){
                unitsClass.step = "0.01"; 
            }else{
                unitsClass.step = "1"; 
            }

            if(data.matchEnabled){
                this.matchReadOnly = true;
                this.youthRequired = false;
            }else{
                this.youthRequired = true;
            }
            if(!data.youthRequired){
                this.dataObj['numberOfYouth'] = 0;
            }

        
        }).catch(error=>{
            console.log('error', error);
        });
        if(this.dataObj['units'])
            this.dataObj['amount'] = this.dataObj['activityRate']*this.dataObj['units'];
    }

    handleActivityRemoval(event){
        
        //this.selectedRecord.lineItemId   = '';
        this.selectedRecord = [];     
        this.dataObj = {};
        this.isAmountValid = true;
        this.validationError = '';
        this.matchReadOnly = false;
    }

    @api 
    isValid(){
        var unitType = this.dataObj['unitType'];
        let units = this.template.querySelector(".units");
        if(unitType == 'Per Hour'){  
            units.step = "0.25";             
        }else if(unitType == 'Per Mile' || unitType == null || unitType == ''){
            units.step = "0.01"; 
        }else{
            units.step = "1"; 
        }
        
        let activityDate = this.template.querySelector(".activityDate");
        
        let activityId = this.template.querySelector(".activityId");
        var isActivitySelected = true;

        let amount = this.template.querySelector(".amount");

        if ( amount.value && this.awardAmount && this.totalInvoiceAmount ) {
            let sumOfAmount = parseFloat(this.totalInvoiceAmount) + parseFloat(amount.value);
            let diff = this.awardAmount - sumOfAmount;

            if (diff < 0) {
                
                this.ShowToastEvent('Award Amount is getting exceeded for this contract.','','warning');
                return;
            }
        }
        
        this.error = '';
        if(!this.dataObj['activityId']){
            isActivitySelected = false;
            this.error = 'Please select an activity';
        }

        let numberOfYouth = this.template.querySelector(".numberOfYouth");
        var isNumberOfYouthValid = numberOfYouth.reportValidity();
        var isUnitsValid = units.reportValidity();
        
        var isActivityDetailValid;
        if(this.mentoring){
            let activityDetail = this.template.querySelector(".activityDetail");
            isActivityDetailValid = activityDetail.reportValidity();
        }
        
        activityDate.setCustomValidity("");
        var isActivityDateValid = activityDate.reportValidity();     
        if(isActivityDateValid){
            var d = new Date(),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();
            

            if (month.length < 2) 
                month = '0' + month;
            if (day.length < 2) 
                day = '0' + day;

            var today =  [year, month, day].join('-');

            let dateDiff = this.differenceInDates(new Date(), new Date(this.fiscalYearStartDate ));

            if(activityDate.value > today){
                activityDate.setCustomValidity("Activity Date cannot be a future date");
                isActivityDateValid = activityDate.reportValidity();
                
            }

            else if ( new Date(this.startDate) <  this.getPreviousFiscalYear(new Date(this.fiscalYearStartDate)) ) {
                activityDate.setCustomValidity("You cannot login an activity for this contract.");
                isActivityDateValid = activityDate.reportValidity();
            }

            else if(new Date(activityDate.value) < new Date(this.startDate)
                    || new Date(activityDate.value) > new Date(this.endDate )) {
                /*
                    * Author : Apoorv Anand
                    * Issue  : I-64728
                    * Desc   : No one able to enter June activities in this fiscal year - start date 2021-07-01.

                */
                activityDate.setCustomValidity("Activity Date cannot be smaller than fiscal year start date.");

                if (new Date(activityDate.value) >= new Date(this.fiscalYearStartDate )) {
                    activityDate.setCustomValidity("Activity Date cannot be greater than fiscal year start date.");

                }
                isActivityDateValid = activityDate.reportValidity();
            } 
            else if (new Date(activityDate.value)< new Date(this.fiscalYearStartDate )
                    && dateDiff > parseInt(NM_CYFD_AllowDatesSmallerThanFiscalStartDate)) {

                activityDate.setCustomValidity("Previous fiscal year activities can no longer be billed.");
                isActivityDateValid = activityDate.reportValidity();
            }
        }
        
        if( isUnitsValid && (!this.mentoring || (isActivityDetailValid && this.mentoring)) && isActivityDateValid && isActivitySelected && this.isAmountValid && isNumberOfYouthValid )
            return true;
        else
            return false;
        //return true;
    }

    getPreviousFiscalYear = ( fiscalYearStartDate ) => {

        let currentDate = new Date( fiscalYearStartDate );
        currentDate.setMonth( currentDate.getMonth() - 12 );
        return currentDate;
    }

    differenceInDates = (activityDate, fiscalYear) => {
       let diffTime = activityDate - fiscalYear;
        let diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)); 

        return diffDays;
    }

    ShowToastEvent(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}