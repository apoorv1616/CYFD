import { LightningElement,api,track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import readCSV from '@salesforce/apex/BulkUploadCMController.readCSVFile';
import getAllCustomMetadata from '@salesforce/apex/BulkUploadCMController.getAllCustomMetadata';
import getAllCustomMetadataFields from '@salesforce/apex/BulkUploadCMController.getAllCustomMetadataFields';
import getAllCustomMetadRecords from '@salesforce/apex/BulkUploadCMController.getAllCustomMetadRecords';

export default class BulkUploadCustomMetadataFromCSV extends LightningElement {
    @api recordId;
    @track error;
    @track data;
    @track result;
    @track optionsArr;
    @track value;
    @track metadataFields;
    @track showFields;
    @track fields;
    @track recordsToDisplay = [];
    @track now;
    @track showSpinner; 
    @track showData;
    @track lengthOfData;
    @track searchClicked = false;


    connectedCallback() {
        this.showSpinner = true;
        this.getAllCustomMetadata();
    }

    //get all custom metadata in org
    getAllCustomMetadata = () => {
        getAllCustomMetadata()
        .then(result => {
            this.result = JSON.parse(JSON.stringify(result));

            let optionsArr = [];

            this.result.forEach(item => optionsArr.push({'label' : item.label, 'value' : item.fieldAPI}));

            this.optionsArr = optionsArr;
            this.showSpinner = false;

        })
        .catch(error => {
            this.ShowToastEvent(JSON.stringify(error),'','error');
            this.showSpinner = false;
        });
    }

    //get all fields of selected custom metadata
    getAllCustomMetadataFields = () => {
        if(!this.value && this.searchClicked) {
            this.ShowToastEvent('Custom metadata not selected','','warning');
            this.showSpinner = false;
            return;
        }
        getAllCustomMetadataFields({customMetadata : this.value})
        .then(result => {
            let optionsArr = [];
            let fields = '';
            result.forEach(function(item,ind) {
                optionsArr.push({'label' : item.label, 'fieldName' : item.fieldAPI})
                fields += item.fieldAPI + ',';
            });
            this.fields = fields.substring(0,fields.length - 1);

            this.metadataFields = optionsArr;
            
            this.showFields = true;
            this.data = false;
            this.getAllCustomMetadRecords();
        })
        .catch(error => {
            this.ShowToastEvent(JSON.stringify(error),'','error');
            this.showFields = false;
            this.data = false;
            this.showSpinner = false;
        });
    }

    //get all records of selected custom metadata
    getAllCustomMetadRecords = () =>  {
        if(!this.fields && !this.value && this.searchClicked) {
            this.showSpinner = false;
            return;
        }
        getAllCustomMetadRecords({fields : this.fields , customMetadata : this.value})
        .then(result => {
            if(result) {
                this.data = JSON.parse(JSON.stringify(result));
                this.lengthOfData = this.data.length;
                this.recordsToDisplay = [...this.data];
                this.showData = this.recordsToDisplay.length > 0 ? true : false;
                this.showSpinner = false;
            }
            else {
                this.ShowToastEvent(JSON.stringify(error),'','warning');
                this.showData = false;
                this.showSpinner = false;
            }
            
        })
        .catch(error => {
            this.ShowToastEvent(JSON.stringify(error),'','error');
            this.showSpinner = false;
            this.showData = false;
        })
    }


    handleDelete = () => {
        let selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows(); 
        console.log('selectedRows ' , JSON.stringify(selectedRows));

    }

    //download custom metadata template
    handleDownload = () => {
        this.showSpinner = true;
        if(!this.value && this.searchClicked) {
            this.ShowToastEvent('Custom metadata not selected','','warning');
            this.showSpinner = false;
            return;
        }
        this.downloadData();
    }


    handleSelectedMetadataChange = (event) => {
        this.value = event.detail.value;
    }

    handleRefresh = () => {
        if(!this.value && this.searchClicked) {
            this.ShowToastEvent('Custom metadata not selected','','warning');
            this.showSpinner = false;
            return;
        }
        this.showSpinner = true;
        this.showData = false;
        this.currentDate();
        this.handleSearch();
    }

    handleSearch = () => {
        this.showSpinner = true;
        this.searchClicked = true;
        if(!this.value && this.searchClicked) {
            this.ShowToastEvent('Custom metadata not selected','','warning');
            this.showSpinner = false;
            return;
        }
        this.getAllCustomMetadataFields();
    }

    //Upload functionality starts
    
    // accepted parameters
    get acceptedFormats() {
        return ['.csv'];
    }
    
    handleUploadFinished = (event) => {
        if(!this.value) {
            this.ShowToastEvent('Custom metadata not selected','','warning');
            return;
        }
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        
        // calling apex class
        readCSV({idContentDocument : uploadedFiles[0].documentId, metadataName : this.value , fields : this.fields})
        .then(result => {
            this.data = result;
            this.handleSearch();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: '',
                    variant: 'success',
                }),
            );
            
        })
        .catch(error => {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: JSON.stringify(error),
                    variant: 'error',
                }),
            );     
        })

    }

    //Upload functionality ends

    handlePaginatorChange(event) {
        this.showSpinner = true;
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
        this.showSpinner = false;
    }
    

    downloadData = () => {
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        
        // splitting using ','
        csvString = this.fields;

        

        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = this.value + '.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
        this.showSpinner = false;
    }
}