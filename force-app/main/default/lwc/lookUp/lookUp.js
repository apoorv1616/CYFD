import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import { api, LightningElement, track, wire } from 'lwc';
import findRecords from '@salesforce/apex/NM_CYFD_ActivityController.findActivityRecords';

let FIELDS = ['Contact.Name'];

export default class LookupLwc extends LightningElement {

    @api valueId;
    @api objName;
    @api iconName;
    @api labelName;
    @api readOnly = false;
    @api filter = '';
    @api showLabel = false;
    @api uniqueKey;
    objLabelName;
    @api contractId;
    @api contractConfigId ;

    /*Create Record Start*/
    @api createRecord;
    @track recordTypeOptions;
    @track createRecordOpen;
    @track recordTypeSelector;
    @track mainRecord;
    @track isLoaded = false;
    @track selectedRecord;
    
    //stencil
    @track cols = [1,2];
    @track opacs = ['opacity: 1', 'opacity: 0.9', 'opacity: 0.8', 'opacity: 0.7', 'opacity: 0.6', 'opacity: 0.5', 'opacity: 0.4', 'opacity: 0.3', 'opacity: 0.2', 'opacity: 0.1'];
    @track double = true;

    //For Stencil
    @track stencilClass = '';
    @track stencilReplacement = 'slds-hide';  
    //css
    @track myPadding = 'slds-modal__content';
    /*Create Record End*/

    searchTerm;
    @track valueObj;
    @api recordName ;
    href;
    @track options; //lookup values
    @track isValue;
    @track blurTimeout;
    @api isSubContractorUser;

    blurTimeout;

    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';

    connectedCallback() {
        if(this.recordName.activityLabel != null ){
            this.selectedRecord = this.recordName;
            this.isValue = true;
        }
    }
    renderedCallback() {
        if(this.objName) {
            let temp = this.objName;
            if(temp.includes('__c')){
                let newObjName = temp.replace(/__c/g,"");
                if(newObjName.includes('_')) {
                    let vNewObjName = newObjName.replace(/_/g," ");
                    this.objLabelName = vNewObjName;
                }else {
                    this.objLabelName = newObjName;
                }
                
            }else {
                this.objLabelName = this.objName;
            }
        }
    
    }
    onSelect1(event) {
        let ele = event.currentTarget;
        let selectedId = ele.dataset.id;
        //As a best practise sending selected value to parent and inreturn parent sends the value to @api valueId
        let key = this.uniqueKey;
       
        
        var name = '';
        var record ;
        this.options.forEach(function(rec){
            if(rec.Id == selectedId){
                name = rec.Name;   
                record = rec;             
            }
        });
       
        this.valueObj = name;
        this.isValue = true;
        const valueSelectedEvent = new CustomEvent('valueselect', {
            detail: { selectedId, key, record },
        });
        this.dispatchEvent(valueSelectedEvent);

        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    /*Used for creating Record Start
    @wire(getObjectInfo, { objectApiName: '$objName' })
    wiredObjectInfo({ error, data }) {
        console.log('data @@@2 ', data)
        if (data) {
            this.record = data;
            this.error = undefined;

            let recordTypeInfos = Object.entries(this.record.recordTypeInfos);
          //  console.log("ObjectInfo length", recordTypeInfos.length);
            if (recordTypeInfos.length > 1) {
                let temp = [];
                recordTypeInfos.forEach(([key, value]) => {
                 //   console.log(key);
                    if (value.available === true && value.master !== true) {
                       // console.log("Inside ifff",JSON.stringify(key,value));
                        
                        temp.push({"label" : value.name, "value" : value.recordTypeId});
                    }
                });
                this.recordTypeOptions = temp;
              //  console.log("recordTypeOptions", this.recordTypeOptions);
            } else {
                this.recordTypeId = this.record.defaultRecordTypeId;
            }

            console.log("this.recordTypeOptions", JSON.stringify(this.recordTypeOptions));
        } else if (error) {
            this.error = error;
            this.record = undefined;
            console.log("this.error #@@@@", this.error);
        }
    }*/
    //Used for creating Record End

  /*  
  -------------------------------------------------------
  @wire(findRecords, {searchKey : '$searchTerm', contractId : this.contractId, contractConfigId : this.contractConfigId})
    wiredRecords({ error, data }) {
        console.log('called %% ');
        if (data) {
            this.record = data;
            this.error = undefined;
            this.options = this.record;
            console.log("common this.options", JSON.stringify(this.options));
        } else if (error) {
            this.error = error;
            this.record = undefined;
            console.log("wire.error",this.error);
        }
    }
    -------------------------------------------------------
    */

  

    handleClick() {
        this.handleOnchange();
        //this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
        //let combobox = this.template.querySelector('#box');
        //combobox.classList.add("slds-is-open"); 
    }

    inblur() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }

   

    onChange(event) {
        this.searchTerm = event.target.value;
        this.handleOnchange();
    }

    handleRemovePill1() {
        this.isValue = false;
        let selectedId = '';
        let key = this.uniqueKey;
        const valueSelectedEvent = new CustomEvent('valueselect', {
            detail: { selectedId, key },
        });
        this.dispatchEvent(valueSelectedEvent);
    }


    handleRecTypeChange(event) {
        this.recordTypeId = event.target.value;
    }

    createRecordMain() {
        this.recordTypeSelector = false;
        this.mainRecord = true;
        //stencil before getting data
        this.stencilClass = '';
        this.stencilReplacement = 'slds-hide';
    }

    handleLoad(event) {
        let details = event.detail;

        if(details) {
            setTimeout(() => {
                this.stencilClass = 'slds-hide';
                this.stencilReplacement = '';
                this.myPadding = 'slds-p-around_medium slds-modal__content';
            }, 1000);
        }

    }

    handleSubmit() {
        this.template.querySelector('lightning-record-form').submit();
    }

    handleError() {

        this.dispatchEvent(
            new ShowToastEvent({
                title : 'Error',
                message : 'Error saving the record',
                variant : 'error',
            }),
        )
    }

    closeModal() {
        this.stencilClass = '';
        this.stencilReplacement = 'slds-hide';
        this.createRecordOpen = false;
        this.recordTypeSelector = false;
        this.mainRecord = false;
    }

    onSelect(event){
        var index = event.currentTarget.dataset.number;      
        this.selectedRecord = this.options[index];
        this.isValue = true;
        const valueChangeEvent = new CustomEvent("select", {
        detail: this.selectedRecord
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
    }

    handleRemovePill(event){
        event.preventDefault();
        this.selectedRecord = undefined;
        this.options = undefined;
        this.error = undefined;
        this.isValue = false;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "removeactivity",
            {
                detail : 'remove'
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }

    handleOnchange(){
        //event.preventDefault();
        findRecords({
            searchKey : this.searchTerm, 
            contractId : this.contractId,
            contractConfigId : this.contractConfigId
        })
        .then(result => {
            this.options = result;
            // for(let i=0; i < this.records.length; i++){
            //     const rec = this.records[i];
            //     this.records[i].activityLabel = rec.activityLabel;
            // }
            this.error = undefined;
            //console.log(' records ', this.records);
        })
        .catch(error => {
            this.error = error;
           // this.records = undefined;
        });
    }
}