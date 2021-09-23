import { LightningElement,track } from 'lwc';
import getNavigationNodes from '@salesforce/apex/NM_CYFD_Utility.getNavigationNodes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import logAssessment from '@salesforce/apex/NM_CYFD_SubmitAssessmentController.submitAssessment';
import getAssessments from '@salesforce/apex/NM_CYFD_SubmitAssessmentController.getAssessment';
import step1Instructions from '@salesforce/label/c.Assessment_Submission_Instructions';

export default class NmcyfdSubmitAssessmentCmp extends NavigationMixin(LightningElement) {

    @track navigationItems = [];
    @track  totalSteps;
    @track currentStep = 1;
    @track currentStepName;
    @track completedStepNum = 0;
    @track isStep1 = true;
     @track isPermanencyStep = false;
     @track isDailyLivingStep = false;
     @track isSelfCareStep = false;
     @track isRelationshipStep = false;
     @track isHousingStep = false;
     @track isWorkStudyStep = false;
     @track isCareerEducationStep = false;
     @track isLookingForwardStep = false;
     @track contractId;
     @track dataObj = {};
     @track buttonclicked = false;
     @track showSpinner = false;
     @track assessmentId = '';
     @track instructions = step1Instructions;

     get previousButtonShow(){
         console.log('step 1 ' , this.isStep1 + ' perm  ' + this.isPermanencyStep);
        if(this.isStep1 || this.isPermanencyStep)
            return false;
        else
            return true;
     }

