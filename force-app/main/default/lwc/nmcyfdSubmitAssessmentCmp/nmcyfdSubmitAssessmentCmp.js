import { LightningElement,track } from 'lwc';
import getNavigationNodes from '@salesforce/apex/NM_CYFD_Utility.getNavigationNodes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import logAssessment from '@salesforce/apex/NM_CYFD_SubmitAssessmentController.submitAssessment';
import getAssessments from '@salesforce/apex/NM_CYFD_SubmitAssessmentController.getAssessment';
import step1Instructions from '@salesforce/label/c.Assessment_Submission_Instructions';
import getAllAssessmentQuestions from '@salesforce/apex/Nmcyfd_Assessment2022Controller.getAllAssessmentQuestions';

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
     @track isCivicEngagement = false;
     @track isSupportSystemSuppliment = false;
     @track contractId;
     @track dataObj = {};
     @track buttonclicked = false;
     @track showSpinner = false;
     @track assessmentId = '';
     @track instructions = step1Instructions;
     @track showAssessment = false;
     @track result = [];
     @track questionsLabel;
     @track totalStepsCount = 0;
     @track showNavigation = false;
     @track sectionNameArr = [];
     @track options =  [
                        { label: 'No', value: '1' },
                        { label: 'Mostly No', value: '2' },
                        { label: 'Somewhat', value: '3' },
                        { label: 'Mostly Yes', value: '4'},
                        { label: 'Yes', value: '5' },
                    ];
    

     get previousButtonShow(){
        return this.currentStep > 1;
     }

     get nextButtonShow(){
        return this.currentStep < this.totalSteps;
     }

     get submitButtonShow(){
        return this.currentStep === this.totalSteps;
     }

    get getquestions() {
         return this.result.filter( item => item.Section_Name__c === this.questionsLabel);
     }

     get getmainclass() {
         return this.showNavigation ? "card--section slds-col slds-size_4-of-6" : "card--section slds-col slds-size_6-of-6";
     }

    connectedCallback(){ 
        let testURL = window.location.href;
        let newURL = new URL(testURL).searchParams;
        this.contractId = newURL.get('contractId');
        var currentStep = this.currentStep;
        var completedStepNum = this.completedStepNum;
        this.getAllAssessmentQuestions();

        getNavigationNodes({flowType : 'CLSA'}).then(data =>{
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
                let msg = error.message || error.body.message;
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: msg,
                    variant :'error'
                });
                this.dispatchEvent(event);
           });
    }

    getAllAssessmentQuestions() {

        getAllAssessmentQuestions({

        })
        .then( result => {
            this.result = JSON.parse( JSON.stringify( result ) );
            let arr = result.reduce( (acc, item ) => {

                if ( acc && !acc.includes( item.Section_Name__c ) ) {

                    acc.push( item.Section_Name__c);
                }

                return acc;
            }, []);
            
            this.sectionNameArr = [...arr];
            console.log('this.sectionNameArr--->', JSON.stringify(this.sectionNameArr));

            this.totalStepsCount = arr.length;
        })
        .catch( error => {
            let msg = error.message || error.body.message;
            const event = new ShowToastEvent({
                title: 'Error',
                message: msg,
                variant :'error'
            });
            this.dispatchEvent(event);
        })
        .finally( () => {
            this.showSpinner = false;
        })
    }

    @track showNext = false;
    handleYouthSelection(event){
        this.assessmentId = event.detail.recordId;        
        this.currentStep = parseInt(event.detail.steps) === 0 ? parseInt(event.detail.steps) + 1 : parseInt(event.detail.steps);

        window.scrollTo(0,0);
        this.showNext = true;
        this.steps();
        
    }
    handleNextStep(event){
        this.showSpinner = true;
        if(this.currentStep === 1){
            this.dataObj = this.template.querySelector('c-nmcyfd-daily-living-assessment').returnData();
            if(this.dataObj && this.dataObj.success === 'true') {
                this.submitAssessmentData(JSON.stringify(this.dataObj), this.currentStep,'false');
            }
        }
        else if(this.currentStep === 2){
            this.dataObj = this.template.querySelector('c-nmcyfd-self-care-assessment').returnData();
            if(this.dataObj && this.dataObj.success === 'true') {
                this.submitAssessmentData(JSON.stringify(this.dataObj), this.currentStep,'false');
            }
        }
        else if(this.currentStep === 3){
            this.dataObj = this.template.querySelector('c-nmcyfd-relationshipsand-communications-assessment').returnData();
            if(this.dataObj && this.dataObj.success === 'true') {
                this.submitAssessmentData(JSON.stringify(this.dataObj), this.currentStep,'false');
            }
        }
        else if(this.currentStep === 4){
            this.dataObj = this.template.querySelector('c-nmcyfd-housingand-money-management-assessment').returnData();
            if(this.dataObj && this.dataObj.success === 'true') {
                this.submitAssessmentData(JSON.stringify(this.dataObj), this.currentStep,'false');
            }
        }
        else if(this.currentStep === 5){
            this.dataObj = this.template.querySelector('c-nmcyfd-workand-study-life-assessment').returnData();
            if(this.dataObj && this.dataObj.success === 'true') {
                this.submitAssessmentData(JSON.stringify(this.dataObj), this.currentStep,'false');
            }
        }
        else if(this.currentStep === 6){
            this.dataObj = this.template.querySelector('c-nmcyfd-careerand-education-planning-assessment').returnData();
            if(this.dataObj && this.dataObj.success === 'true') {
                this.submitAssessmentData(JSON.stringify(this.dataObj), this.currentStep,'false');
            }
        }
        else if(this.currentStep === 7){
            this.dataObj = this.template.querySelector('c-nmcyfd-civic-engagement').returnData();
            if(this.dataObj && this.dataObj.success === 'true') {
                this.submitAssessmentData(JSON.stringify(this.dataObj), this.currentStep,'false');
            }
        }
        else if(this.currentStep === 8){
            this.dataObj = this.template.querySelector('c-nmcyfd-looking-forward-assessment').returnData();
            if(this.dataObj && this.dataObj.success === 'true') {
                this.submitAssessmentData(JSON.stringify(this.dataObj), this.currentStep,'false');

            }
        }

        this.showSpinner = false;
        if(this.dataObj.success === 'true'){
            window.scrollTo(0,0);
            this.currentStep += 1;
            this.steps();

        }

        let result = JSON.parse(JSON.stringify(  this.result ));
        result.map( item =>  {
            if ( this.dataObj.hasOwnProperty(item.Assement_API__c)) {
                item['value'] = this.dataObj[item.Assement_API__c]

            }
        } );
        this.result = JSON.parse(JSON.stringify(  result ));
        
    }

    submitAssessmentData(dataObj, stepNumber,saveExit){
        logAssessment({assessmentJSON : dataObj,stepNumber : stepNumber,
            assessmentId : this.assessmentId ,saveAndExit :saveExit})
        .then(()=>{
        })
        .catch(error=>{
            let msg = error.message || error.body.message;
            const event = new ShowToastEvent({
                title: 'Error',
                message: msg,
                variant :'error'
            });
            this.dispatchEvent(event);
        })
        .finally(() => {
            this.showSpinner = false;
        });
    }
    

    handlePreviousStep(event){
        this.showSpinner = true;
        this.currentStep = --this.currentStep;
        window.scrollTo(0,0);
        this.steps();
    }


    steps(){

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
        this.isSupportSystemSuppliment = false;
        this.isCivicEngagement = false;
        var instructions = '';

        this.questionsLabel = this.sectionNameArr[this.currentStep - 1];
        this.showSpinner = false;
        this.showNavigation = this.currentStep >= 1 ? true : false;
        if(this.currentStep == 1) {
            this.isDailyLivingStep = true;
            
        }
        else if(this.currentStep == 2) {
            this.isSelfCareStep = true;

        }
        else if(this.currentStep == 3)  {
            this.isRelationshipStep = true;

        }
        else if(this.currentStep == 4) {
            this.isHousingStep = true;

        }
        else if(this.currentStep == 5) {
            this.isWorkStudyStep = true;

        }
        else if(this.currentStep == 6) {
            this.isCareerEducationStep = true;

        }
        else if(this.currentStep == 7) {
            this.isCivicEngagement = true;

        }
        else if(this.currentStep == 8) {
            this.isLookingForwardStep = true;

        }
        else if(this.currentStep == 9) {
            this.isSupportSystemSuppliment = true;

        }

        if ( this.currentStep >=1 )  {
            this.showAssessment = true;
        }
        
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

        this.dataObj = this.template.querySelector('c-nmcyfd-support-system-suppliment').returnData();
        if ( this.dataObj.success === 'true' ) {
            this.showSpinner = true;
            logAssessment({
                    assessmentJSON : JSON.stringify(this.dataObj),
                    stepNumber : '9', 
                    assessmentId : this.assessmentId,
                    saveAndExit : 'false'})
            .then( () =>{
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
        
            })
            .catch(error=>{
                this.showSpinner = false;
                let msg = error.message || error.body.message;
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: msg,
                    variant :'error'
                });
                this.dispatchEvent(event);
            })
            .finally( () => {
                this.showSpinner = false;
            });
        }
        
        let result = JSON.parse(JSON.stringify(  this.result ));
        result.map( item =>  {
            if ( this.dataObj.hasOwnProperty(item.Assement_API__c)) {
                item['value'] = this.dataObj[item.Assement_API__c]

            }
        } );
        this.result = JSON.parse(JSON.stringify(  result ));
        
        this.showSpinner = false;
    }
    async handleSaveAndExit(event){
        this.currentStep = this.currentStep++;
        this.showSpinner = true;
        if(this.currentStep === 1){
            this.dataObj = this.template.querySelector('c-nmcyfd-daily-living-assessment').returnPartialData();
             await this.submitAssessmentData(JSON.stringify(this.dataObj), this.currentStep,'true');
        }
        else if(this.currentStep === 2){
            this.dataObj = this.template.querySelector('c-nmcyfd-self-care-assessment').returnPartialData();
            await this.submitAssessmentData(JSON.stringify(this.dataObj), this.currentStep,'true');
        }
        else if(this.currentStep === 3){
            this.dataObj = this.template.querySelector('c-nmcyfd-relationshipsand-communications-assessment').returnPartialData();
            await this.submitAssessmentData(JSON.stringify(this.dataObj), this.currentStep,'true');
        }
        else if(this.currentStep === 4){
            this.dataObj = this.template.querySelector('c-nmcyfd-housingand-money-management-assessment').returnPartialData();
            await this.submitAssessmentData(JSON.stringify(this.dataObj), this.currentStep,'true');
        }
        else if(this.currentStep === 5){
            this.dataObj = this.template.querySelector('c-nmcyfd-workand-study-life-assessment').returnPartialData();
            await this.submitAssessmentData(JSON.stringify(this.dataObj), this.currentStep,'true');
        }
        else if(this.currentStep === 6){
            this.dataObj = this.template.querySelector('c-nmcyfd-careerand-education-planning-assessment').returnPartialData();
            await this.submitAssessmentData(JSON.stringify(this.dataObj), this.currentStep,'true');
        }
        else if(this.currentStep === 7){
            this.dataObj = this.template.querySelector('c-nmcyfd-civic-engagement').returnPartialData();
            await this.submitAssessmentData(JSON.stringify(this.dataObj), this.currentStep,'true');
        }
        else if(this.currentStep === 8){
            this.dataObj = this.template.querySelector('c-nmcyfd-looking-forward-assessment').returnPartialData();
            await this.submitAssessmentData(JSON.stringify(this.dataObj), this.currentStep,'true');
        }
        else if(this.currentStep === 9){
            this.dataObj = this.template.querySelector('c-nmcyfd-support-system-suppliment').returnPartialData();
            await this.submitAssessmentData(JSON.stringify(this.dataObj), this.currentStep,'true');
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