import { LightningElement, track, api } from 'lwc';
import getFilesAssociatedWithCA from '@salesforce/apex/NM_CYFD_DeleteFilesOnCAController.getFilesAssociatedWithCA';
import deleteFiles from '@salesforce/apex/NM_CYFD_DeleteFilesOnCAController.deleteFiles';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NM_CYFD_DeleteFilesOnCA extends NavigationMixin(LightningElement) {
    @track recordCount = 0;
    @track result = [];
    @track showData = false;
    @api recordId;
    @track showSpinner = false;

    //Pagination Variables
    @track page = 0;
    @track items = [];
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = 5;
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track data = [];

    handleKeyUp(event) {
        const isEnterKey = event.keyCode === 13;

        if (isEnterKey) {
            this.showSpinner = true;
            let searchKey = event.target.value;
            this.getFilesAssociatedWithCA(searchKey);

        }
    }

    handleRefresh() {
        this.showSpinner = true;
        this.getFilesAssociatedWithCA(null);
    }

    handleInputChange(event) {
        // this.resultForAdd = [...this.result];
        var indexselect = this.result.findIndex(x => x.Id == event.target.dataset.id);
        if(indexselect > -1){
            this.result[indexselect].isSelected = event.target.checked;
        }
        console.log(JSON.stringify(this.result));
    }

    column = [
        {
            'label' : 'Action',
            'width' : '13%'
        },
        {
            'label' : 'Contract Activity',
            'width' : '20%'
        },
        {
            'label' : 'File Name',
            'width' : '50%'
        },
        {
            'label' : 'File Type',
            'width' : '15%'
        }    
    ];

    connectedCallback() {
        this.showSpinner = true;
        this.getFilesAssociatedWithCA(null);
    }

    getFilesAssociatedWithCA(searchKey) {
        getFilesAssociatedWithCA({
            recordId : this.recordId,
            searchKey : searchKey
        })
        .then(result => {
            if(result && result.length > 0) {
                this.result = JSON.parse(JSON.stringify(result));
                this.recordCount = this.result.length;
                this.showData = true;

                //used for pagination
                this.page = 0;
                this.items = this.result;
                this.totalRecountCount = this.result.length; 
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                this.data = this.items.slice(0, this.pageSize);
                this.endingRecord = this.pageSize;

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

    handleDelete() {
        this.showSpinner = true;
        let selectedArr = [];
        if(this.result.length > 0) {
            this.result.forEach(function(item,ind) {
            if(item.isSelected) {
                selectedArr.push(item);
            }
            });
        }
        console.log('selectedArr ' + JSON.stringify(selectedArr));
        if(selectedArr.length < 1) {
            this.ShowToastEvent('' , 'No Data Selected!' , 'warning');
            this.showSpinner = false;
            return;
        }
        else {
            this.deleteFiles(selectedArr);
        }
    }

    deleteFiles(selectedArr) {
        deleteFiles({
            wrapperList : JSON.stringify(selectedArr)
        })
        .then(result => {
            this.ShowToastEvent('Files Deleted successfully!' , '' , 'success');
            this.handleRefresh();
        })
        .catch(error => {
            let message = error.message || error.body.message;
            this.ShowToastEvent('' , message , 'error');
            this.showSpinner = false;
        });
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