    connectedCallback(){ 
        let testURL = window.location.href;
        let newURL = new URL(testURL).searchParams;
        this.contractId = newURL.get('contractId');
        console.log('Id'+this.contractId);
        var currentStep = this.currentStep;
        var completedStepNum = this.completedStepNum;

        getNavigationNodes({flowType : 'CLSA'}).then(data =>{
            console.log('log ** ' + JSON.stringify(data));
               if(data){
                   this.totalSteps = data.length;
                   let nodes = {}, results;
                   this.navigationItems = [];
                   var instructions = '';
                   var navs = [];
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
                       
                   });
   
                  // this.instructions = instructions;          
                   this.navigationItems = navs;              
               }   
           }).catch(error=>{
               console.log('error', error);
           });
    }

    @track showNext = false;
    handleYouthSelection(event){
        this.assessmentId = event.detail.recordId;        
        
        // this.currentStep = ++this.currentStep;
        this.currentStep = parseInt(event.detail.steps) + 1;
        console.log('step num ** ', event.detail.steps , ' current ' ,  this.currentStep);
        console.log('assessment id ** ', this.assessmentId);
        window.scrollTo(0,0);
        this.showNext = true;
        this.steps();
        
    }
    handleNextStep(event){

        // this.handleSteps();
        // if(this.currentStep === 1){
        //     this.dataObj = this.template.querySelector('c-nmcyfd-permanency-assessment').returnData();
        //     this.submitAssessmentData(JSON.stringify(this.dataObj), '1','false');
        // }
        if(this.currentStep === 1){
            this.dataObj = this.template.querySelector('c-nmcyfd-daily-living-assessment').returnData();
            this.submitAssessmentData(JSON.stringify(this.dataObj), '1','false');
        }
        else if(this.currentStep === 2){
            this.dataObj = this.template.querySelector('c-nmcyfd-self-care-assessment').returnData();
            this.submitAssessmentData(JSON.stringify(this.dataObj), '2','false');
        }
        else if(this.currentStep === 3){
            this.dataObj = this.template.querySelector('c-nmcyfd-relationshipsand-communications-assessment').returnData();
            this.submitAssessmentData(JSON.stringify(this.dataObj), '3','false');
        }
        else if(this.currentStep === 4){
            this.dataObj = this.template.querySelector('c-nmcyfd-housingand-money-management-assessment').returnData();
            this.submitAssessmentData(JSON.stringify(this.dataObj), '4','false');
        }
        else if(this.currentStep === 5){
            this.dataObj = this.template.querySelector('c-nmcyfd-workand-study-life-assessment').returnData();
            this.submitAssessmentData(JSON.stringify(this.dataObj), '5','false');
        }
        else if(this.currentStep === 6){
            this.dataObj = this.template.querySelector('c-nmcyfd-careerand-education-planning-assessment').returnData();
            this.submitAssessmentData(JSON.stringify(this.dataObj), '6','false');
        }
        

        
        window.scrollTo(0,0);
        if(this.dataObj.success == 'true'){
            
            this.currentStep = ++this.currentStep;
            this.steps();
        }
        
    }

    submitAssessmentData(dataObj, stepNumber,saveExit){
        logAssessment({assessmentJSON : dataObj,stepNumber : stepNumber,
            assessmentId : this.assessmentId ,saveAndExit :saveExit}).then(data=>{
        
        }).catch(error=>{
            console.log('error '+JSON.stringify(error));
        });
    }
    

    handlePreviousStep(event){
        if(this.currentStep === 2){
            this.showNext = false;
        }
        this.currentStep = --this.currentStep;
        window.scrollTo(0,0);
            this.steps();
    }


    steps(){
        console.log('steps ', this.currentStep);
        var currentStep = this.currentStep;
        this.isStep1 = false;
        this.isPermanencyStep = false;
        this.isDailyLivingStep = false;
        this.isSelfCareStep = false;
        this.isRelationshipStep = false;
        this.isHousingStep = false;
        this.isWorkStudyStep = false;
        this.isCareerEducationStep = false;
        this.isLookingForwardStep = false;
        var instructions = '';
       // if(this.currentStep == )
           // this.isStep1 = true;
        // if(this.currentStep == 1)
        //     this.isPermanencyStep = true;
        if(this.currentStep == 1)
            this.isDailyLivingStep = true;
        else if(this.currentStep == 2)
            this.isSelfCareStep = true;
        else if(this.currentStep == 3)
            this.isRelationshipStep = true;
        else if(this.currentStep == 4)
            this.isHousingStep = true;
        else if(this.currentStep == 5)
            this.isWorkStudyStep = true;
        else if(this.currentStep == 6)
            this.isCareerEducationStep = true;
        else if(this.currentStep == 7)
            this.isLookingForwardStep = true;
        
        

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

    backToClientsList(){
        window.location.reload()
    }

    isFirstSteporLookingForward(){
        
        if(this.isStep1 == true){
            return true;
        }
        else if(this.isLookingForwardStep == true){
            return true;
        }
        else {
            return false;
        }
    }
    handleSubmit(event){

        this.showSpinner = true;
        if(this.currentStep === 7){
            this.dataObj = this.template.querySelector('c-nmcyfd-looking-forward-assessment').returnData();
            logAssessment({assessmentJSON : JSON.stringify(this.dataObj),stepNumber : '7', assessmentId : this.assessmentId,saveAndExit : 'false'}).then(data=>{

           
            }).catch(error=>{
                console.log('error '+JSON.stringify(error));
            });
            if(this.dataObj.success == 'true'){
                const event = new ShowToastEvent({
                    title: 'Sucess',
                    message: 'Assessment submitted successfully !',
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
            }
        }
        
        this.showSpinner = false;
    }
    async handleSaveAndExit(event){
        this.currentStep = this.currentStep++;
        // if(this.currentStep === 1){
        //     this.dataObj = this.template.querySelector('c-nmcyfd-permanency-assessment').returnPartialData();
        //     await this.submitAssessmentData(JSON.stringify(this.dataObj), '1','true');
        // }
        if(this.currentStep === 1){
            this.dataObj = this.template.querySelector('c-nmcyfd-daily-living-assessment').returnPartialData();
             await this.submitAssessmentData(JSON.stringify(this.dataObj), '1','true');
        }
        else if(this.currentStep === 2){
            this.dataObj = this.template.querySelector('c-nmcyfd-self-care-assessment').returnPartialData();
            await this.submitAssessmentData(JSON.stringify(this.dataObj), '2','true');
        }
        else if(this.currentStep === 3){
            this.dataObj = this.template.querySelector('c-nmcyfd-relationshipsand-communications-assessment').returnPartialData();
            await this.submitAssessmentData(JSON.stringify(this.dataObj), '3','true');
        }
        else if(this.currentStep === 4){
            this.dataObj = this.template.querySelector('c-nmcyfd-housingand-money-management-assessment').returnPartialData();
            await this.submitAssessmentData(JSON.stringify(this.dataObj), '4','true');
        }
        else if(this.currentStep === 5){
            this.dataObj = this.template.querySelector('c-nmcyfd-workand-study-life-assessment').returnPartialData();
            await this.submitAssessmentData(JSON.stringify(this.dataObj), '5','true');
        }
        else if(this.currentStep === 6){
            this.dataObj = this.template.querySelector('c-nmcyfd-careerand-education-planning-assessment').returnPartialData();
            await this.submitAssessmentData(JSON.stringify(this.dataObj), '6','true');
        }
        else if(this.currentStep === 7){
            this.dataObj = this.template.querySelector('c-nmcyfd-looking-forward-assessment').returnPartialData();
            await this.submitAssessmentData(JSON.stringify(this.dataObj), '7','true');
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.contractId,
                objectApiName: 'Contract__c',
                actionName: 'view'
            },
        });

    }
}