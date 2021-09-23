import { LightningElement, track, api } from 'lwc';
import getAtivities from '@salesforce/apex/NM_CYFD_ConfigurationController.getCYFDActivities';
import createContractCongifLineitems from '@salesforce/apex/NM_CYFD_ConfigurationController.createContractCongifLineitems';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
const pageNumber = 1;
const showIt = 'visibility:visible';
const hideIt = 'visibility:hidden';
export default class NmcyfdCreateContractConfigLineitems extends NavigationMixin(LightningElement){
    @track billables = [];
    @track deliverables = [];
    @api recordId;
    @track selectedActivities = [];
    @track selectedDeliverables = [];

    //pagination for Activities Section
    @track pageSize = 3; //No.of records to be displayed per page
    @track totalPagesActivities; //Total no.of pages
    @track pageNumActivities = pageNumber; //Page number
    @track ctrlPrevActivities = hideIt; //Controls the visibility of Previous page button
    @track ctrlNextActivities = showIt;
    @track activitiesToDisplay = [];
    
    //pagination for Deliverables Section
    @track totalPagesDeliverables; //Total no.of pages
    @track pageNumDeliverables = pageNumber; //Page number
    @track ctrlPrevDeliverables = hideIt; //Controls the visibility of Previous page button
    @track ctrlNextDeliverables = showIt;
    @track deliverablesToDisplay = [];


    connectedCallback() {
        this.getCYFDActivities();       
    }

    getCYFDActivities(){
        getAtivities({contractConfigId : this.recordId}).then(result =>{
            if(result){
                this.deliverables = result.deliverables;
                this.billables = result.billables;
                //this.controlPaginationActivities = this.showPagination === false ? hideIt : showIt;
                this.setRecordsToDisplay();
                this.setRecordsToDisplayDeliverables();
            }
        }).catch(error=>{
            console.log('error', error);
        });
    }

    handleAddDeliverable(event){
        var value = event.target.checked;
        var index  = event.target.name;
        var ind = (this.pageNumDeliverables-1)*this.pageSize + index;
        var obj = this.deliverables[ind];
        obj.selected = value;
        this.deliverables[ind] = obj;
    }

    handleAddActivity(event){
        var value = event.target.checked;
        var index  = event.target.name;
        var ind = (this.pageNumActivities-1)*this.pageSize + index;
        var obj = this.billables[ind];
        obj.selected = value;
        this.billables[ind] = obj;
        //sthis.billables[ind].Selected = value;
        // if(!value){
        //     this.activitiesToDisplay.splice(index, 1);
        // }else{
        //     var obj = this.billables[index];
        //     this.activitiesToDisplay.push(obj);
        // }
    }

