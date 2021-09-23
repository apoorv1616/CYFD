import { LightningElement,track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMatchExpenditure from '@salesforce/apex/NmcyfdExprenditureAmountOnCAController.getMatchExpenditure';
import getTotalMatchAmount from '@salesforce/apex/NmcyfdExprenditureAmountOnCAController.getTotalMatchAmount';
import { NavigationMixin } from 'lightning/navigation';


export default class NmcyfdMatchExpOnContract extends NavigationMixin(LightningElement) {

    @api recordId;
    @track hasMatchAmount = false;
    @track result = [];
    @track showSpinner = false;
    @track totalMatchAmountValue = 0;
    @track matchColumnSort;

    @track fieldName;

    // Pagination Variables
    @track page = 1;
    @track items = [];
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = 10;
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track data = [];
    @track showMatchAmount = false;

    @track matchColumn  = [
        {
            'label' : 'Contract Activity',
            'fieldname' : 'Name',
            'width' : '15%',
            'sorted' : false,
            'asc' : true,
            'sortable' : true
        },
        {
            'label' : 'Activity Date',
            'fieldname' : 'Date__c',
            'width' : '15%',
            'sorted' : true,
            'asc' : false,
            'sortable' : true
        },
        {
            'label' : 'Activity Label',
            'fieldname' : 'Activity_label__c',
            'width' : '20%',
            'sorted' : false,
            'asc' : true,
            'sortable' : true
        },
        {
            'label' : 'Match Amount',
            'fieldname' : 'Match_Amount__c',
            'width' : '20%',
            'sorted' : false,
            'asc' : true,
            'sortable' : true
        },
        {
            'label' : 'Invoice Name',
            'fieldname' : 'Invoice__r.Invoice_Name__c',
            'width' : '20%',
            'sorted' : false,
            'asc' : true,
            'sortable' : false
        }
    ];

    connectedCallback() {
        this.showSpinner = true;
        this.getMatchExpenditure();
    }

    handleSort(event) {
        this.showSpinner = true;
        this.fieldName = event.target.dataset.fieldname;

        // this.matchColumn.asc = !this.matchColumn.asc;
        // this.matchColumn.sorted = true;

        // let matchColumnSort = '';
        this.matchColumn.map(item => {
            if(item.sorted && this.fieldName !== item.fieldname) {
                item.sorted = false;
            }
            else if(this.fieldName === item.fieldname) {
                item.asc = !item.asc;
                item.sorted = true;
                this.matchColumnSort = item.asc;
            }
        });
        this.getMatchExpenditure();
    }

    getMatchExpenditure() {
        getMatchExpenditure({
            recordId : this.recordId,
            fieldName : this.fieldName,
            columnSort : this.matchColumnSort
        })
        .then(result => {
            if (result) {
                this.result = JSON.parse(JSON.stringify(result));
                this.hasMatchAmount = true;
                this.showSpinner = false;

                this.result.map(item => {
                    if (item.Invoice__c != null ) {
                        item.hasInvoice = true;
                    }
                    else {
                        item.hasInvoice = false;

                    }
                });

                this.getTotalMatchAmount();

                //used for pagination
                this.recordCount = this.result.length;
                this.page = 1;
                this.items = JSON.parse(JSON.stringify(this.result));
                this.totalRecountCount = this.result.length; 
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                this.data = this.items.slice(0, this.pageSize);
                this.endingRecord = this.pageSize;

            }
            else {
                this.recordCount = 0;
                this.showSpinner = false;
                this.hasMatchAmount = false;
            }
        })
        .catch(error => {
            this.recordCount = 0;
            this.showSpinner = false;
            this.hasMatchAmount = false;
            let msg = error.message || error.body.message;
            this.ShowToastEvent('',msg,'error');
        });
    }

    getTotalMatchAmount() {
        getTotalMatchAmount({
            recordId : this.recordId
        })
        .then(result => {
            if (result) {
                this.showMatchAmount = true;
                this.totalMatchAmountValue = JSON.parse( JSON.stringify(result));
            }
            else {
                this.showMatchAmount = false;
            }
        })
        .catch(error=> {
            this.showMatchAmount = false;
            let msg = error.message || error.body.message;
            this.ShowToastEvent('',msg,'error');
        });
    }

     //Toast 
     ShowToastEvent(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
     }

     //navigation
    navigate(event) {
        this.showSpinner = true;
        let object = event.target.dataset.object;
        let contractActivity = event.target.name;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: contractActivity,
                objectApiName: object,
                actionName: 'view'
            }
        });

        this.showSpinner = false;
    }

    //Paginator functions
    previousHandler() {
        // this.showSpinner = true;
        if (this.page > 1) {
            this.showSpinner = true;
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    nextHandler() {
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.showSpinner = true;
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    displayRecordPerPage(page) {

        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount)
            ? this.totalRecountCount : this.endingRecord;

        this.data = this.items.slice(this.startingRecord, this.endingRecord);
        
        this.startingRecord = this.startingRecord + 1;
        this.showSpinner = false;
    }

    //End of Paginator funtions

}