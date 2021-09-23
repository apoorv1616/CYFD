import { LightningElement,track, api } from 'lwc';

export default class Multiselect_picklist extends LightningElement {

    @api isRequired;
    @api allowSearch;
    @api isInvalid;
    @api requiredErrorMessage;

    @track showOptions = false; 
    @track items = [];
    @track pillList = []; 
    @track filterValue = "";

    _allOptions;
    _selectedOptions = [];
    accessKey; 
    _selectedValues = [];

    _closeDropdownHandler;

    connectedCallback() {
        document.addEventListener('click', this._closeDropdownHandler = this.handleCloseDropdown.bind(this));
    }

    disconnectedCallback() {
        document.removeEventListener('click', this._closeDropdownHandler);
    }

    handleCloseDropdownAfterEventVerification(event) {
        event.stopPropagation();
        return false;
    }

    @api 
    get allOptions(){
        return this._allOptions;
    }      
    set allOptions(options) {
        if(options) {
            this._allOptions = options;  
            this.pillList = this._allOptions;
        }
        else {
            this._allOptions = [];  
            this.pillList = [];
        }
        
    }

    @api
    get selectedOptions() {
        console.log('called get options ');
        return this._selectedOptions;
       //return _selectedValues;
    }

    set selectedOptions(options) {

        if(options) {
            this._selectedOptions = options;
        }
        else {
            this._selectedOptions = [];
        }
        
    }

    @api
    get value(){ 
        let selectedOptionsValue = [];
        if(this._selectedOptions){
            this._selectedOptions.forEach(item => {
                selectedOptionsValue.push(item.value);                
            })
        }
        return selectedOptionsValue.join(';');
    }

    @api
    getselectedValues(){ 
        let selectedOptionsValue = [];
        if(this._selectedOptions){
            this._selectedOptions.forEach(item => {
                selectedOptionsValue.push(item.value);                
            })
        }
        return selectedOptionsValue.join(';');
    }
    
    handleItemRemove(event){ 
        const optionIndex = event.detail.index;
        if(optionIndex || optionIndex === 0) {
            this._selectedOptions = [... this._selectedOptions];
            this._selectedOptions.splice(optionIndex, 1);
       
            const selectedEvent = new CustomEvent('selected', { detail: this._selectedOptions }); 
            this.dispatchEvent(selectedEvent);
            this.validateValue();
        }
    }

    toggelOption(event){ 
        this.filterValue = "";
        this.showOptions = (this.showOptions) ? false : true;
    }

    select(event) { 
        if(event && event.target && event.target.dataset) {
            let selectedOption = this._allOptions.find(element => element.value == event.target.dataset.id);
            if(selectedOption && selectedOption.value) {
                event.preventDefault();
                this._selectedOptions = [... this._selectedOptions];
                this._selectedOptions.push(selectedOption);
                const selectedEvent = new CustomEvent('selected', { detail: this._selectedOptions }); 
                this.dispatchEvent(selectedEvent);
                this.validateValue();
            }
        }
    }

    sortRecords(records, sortBy, sortOrder){
        records.sort(function(a,b){
            var dataA,dataB;
            if(sortBy.includes(".")){
                dataA = a;
                dataB = b;
                sortBy.split(".").forEach(function(f){
                    if(dataA){
                        dataA = dataA[f];
                    }
                    if(dataB){
                        dataB = dataB[f];
                    }
                })
            }else{
                dataA = a[sortBy];
                dataB = b[sortBy];
            }
            var t1 = dataA == dataB, t2 = dataA < dataB;
            return t1? 0: (sortOrder=="asc"?-1:1)*(t2?1:-1);
        })
        return records;
    }

    handleCloseDropdown(event) {
        this.filterValue = "";
        let targetName = "";
        if(event && event.target) {
            targetName = event.target.name;
        }
        if(targetName != "multi_select_cmp") {
            this.showOptions = false;
        }
    }

    @api
    validateValue() {
        if(this.isRequired) {
            if(this.value) {
                this.isInvalid = false;
            }
            else {
                this.isInvalid = true;
            }
        }
    }

    filterOptions(event) {
        this.filterValue = event.target.value;
        if(this.showOptions == false) {
            this.showOptions = true;
        }
    }
 
    get showList(){ 
        return (this.showOptions) ? "slds-form-element slds-lookup slds-is-open" : "slds-form-element slds-lookup slds-is-close" 
    }
    
    get noOptionsAvaialble(){
        return (this.nonSelectedOptions.length <= 0) ? "slds-lookup__result-text slds-show" : "slds-lookup__result-text slds-hide";
    }

    get noMatchingOptionFound() {
        if(this.filterValue && this.showList && this.availableOptions.length == 0) {
            return true;
        }
        return false;
    }

    get nonSelectedOptions() {
        let options = [];
        let selectedOptionsValues = [];
        if(this._selectedOptions){
            this._selectedOptions.forEach(item => {
                selectedOptionsValues.push(item.value);                
            })
        }
        if(this._allOptions && this._allOptions.length > 0) {
            this._allOptions.forEach(item => {
                if(! selectedOptionsValues.includes(item.value)) {
                    options.push(item);
                }             
            })
        }
        return options;
    }

    get availableOptions() {
        console.log('##1########')
        if(this.filterValue) {
            console.log('###2########')
            let matchingOptions = [];
            let all_options = this.nonSelectedOptions;
            let upperCaseFilter = this.filterValue.toUpperCase();
            upperCaseFilter = upperCaseFilter.trim();
            for(let i = 0; i < all_options.length; i ++) {
                let optionLabelUpperCase = "";
                if(all_options[i].label) {
                    optionLabelUpperCase = all_options[i].label;
                }
                optionLabelUpperCase = optionLabelUpperCase.toUpperCase();
                optionLabelUpperCase = optionLabelUpperCase.trim();
                if(optionLabelUpperCase.indexOf(upperCaseFilter) >= 0) {
                    matchingOptions.push(all_options[i]);
                }
            }
            return matchingOptions;
        }
        return this.nonSelectedOptions;
    }

    get renderErrorMessage() {
        if(this.isInvalid && !this.showOptions) {
            return true;
        }
        return false;
    }

    get additionalClass() {
        if(this.isInvalid) {
            return "slds-has-error";
        }
        return "";
    }

    get requiredFieldErrorMessage() {
        if(this.requiredErrorMessage) {
            return this.requiredErrorMessage;
        }
        return "Complete this field !";
    }

    get allowSearching() {
        if(this.allowSearch && this.showOptions) {
            return true;
        }
        return false;
    }

}