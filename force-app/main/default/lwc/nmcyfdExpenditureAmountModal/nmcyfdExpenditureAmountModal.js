import { LightningElement,api,track } from 'lwc';
import getContractActivityRelatedToGrant from '@salesforce/apex/NmcyfdExprenditureAmountOnCAController.getContractActivityRelatedToGrant';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NmcyfdExpenditureAmountModal extends LightningElement {

    @api grant;
    @api contractActivityId;
    @api contractId;
    @api label;
    @track showSpinner = false;
    @api tabName;

    @track searchKey;

    @track result = [];
    //Pagination Variables
    @track page = 1;
    @track items = [];
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = 25;
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track data = [];


    @track hasData = false;

    @track activityColumn  = [
        
        {
            'label' : 'Name',
            'fieldname' : 'Name',
        },
        {
            'label' : 'Activity Date',
            'fieldname' : 'Date__c',
        },
        {
            'label' : 'Invoice Amount',
            'fieldname' : 'Invoice_Amount__c',
        },
        {
            'label' : 'Invoice Name',
            'fieldname' : 'Invoice__r.Name',
        }
    ];

    handleKeyUp(event) {
        const isEnterKey = event.keyCode === 13;  
        
        if (isEnterKey) {
            this.showSpinner = true;
            this.searchKey= event.target.value;
            this.getContractActivityRelatedToGrant();
        }

    }

    connectedCallback() {

        if (this.contractId && this.label &&  this.tabName) {
            this.showSpinner = true;
            this.getContractActivityRelatedToGrant();
        }
    }

    getContractActivityRelatedToGrant() {

        getContractActivityRelatedToGrant({
            contractId : this.contractId,
            label : this.label,
            grant : this.tabName,
            searchKey : this.searchKey
        })
        .then(result => {
            if (result) {
                this.result = JSON.parse(JSON.stringify(result));
                console.log('this.result --->', JSON.stringify(this.result ));
                // this.result.map( item => {
                //     if ( item.Invoice__c ) {
                //         item.hasInvoice = true;
                //     }
                //     else {
                //         item.hasInvoice = false;
                //     }
                // });

                //used for pagination
                this.page = 1;
                this.items = this.result;
                this.totalRecountCount = this.result.length; 
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                this.data = this.items.slice(0, this.pageSize);
                this.endingRecord = this.pageSize;
                this.showSpinner = false;
                this.hasData = true;
                this.searchKey = null;
            }
            else {
                this.showSpinner = false;
                this.hasData = false;
                this.searchKey = null;
            }
        })
        .catch(error => {
            this.hasData = false;
            this.showSpinner = false;
            this.searchKey = null;
            console.log('erorr',error);
            let msg = error.message || error.body.message;
            this.ShowToastEvent('',msg,'error');
        });
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel', {
            detail : this.grant
        }));
        // location.reload();
    }

    handleDownload() {
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();
        let colHeaders = new Set();
        let allowedColumnsForReport = {'invoiceName' : 'Invoice Name', 'name' : 'Contract Activity', 'activityDate' : 'Activity Date','invoiceAmount' : 'Invoice Amount', 'matchAmount' : 'Match Amount'};
        // getting keys from result
        this.result.forEach(function (record) {
            Object.keys(record).forEach(function (key) {

                if (allowedColumnsForReport.hasOwnProperty(key) && allowedColumnsForReport[key]) {
                    colHeaders.add(allowedColumnsForReport[key]);
                    rowData.add(key);
                }
            });
        });
        console.log('rowData--->',colHeaders); 
        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        colHeaders = Array.from(colHeaders);
        // splitting using ','
        csvString += colHeaders.join(',');
        csvString += rowEnd;
        
        // main for loop to get the result based on key value
        for(let i=0; i < this.result.length; i++){
            let colValue = 0;

            // validating keys in result
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = this.result[i][rowKey] === undefined ? '' : this.result[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }

        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'Contract Activity.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
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