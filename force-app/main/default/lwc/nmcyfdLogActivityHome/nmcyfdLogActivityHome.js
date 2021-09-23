import { LightningElement, track, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getNavigationNodes from '@salesforce/apex/NM_CYFD_Utility.getNavigationNodes';
import getInitialDetails from '@salesforce/apex/NM_CYFD_ActivityController.getInitialDetails';
import createContractActivity from '@salesforce/apex/NM_CYFD_ActivityController.createContractActivity';

export default class NmcyfdLogActivityHome extends NavigationMixin(LightningElement){

    @track completedStepNum = 0;
    @track navigationItems = [];
    @track stepsArray = [];
    @track stepsObj = {};
    @track pageArray = [];
    @track totalSteps;
    @track currentStep = 1;
    @track currentStepName;
    @track contractId;
    @track contract = {};
    @track month = '';
    @track allData = {};
    @track showSpinner = false;

    //Step Variables
    @track isStep1 = true;
    @track isStep2 = false;
    @track isStep3 = false;
    @track isStep4 = false;
    @track lastStep = false;

    //data from child components
    @track step1Data = {'saved' : false};
    @track step2Data = [];
    @track step3Data = [];
    @track step4Data = [];
    @track contractActivityId = '';
    @track profile = '';
    @track jccUser;
    @track subContractorUser = false;
    @track mentoringUser;
    @track unitType = '';
    @track activityType = '';
    @track activityDetailValues = [];
    @track staffLength = 0;
    @track numOfYouth = 0;
    @track fiscalYearStartDate;
    @track matchEnabled = false;
    @track skipStaff = false;
    @track instructions = '';
    @track awardAmount = 0;
    @track startDate;
    @track endDate;
    @track totalInvoiceAmount = 0;
    @track grant;
    @track jcc = false;
    @track mentoring = false;
    @track jjac = false;
    

    
    connectedCallback(){
        
        let testURL = window.location.href;
        let newURL = new URL(testURL).searchParams;
        this.contractId = newURL.get('contractId');

        var currentStep = this.currentStep;
        var completedStepNum = this.completedStepNum;
        var contract;

        const today = new Date();
        this.month = today.toLocaleString('default', { month: 'long' });
        
        getInitialDetails({contractId : this.contractId}).then(data =>{
            
            if(data.contract){
                this.contract  = data.contract;
                this.grant = this.contract.Grant__c;
                this.awardAmount = this.contract.Amount__c;
                this.startDate = this.contract.Start_Date__c;
                this.endDate = this.contract.End_Date__c;

                this.totalInvoiceAmount = this.contract.Total_Invoice_Amount__c;

                console.log('this.awardAmount', this.awardAmount);
                console.log('this.totalInvoiceAmount', this.totalInvoiceAmount);
                if(this.contract.Grant__c == 'JJAC'){
                    this.jjac = true;
                }else if(this.contract.Grant__c == 'JCC'){
                    this.jcc = true;
                }else if(this.contract.Grant__c == 'Mentoring'){
                    this.mentoring = true;
                }

            } 
            if(data.fiscalStartDate){
                this.fiscalYearStartDate = data.fiscalStartDate;
            }
            if(data.subContractor || this.jjac){
                this.subContractorUser = true;
            }
            
           // this.profile = data.profile;
            this.activityDetailValues = data.activityDetailValues;
            
          /*  if(this.profile == 'Mentoring'){
                this.mentoringUser = true;
                this.jccUser = false;
            }else if(this.profile == 'JCC'){
                this.mentoringUser = false;
                this.jccUser = true;
            }*/

            
            this.showSpinner = false;
            
        }).catch(error=>{
            console.log('error', error);
        });

        getNavigationNodes({flowType : 'Log Activity'}).then(data =>{
            if(data){
                this.totalSteps = data.length;
                let nodes = {}, results;
                this.navigationItems = [];
                var navs = [];
                var instructions = '';
                nodes[undefined] = { Name: "Root", items: [] };
                data.forEach(function (item) {
                    
                    //var step = (Math.round(item.Step_Number__c));
                    var i = {
                        key: item.name,
                        name: item.name,
                        instructions : item.instructions,
                        step: (Math.round(item.stepNumber)),
                        order: (Math.round(item.stepNumber)).toString(),
                        isCurrent: false,
                        isComplete: false
                    };
                    i.isCurrent = i.step == Math.round(currentStep) ? true : false;
                    i.isComplete = i.step <= Math.round(completedStepNum) ? true : false;
                    navs.push(i);
                    if(i.step == 1){
                         instructions = item.instructions;
                    }
                });

                
                this.navigationItems = navs;   
                this.instructions = instructions;           
            }   
        }).catch(error=>{
            console.log('error', error);
        });
    }

    setSteps(){
        this.isStep1 = false;
        this.isStep2 = false;
        this.isStep3 = false;
        this.isStep4 = false;
    }

    handleNextStep(event){
        
        var isValid = false;
       console.log('current step', this.currentStep);
        if(this.currentStep == 1){
            isValid = this.template.querySelector('c-nmcyfd-activity-selection-step').isValid();
            if(isValid){    
                
                this.step1Data = this.template.querySelector('c-nmcyfd-activity-selection-step').returnData();
                this.unitType = this.step1Data.unitType;
                this.numOfYouth = this.step1Data.numberOfYouth;
                this.matchEnabled = this.step1Data.matchEnabled;
                this.activityType = this.step1Data.activityType;
                this.skipStaff = this.step1Data.skipStaff;
                const today = this.step1Data.activityDate;
            console.log('step1Data--->',JSON.stringify(this.step1Data));

                this.month = new Date(today).toLocaleString("en-us", { month: "long" });
                this.step1Data.saved = true;
            }
        }
        if(this.currentStep == 2){
            isValid = this.template.querySelector('c-nmcyfd-add-staff-members-step').isValid();
            if(isValid){               
                this.step2Data = this.template.querySelector('c-nmcyfd-add-staff-members-step').returnData();
                this.staffLength = this.step2Data.length;
                console.log('step2Data--->',JSON.stringify(this.step2Data));

            }
        }
        if(this.currentStep == 3){
            isValid = this.template.querySelector('c-nmcyfd-add-client-step').isValid();
            if(isValid){ 
                this.step3Data = this.template.querySelector('c-nmcyfd-add-client-step').returnData();
                console.log('step3Data--->',JSON.stringify(this.step3Data));

                this.showSpinner = true;
                this.saveData();
                isValid = false;
            }
        }
      

        if(isValid){
            
            this.currentStep = ++this.currentStep;
            this.steps();    
        } 
    }

    handlePreviousStep(event){
        var isValid = true;
      
       
        if(this.currentStep == 2){
            this.step2Data = this.template.querySelector('c-nmcyfd-add-staff-members-step').returnData();
        }      
        else if(this.currentStep == 3){
            this.step3Data = this.template.querySelector('c-nmcyfd-add-client-step').returnData();
        }else if(this.currentStep == 4){ 
            this.step4Data = this.template.querySelector('c-nmcyfd-activity-submission-step').returnData();          
            isValid = true;
        } 

        if(!isValid)
            this.showSpinner = false;
        if(isValid){
            this.currentStep = --this.currentStep;
            this.steps();    
        }
    }

    saveData(){
        this.allData = this.step1Data;     
        var obj = this.step1Data;
        obj.staffs = this.step2Data;
        obj.clients = this.step3Data;
        var isValid = false;

        if ( !obj.contractId ) {
            obj.contractId = this.contractId;
        }
        
        createContractActivity({jsonData : JSON.stringify(obj), insertAllData : false}).then(data =>{
            this.contractActivityId = data.contractActivityId;
            this.step1Data['contractActivityId'] = data.contractActivityId;
            if(data.success){
            //this.contractActivityId = data.contractActivityId;
            //this.step1Data['contractActivityId'] = data.contractActivityId;
            isValid = true;
            this.currentStep = ++this.currentStep;
            this.steps();  
            this.showSpinner = false;
         }else{
            const event = new ShowToastEvent({
                title: '',
                message: data.msg,
                variant :'error'
            });
            this.dispatchEvent(event);
            this.showSpinner = false;
            isValid = false;
         }
         
        }).catch(error=>{
            this.showSpinner = false;
            console.log('error', error);
            let message = error.message || error.body.message;
            const event = new ShowToastEvent({
                title: '',
                message: message,
                variant :'error'
            });
            this.dispatchEvent(event);
        });
    }

    steps(){
       
        var currentStep = this.currentStep;
        var instructions = '';
        this.isStep1 = false;
        this.isStep2 = false;
        this.isStep3 = false;
        this.isStep4 = false;
        if(this.currentStep == 1)
            this.isStep1 = true;
        else if(this.currentStep ==2)
            this.isStep2 = true;
        else if(this.currentStep == 3)
            this.isStep3 = true;
        else if(this.currentStep == 4)
            this.isStep4 = true;

        this.navigationItems.forEach(function(nav){
            if(nav.step == currentStep){
                nav.isCurrent = true;
                instructions = nav.instructions;
            }else{
                nav.isCurrent = false;
            }
        });
        this.instructions = instructions;
    }

    handleBackToContract(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.contractId,
                objectApiName: 'Contract__c',
                actionName: 'view'
            },
        });
    }

    handleSubmit(event){
        this.showSpinner = true;
        var obj = this.step1Data;
        obj.staffs = this.step2Data;
        obj.clients = this.step3Data;
        var isValid = false;
        createContractActivity({jsonData : JSON.stringify(obj), insertAllData : true}).then(data =>{
         if(data.success){
            this.contractActivityId = data.contractActivityId;
            
            const event = new ShowToastEvent({
                title: '',
                message: 'Contract Activity submitted successfully !',
                variant :'success'
            });
            this.dispatchEvent(event);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.contractId,
                    objectApiName: 'Contract__c',
                    actionName: 'view'
                },
            });

            this.showSpinner = false;
         }else{
            const event = new ShowToastEvent({
                title: '',
                message: data.msg,
                variant :'error'
            });
            this.dispatchEvent(event);
            isValid = false;
            this.showSpinner = false;
         }
         
        }).catch(error=>{
            console.log('error', error);
            this.showSpinner = false;
        });
        
    }

}