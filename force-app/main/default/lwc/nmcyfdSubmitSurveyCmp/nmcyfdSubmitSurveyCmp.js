import { LightningElement ,track, wire} from 'lwc';
import getNavigationNodes from '@salesforce/apex/NM_CYFD_Utility.getNavigationNodes';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitYouthData from '@salesforce/apex/NM_CYFD_SubmitSurveyController.submitYouthData';
import submitStaffData from '@salesforce/apex/NM_CYFD_SubmitSurveyController.submitStaffData';
import getContractDetails from '@salesforce/apex/NM_CYFD_SubmitSurveyController.getContractDetails';
import step1Instructions from '@salesforce/label/c.Survey_Submission_Instructions';
import getPicklistFields from '@salesforce/apex/NM_CYFD_SubmitSurveyController.getPicklistFields';

import {
	getObjectInfo
} from 'lightning/uiObjectInfoApi';

import {
    getPicklistValues
} from "lightning/uiObjectInfoApi";
import No_Survey_Available from "@salesforce/schema/Survey__c.No_Survey_Available__c";

export default class NmcyfdSubmitSurveyCmp extends NavigationMixin(LightningElement){

    @track isSelectYouthStep = true;
    @track isFederalYouthStep = false;
    @track isFederalStaffStep = false;
    @track noSurveyAvailable;
    @track programValues = [];

    @track showSubmit = false;
    @track showPrevious = false;
    @track showSaveAndExit = false;

    @track completedStepNum = 0;
    @track navigationItems = [];
    @track totalSteps;
    @track currentStep = 0;
    @track currentStepName;
    @track contractId;
    @track showSpinner = false;

    @track dataObj;
    @track federalYouthObject = {};
    @track federalStaffObect = {};
    @track finalDataObj;
    @track youthId;
    @track surveyId = '';

    @track mentoring = false;
    @track jcc = false;
    @track jjac = false;
    @track grant;

    @track instructions = step1Instructions;
    label = {
        step1Instructions
    };

    @track survey;
    @track surveyOptions = [];
    @track No_Survey_Reason;
    @track program;

    @wire(getObjectInfo, {
        objectApiName: "Survey__c"
    })
    surveyinfo;

    @wire(getPicklistValues, {
        recordTypeId: "$surveyinfo.data.defaultRecordTypeId",
        fieldApiName: No_Survey_Available
    })
    vaccineBrand({
        data,
        error
    }) {
        if (data) {
            this.surveyOptions = data.values;
        }
        if(error) {
        }
    }

    handleSurveyChange(event) {
        this.noSurveyAvailable = event.target.value;
        //this.federalStaffObject[event.target.name] = noSurveyAvailable;
        if ( this.noSurveyAvailable === 'Staff' ) {
            // this.staffValidations();
            this.youthValidations();
            
        }   
        else if ( this.noSurveyAvailable === 'Youth' ) {
            this.staffValidations();

        }
        else {
            this.showSubmit = false;
            this.showPrevious = false;
            this.showSaveAndExit = false;
            this.isFederalYouthStep = true;
            this.isFederalStaffStep = false;
            this.noSurveyAvailable = null;
            this.currentStep = 1;

            // this.federalStaffObject['success'] = null;
        }

    }

    youthValidations() {
        this.isFederalYouthStep = true;
        this.isFederalStaffStep = false;
        this.showSubmit = true;
        this.showPrevious = false;
        this.showSaveAndExit = false;
    }

    staffValidations() {

        this.currentStep = 2;
        this.isFederalStaffStep = true;
        this.isFederalYouthStep = false;
        this.showSubmit = true;
        this.showPrevious = false;
        this.showSaveAndExit = false;
    }

    get showNoSurveyOptionAvailable() {
        if ( !this.isSelectYouthStep ) {
            return this.isFederalYouthStep || this.isFederalStaffStep;
        }
        return false;
    }

