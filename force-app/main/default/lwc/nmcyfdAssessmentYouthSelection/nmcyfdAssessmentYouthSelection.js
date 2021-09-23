import { LightningElement, track, api } from 'lwc';
import getYouthDataForAssessment from '@salesforce/apex/NM_CYFD_SubmitAssessmentController.getYouthDataForAssessment';
import startAssessment from '@salesforce/apex/NM_CYFD_SubmitAssessmentController.startAssessment';
import { NavigationMixin } from 'lightning/navigation';
const pageNumber = 1;
const showIt = 'visibility:visible';
const hideIt = 'visibility:hidden';

export default class NmcyfdAssessmentYouthSelection extends NavigationMixin(LightningElement) {

    @track assessments = [];
    @track selectedAssessmentType = '';
    @track selectedAction = '';
    @track inputClass = '';
    @track searchTerm = '';
    @api contractId ;
    @track showAddClient =false;

    //pagination 
    @track pageSize = 5; //No.of records to be displayed per page
    @track totalPages; //Total no.of pages
    @track pageNum = pageNumber; //Page number
    @track ctrlPrev = hideIt; //Controls the visibility of Previous page button
    @track ctrlNext = showIt;
    @track assessmentsToDisplay= [];

    @track jcc = false;
    @track jjac = false;
    @track mentoring = false;


    get isActionNone(){
        
    }
    get assessmentTypes() {
        return [
            { label: '-- None -- ', value: '' },
            { label: 'Initial Assessment', value: 'Initial Assessment' },
            { label: 'Discharge Assessment', value: 'Discharge Assessment'}
        ];
    }

   /*get actions() {
        return [
            { label: '-- None -- ', value: '' },
            { label: 'Start Initial Assessment', value: 'Not Started-Initial Assessment' },
            { label: 'Continue Initial Assessment', value: 'In Progress-Initial Assessment' },
            { label: 'Start Discharge Assessment', value: 'Not Started-Discharge Assessment' },
            { label: 'Continue Discharge Assessment', value: 'In Progress-Discharge Assessment' },
        ];
    }*/
    get actions() {
        return [
            { label: '-- None -- ', value: '' },
            { label: 'Start Initial Assessment', value: 'Start Initial Assessment' },
            { label: 'Continue Initial Assessment', value: 'Continue Initial Assessment' },
            { label: 'Start Discharge Assessment', value: 'Start Discharge Assessment' },
            { label: 'Continue Discharge Assessment', value: 'Continue Discharge Assessment' },
        ];
    }

    addClient(){
        this.showAddClient = true;
    }
    handleClose(){
        this.showAddClient = false;
        this.getYouths();
    }

    connectedCallback(){
        
        this.getYouths();      
    }

    handleFilterChange(event){
        if(event.target.name == 'clientName'){
            this.searchTerm = event.target.value;
        }else if(event.target.name == 'assessmentType'){
            this.selectedAssessmentType = event.target.value;
        }else if(event.target.name == 'action'){
            this.selectedAction = event.target.value;
        }
        this.getYouths();
    }

    getYouths(){
        getYouthDataForAssessment({contractId : this.contractId, searchKey : this.searchTerm, 
        assessmentType : this.selectedAssessmentType , action : this.selectedAction}).then(data =>{
            this.assessments = data.youths;
            var grant = data.grant;
            console.log('grant '+grant);
            if(grant == 'JCC'){
                this.jcc = true;
            }else if(grant == 'JJAC'){
                this.jjac = true;
            }else if(grant == 'Mentoring'){
                this.mentoring = true;
            }

            this.pageNum = 1;       
            this.setRecordsToDisplay();
        }).catch(error=>{
            console.log('error', error);
        });
    }

    // Methods for pagination 
    previousPage(){
        this.pageNum = this.pageNum-1 ;
        this.setRecordsToDisplay();
    }
    nextPage(){  
        console.log(' hfbj next ', this.pageNum)      
        this.pageNum = this.pageNum+1;
        console.log(' hfbj next  &&  ', this.pageNum)  
        this.setRecordsToDisplay();
    }
    setRecordsToDisplay(){

        this.assessmentsToDisplay = [];
        this.totalPages = Math.ceil(this.assessments.length/this.pageSize);
        console.log('total pages ', this.totalPages);
        this.setPaginationControls();
        for(let i=(this.pageNum-1)*this.pageSize; i < this.pageNum*this.pageSize; i++){
            console.log('bdhbj');
            if(i === this.assessments.length) break;
            this.assessmentsToDisplay.push(this.assessments[i]);
        }
    }
    setPaginationControls(){
        //Control Pre/Next buttons visibility by Total pages
        if(this.totalPages === 1){
            this.ctrlPrev = hideIt;
            this.ctrlNext = hideIt;
        }else if(this.totalPages > 1){
           this.ctrlPrev = showIt;
           this.ctrlNext = showIt;
        }
        //Control Pre/Next buttons visibility by Page number
        if(this.pageNum <= 1){
            this.pageNum = 1;
            this.ctrlPrev = hideIt;
        }else if(this.pageNum >= this.totalPages){
            this.pageNum = this.totalPages;
            this.ctrlNext = hideIt;
        }

        console.log('bdhbj8**** ', this.pageNum  + '  ' + this.ctrlNext);
    }

    handleYouthSelection(event){
        if(event.target.dataset.label != 'None'){
            var assessmentId = event.target.dataset.assessmentId;
            var stepNumber =  event.target.dataset.step ;
            console.log('event stepnumvber ', stepNumber);
            console.log('event.target.dataset.assessmentId ',event.target.dataset.assessmentId ,'stepnumber ',event.target.dataset.step);
            if(assessmentId){
                console.log('assessmentId ',assessmentId);
                
                const selectedEvent = new CustomEvent('youthselect', {
                    detail: {
                        recordId : assessmentId,
                        steps : stepNumber
                    }
                });
                this.dispatchEvent(selectedEvent);                 
                
            
            }else{
                var youthId = event.target.dataset.youthId;
                var latestAssessment =  event.target.dataset.latestAssessment;
                var assessmentType = '';           
                assessmentType = latestAssessment == 'None' ? 'Initial Assessment' : 'Discharge Assessment';

                startAssessment({contractId : this.contractId , youthId : youthId, assessmentType : assessmentType}).then(data =>{
                    console.log('assessmentId ', data.assessmentId);
                    console.log('step ', event.target.dataset.step);
                    this.dispatchEvent(new CustomEvent('youthselect', {detail:{recordId : data.assessmentId,steps : 0 } }));
                }).catch(error=>{
                    console.log('error', error);
                }); 
            }    
        }
          
      
    }
    onYouthClick(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
                attributes: {
                    recordId: event.target.dataset.youthId,
                    objectApiName: 'Contract_Role__c',
                    actionName: 'view'
                },
        });

    }

}