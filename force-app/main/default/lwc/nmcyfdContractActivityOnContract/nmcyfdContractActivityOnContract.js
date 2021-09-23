import { LightningElement,track,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCAAssociatedWithContract from '@salesforce/apex/NmcyfdCAOnContractController.getCAAssociatedWithContract';

export default class NmcyfdContractActivityOnContract extends NavigationMixin(LightningElement)  {
    @track recordCount = 0;
    @track result = [];
    @track showData = false;
    @api recordId;
    @track showSpinner = false;
    @track invoiceAmountSum = 0;
    @track grant;
    @track contractPage = true;

    //Pagination Variables
    @track page = 1;
    @track items = [];
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = 25;
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track data = [];

    //options variable
    @track searchKey;
    @track type;


    @track column;

    defaultColumn  = [
        {
            'label' : 'Contract Activity ID',
            'width' : '15%',
            'fieldname' : 'Name',
            'sorted' : false,
            'asc' : true,
            'sortable' : true
        },
        {
            'label' : 'CYFD Activity Label',
            'width' : '12%',
            'fieldname' : 'Activity_Label__c',
            'sorted' : false,
            'asc' : true,
            'sortable' : true
        },
        {
            'label' : 'Amount',
            'width' : '12%',
            'fieldname' : 'Amount__c',
            'sorted' : false,
            'asc' : true,
            'sortable' : false
        },
        {
            'label' : 'Activity Date',
            'width' : '12%',
            'fieldname' : 'Date__c',
            'sorted' : true,
            'asc' : false,
            'sortable' : true
        },
        {
            'label' : 'Created By',
            'width' : '12%',
            'fieldname' : 'CreatedBy.Name',
            'sorted' : false,
            'asc' : true,
            'sortable' : true
        },
        {
            'label' : 'Program',
            'width' : '12%',
            'fieldname' : 'Program__c',
            'sorted' : false,
            'asc' : true,
            'sortable' : true
        },
        {
            'label' : 'Sub-Contract',
            'width' : '13%',
            'fieldname' : 'Sub_Contractor__c',
            'sorted' : false,
            'asc' : true,
            'sortable' : true
        },
        {
            'label' : 'Files?',
            'width' : '9%',
            'fieldname' : 'ContentDocumentLinks',
            'sorted' : false,
            'asc' : true,
            'sortable' : false
        }
    
    ];

    connectedCallback() {
        this.showSpinner = true;
        this.column = JSON.parse(JSON.stringify(this.defaultColumn));
        // console.log('window.location.href', window.location.href.match(/[a-z0-9]\w{4}0\w{12}|[a-z0-9]\w{4}0\w{9}/g)[0]);

        if (window.location.href.includes('/s/'))
            this.recordId = window.location.href.match(/[a-z0-9]\w{4}0\w{12}|[a-z0-9]\w{4}0\w{9}/g)[0];
        this.getCAAssociatedWithContract(null, null, null, null);
    }

    handlePageChange(event) {
        let pageNumber = event.target.value;
        this.page = pageNumber;
        this.displayRecordPerPage(this.page);
    }

    //options functions
    handleTypeName(event) {
        this.type = event.detail.value;
        if(this.type != '---SELECT---') {
            this.showSpinner = true;
            if(this.searchKey && this.type)
                this.getCAAssociatedWithContract(this.searchKey, this.type, null, null);
            else if(this.type)
                this.getCAAssociatedWithContract(null, this.type, null, null);
            else 
                this.handleRefresh();
        }
        else if(this.searchKey) {
            this.getCAAssociatedWithContract(this.searchKey, null, null, null);
        }
        else {
            this.handleRefresh();
        }
    }

    get options() {
        return [
            { label: '---SELECT---', value: '---SELECT---' },
            { label: 'Billable Activity', value: 'Billable Activity' },
            { label: 'Deliverable', value: 'Deliverable' },
        ];
    }

    handleKeyUp(event) {
        const isEnterKey = event.keyCode === 13;    

        if (isEnterKey) {
            this.showSpinner = true;
            this.searchKey= event.target.value;
            if(this.type != '---SELECT---' && this.searchKey) {
                this.getCAAssociatedWithContract(this.searchKey,this.type, null, null);
            }
            else if(this.searchKey) {
                this.getCAAssociatedWithContract(this.searchKey, null, null, null);
            }
            else if(this.type != '---SELECT---' ) {
                this.getCAAssociatedWithContract(null, this.type , null, null);
            }
            else {
                this.handleRefresh();
            }
        }
    }

    handleRefresh() {
        this.showSpinner = true;
        this.type = null;
        this.searchKey = null;
        this.column = JSON.parse(JSON.stringify(this.defaultColumn));
        this.getCAAssociatedWithContract(null, null, null, null);
    }

    handleSort(event) {
        this.showSpinner = true;
        let fieldName = event.target.dataset.fieldname;

        this.column.asc = !this.column.asc;
        this.column.sorted = true;

        let columnSort = '';
        this.column.map(item => {
            if(item.sorted && fieldName !== item.fieldname) {
                item.sorted = false;
            }
            else if(fieldName === item.fieldname) {
                item.asc = !item.asc;
                item.sorted = true;
                columnSort = item.asc;
            }
        });
        this.getCAAssociatedWithContract(null, null, fieldName, columnSort);
    }


    getCAAssociatedWithContract(searchKey, type, sortFieldName, sortDirection) {
        getCAAssociatedWithContract({
            recordId : this.recordId,
            searchKey : searchKey,
            type : type,
            sortFieldName : sortFieldName,
            sortInAscending : sortDirection
        })
        .then(result => {
            if(result && result.length > 0) {
                this.result = JSON.parse(JSON.stringify(result));
                this.grant = this.result[0].Contract__r.Grant__c;
                console.log('this.grant ---->',this.grant );
                this.recordCount = this.result.length;
                this.showData = true;

                //used for pagination
                this.page = 1;
                this.items = this.result;
                this.totalRecountCount = this.result.length; 
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                this.data = this.items.slice(0, this.pageSize);
                this.endingRecord = this.pageSize;

                this.checkFiles();
                this.showSpinner = false;
            }
            else {
                this.recordCount = 0;
                this.showData = false;
                this.showSpinner = false;
            }

        })
        .catch(error => {
            let message = error.message || error.body.message;
            this.ShowToastEvent('' , message , 'error');
            this.showSpinner = false;
        });
    }

    checkFiles = () => {
        let sum = 0;
        this.result.map(item => {
            sum += item.Amount__c;
            if(item.ContentDocumentLinks) {
                item['checkFilesAndCount'] = 'Yes (' + item.ContentDocumentLinks.length + ')';
            }
            else {
                item['checkFilesAndCount'] = 'No';
            }
        });

        if(sum >= 0) {
            this.invoiceAmountSum = sum;
            console.log('Invoice Amount sum', this.invoiceAmountSum);
        }
    }

    //navigation
    navigateToCA(event) {
        this.showSpinner = true;

        let contractActivity = event.target.name;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: contractActivity,
                objectApiName: 'Contract_Activity__c',
                actionName: 'view'
            }
        });

        this.showSpinner = false;
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

    //Paginator functions
    previousHandler() {
        this.showSpinner = true;
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    nextHandler() {
        this.showSpinner = true;
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
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