    get showNo_Survey_Reason() {
        if(this.noSurveyAvailable && this.noSurveyAvailable !== 'None') {
            return true;   
        }
        return false;
    }

    get program() {
        if (this.federalYouthObject)  
            return this.federalYouthObject.program

        else if(this.federalStaffObect)
            return this.federalStaffObect.program;
    }

    handleChange(event) {
        if (event.target.name === 'No_Survey_Reason')
            this.No_Survey_Reason = event.target.value;
        
        if (event.target.name === 'program')
            this.program = event.target.value;

    }
    
    connectedCallback(){
        var currentStep = this.currentStep;
        var completedStepNum = this.completedStepNum;
        
        let testURL = window.location.href;
        let newURL = new URL(testURL).searchParams;
        this.contractId = newURL.get('contractId');
        getContractDetails({contractId : this.contractId}).then(data =>{
               if(data.grant){
                   this.grant = data.grant;
                      if(data.grant == 'JCC')
                            this.jcc =  true;
                    else if(data.grant == 'JJAC')
                        this.jjac = true;
                    else if(data.grant == 'Mentoring')
                        this.mentoring = true;
               }   
           }).catch(error=>{
            console.log('error',error);

           });

           getPicklistFields({youthId : this.youthId, contractId : this.contractId}).then(data =>{
                this.programValues = data.programValues;
            }).catch(error=>{
                console.error('error',error);
            });

        getNavigationNodes({flowType : 'Survey'}).then(data =>{
            if(data){
                this.totalSteps = data.length;
                let nodes = {}, results;
                this.navigationItems = [];
                var instructions = '';
                var navs = [];
                nodes[undefined] = { Name: "Root", items: [] };
                data.forEach(function (item) {
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

                this.navigationItems = navs;              
            }   
        }).catch(error=>{
            console.log('error',error);

        });
    }

    handleNextStep(event) {
        if (!this.noProgram()) {
            return;
        }
        if(this.currentStep === 1){
            this.federalYouthObject = this.template.querySelector('c-nmcyfd-federal-youth-survey').returnData();
        }
        this.federalYouthObject.program = this.program;

        console.log('this.currentStep---',this.currentStep);
        console.log('this.federalYouthObject---',this.federalYouthObject);
        if(this.federalYouthObject && this.federalYouthObject.success === 'true' ){
            this.federalYouthObject.contractId = this.contractId;
            this.submitYouthData();
            
        }  
    }

    noProgram = () => {
        if (!this.program && this.grant === 'JJAC') {
            this.ShowToastEvent('Warning','Please select a program!','warning');
            return false;
        }
        return true;
    }

    ShowToastEvent(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    submitYouthData() {
        submitYouthData({surveyJSON : JSON.stringify(this.federalYouthObject), youthId : this.youthId, 
            type : this.grant, surveyId : this.surveyId}).then(data=>{
            
            if(data.success){
                this.surveyId = data.surveyId;
            }
            if (!this.noSurveyAvailable || this.noSurveyAvailable == 'None') {
                this.currentStep = ++this.currentStep;
                window.scrollTo(0,0);
                console.log('inside---',this.currentStep);
                this.steps(); 
            }
            else if(this.noSurveyAvailable === 'Staff') {
                const event = new ShowToastEvent({
                    title: '',
                    message: "Survey Completed Successfully",
                    variant :'success'
                });
                this.dispatchEvent(event);
                this.handleBackToContract();

            }
            
        }).catch(error=>{
            console.log('error',error);

        });
    }

    handlePreviousStep(event){
        if(this.currentStep === 2){
            this.federalStaffObject = this.template.querySelector('c-nmcyfd-federal-staff-survey').returnPartialData();
        }
        this.currentStep = --this.currentStep;
        window.scrollTo(0,0);
        this.steps(); 
    }

    steps(){
        var currentStep = this.currentStep;
        this.isSelectYouthStep = false;
        this.isFederalYouthStep = false;
        this.isFederalStaffStep = false;
        this.showSubmit = false;
        this.showPrevious = false;
        this.showSaveAndExit = false;

        var instructions = '';
        /*if(this.currentStep == 1)
            this.isSelectYouthStep = true;
        else */ 
        if(this.currentStep ==1) {
            this.isFederalYouthStep = true;
            this.isFederalStaffStep = false;
            this.showSubmit = false;
            this.showPrevious = false;

        }
        else if(this.currentStep == 2) {
            this.isFederalStaffStep = true;
            this.isFederalYouthStep = false;
            this.showSubmit = true;
            this.showPrevious = true;
            this.showSaveAndExit = true;

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

    handleSubmit(event){
        if (!this.noProgram()) {
            return;
        }

        if(!this.noSurveyAvailable || this.noSurveyAvailable == 'None') { 

            this.federalStaffObject = this.template.querySelector('c-nmcyfd-federal-staff-survey').returnData();
            this.federalStaffObject.contractId = this.contractId;
            this.federalStaffObject.program = this.program;
            

            if (this.federalStaffObject && this.federalStaffObject.success === 'true' ) {

                this.submitStaffData(true);
            }
        }
        else if (this.noSurveyAvailable === 'Youth') {
            this.federalStaffObject = this.template.querySelector('c-nmcyfd-federal-staff-survey').returnData();
            this.federalStaffObject.contractId = this.contractId;
            this.federalStaffObject.noSurveyAvailable = this.noSurveyAvailable;
            this.federalStaffObject.No_Survey_Reason = this.No_Survey_Reason;
            this.federalStaffObject.program = this.program;
            

            this.submitStaffData(true);
        }
        else if (this.noSurveyAvailable === 'Staff') {
            this.federalYouthObject = this.template.querySelector('c-nmcyfd-federal-youth-survey').returnData();
            this.federalYouthObject.contractId = this.contractId;
            this.federalYouthObject.noSurveyAvailable = this.noSurveyAvailable;
            this.federalYouthObject.No_Survey_Reason = this.No_Survey_Reason;
            this.federalYouthObject.program = this.program;


            this.submitYouthData();
        }
        
        
    }

    submitStaffData(submit) {
        
        submitStaffData({surveyJSON : JSON.stringify(this.federalStaffObject), surveyId : this.surveyId, submit : submit, youthId: this.youthId, type:this.grant}).then(data=>{
            
            const event = new ShowToastEvent({
                     title: '',
                     message: "Survey Completed Successfully",
                     variant :'success'
                 });
                 this.dispatchEvent(event);
                 this.handleBackToContract();

            
        }).catch(error=>{
            console.log('error',error);

        });
    }

    handleYouthSelection(event){
        this.youthId = event.detail;      
        this.currentStep = ++this.currentStep;
        window.scrollTo(0,0);
        this.steps(); 
    }
    handleContinueSurvey(event){
        this.surveyId = event.detail;      
        this.currentStep = 2;
        window.scrollTo(0,0);
        this.steps(); 
    }

    backToClientsList(){
        window.location.reload()
    }

    handleSaveNExit(){
        this.federalStaffObject = this.template.querySelector('c-nmcyfd-federal-staff-survey').returnPartialData();
        this.federalStaffObject.contractId = this.contractId;
        this.federalStaffObject.noSurveyAvailable = this.noSurveyAvailable;
        this.federalStaffObject.No_Survey_Reason = this.No_Survey_Reason;
        this.federalStaffObject.program = this.program;

        submitStaffData({surveyJSON : JSON.stringify(this.federalStaffObject), surveyId : this.surveyId, submit : false, youthId: this.youthId, type:this.grant}).then(data=>{
            
            const event = new ShowToastEvent({
                     title: '',
                     message: "Survey Saved Successfully",
                     variant :'success'
            });
            this.dispatchEvent(event);
            this.handleBackToContract();
            
        }).catch(error=>{
            console.log('error',error);

        });
    }

 
}