    addActivities(){


        //var activities = this.selectedActivities.concat(this.selectedDeliverables);
        var activities = [];
        console.log(' total 1-- ', JSON.stringify(this.billables));
         this.billables.forEach(function(m){
            if(m.selected){
                activities.push(m);
            }           
         });
         this.deliverables.forEach(function(m){
            if(m.selected){
                activities.push(m);
            }           
         });

         if(activities.length == 0){
            const event = new ShowToastEvent({
                title: '',
                message: 'Select atleast 1 activity !',
                variant :'warning'
            });
            this.dispatchEvent(event);
            return;
         }
        
       createContractCongifLineitems({activitiesJSON : JSON.stringify(activities)}).then(result =>{
                const event = new ShowToastEvent({
                    title: '',
                    message: 'Contract Configuration Line Items added successfully !',
                    variant :'success'
                });
                this.dispatchEvent(event);
                const custEvent = new CustomEvent(
                    'close', {
                        detail: ''
                    });
                this.dispatchEvent(custEvent);  
        }).catch(error=>{
            console.log('error', JSON.stringify(error));
            let err = '';
            if(error && error.body && error.body.pageErrors && error.body.pageErrors[0].message) {
                err = error.body.pageErrors[0].message;
                if(err.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                    err = error.body.pageErrors[0].message.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1];
                    if(err && err.includes(':')) {
                        err = err.split(':')[0];
                        console.log('error message', err);
                    }
                }
            }
            if(!err) {
                err = error.message || error.body.message;
            }

            const event = new ShowToastEvent({
                title: err,
                message: '',
                variant :'warning'
            });
            this.dispatchEvent(event);
        });       
    }

    handleClose(){
        const custEvent = new CustomEvent(
            'close', {
                detail: ''
            });
        this.dispatchEvent(custEvent);
    }

    // Methods for pagination for Activities Section
    previousPage(){
        this.pageNumActivities = this.pageNumActivities-1;
        this.setRecordsToDisplay();
    }
    nextPage(){        
        this.pageNumActivities = this.pageNumActivities+1;
        this.setRecordsToDisplay();
    }

    setRecordsToDisplay(){

        this.activitiesToDisplay = [];
        this.totalPagesActivities = Math.ceil(this.billables.length/this.pageSize);
        this.setPaginationControls();
        for(let i=(this.pageNumActivities-1)*this.pageSize; i < this.pageNumActivities*this.pageSize; i++){
            if(i === this.billables.length) break;
            this.activitiesToDisplay.push(this.billables[i]);
        }
        // this.dispatchEvent(new CustomEvent('paginatorchange', {detail: this.recordsToDisplay})); //Send records to display on table to the parent component
    }
    setPaginationControls(){
        //Control Pre/Next buttons visibility by Total pages
        if(this.totalPagesActivities === 1){
            this.ctrlPrevActivities = hideIt;
            this.ctrlNextActivities = hideIt;
        }else if(this.totalPagesActivities > 1){
           this.ctrlPrevActivities = showIt;
           this.ctrlNextActivities = showIt;
        }
        //Control Pre/Next buttons visibility by Page number
        if(this.pageNumActivities <= 1){
            this.pageNumActivities = 1;
            this.ctrlPrevActivities = hideIt;
        }else if(this.pageNumActivities >= this.totalPagesActivities){
            this.pageNumActivities = this.totalPagesActivities;
            this.ctrlNextActivities = hideIt;
        }
    }


    // -------------------------------------------------------------
    previousPageDeliverables(){
        this.pageNumDeliverables = this.pageNumDeliverables-1;
        this.setRecordsToDisplayDeliverables();
    }
    nextPageDeliverables(){        
        this.pageNumDeliverables = this.pageNumDeliverables+1;
        this.setRecordsToDisplayDeliverables();
    }
    setRecordsToDisplayDeliverables(){
        this.deliverablesToDisplay = [];
        this.totalPagesDeliverables = Math.ceil(this.deliverables.length/this.pageSize);
        
        this.setPaginationControlsDeliverables();
        for(let i=(this.pageNumDeliverables-1)*this.pageSize; i < this.pageNumDeliverables*this.pageSize; i++){
            if(i === this.deliverables.length) break;
            this.deliverablesToDisplay.push(this.deliverables[i]);
        }
       // this.dispatchEvent(new CustomEvent('paginatorchange', {detail: this.recordsToDisplay})); //Send records to display on table to the parent component
    }

    setPaginationControlsDeliverables(){
        //Control Pre/Next buttons visibility by Total pages
        if(this.totalPagesDeliverables === 1){
            this.ctrlPrevDeliverables = hideIt;
            this.ctrlNextDeliverables = hideIt;
        }else if(this.totalPagesDeliverables > 1){
           this.ctrlPrevDeliverables = showIt;
           this.ctrlNextDeliverables = showIt;
        }
        //Control Pre/Next buttons visibility by Page number
        if(this.pageNumDeliverables <= 1){
            this.pageNumDeliverables = 1;
            this.ctrlPrevDeliverables = hideIt;
        }else if(this.pageNumDeliverables >= this.totalPagesDeliverables){
            this.pageNumDeliverables = this.totalPagesDeliverables;
            this.ctrlNextDeliverables = hideIt;
        }
    }


}