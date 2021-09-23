import { LightningElement,track, api } from 'lwc';
import getExpenditureAmount from '@salesforce/apex/NmcyfdExprenditureAmountOnCAController.getExpenditureAmount';
import getProgramSupportFee from '@salesforce/apex/NmcyfdExprenditureAmountOnCAController.getProgramSupportFee';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import NM_CYFD_NoDataFound from '@salesforce/resourceUrl/NM_CYFD_NoDataFound';

export default class NmcyfdExprenditureAmountOnCA extends NavigationMixin(LightningElement)  {
    @track showSpinner = false;
    @track alreadyAdded = false;
    @api recordId;
    @api grant;
    @track data = [];
    @track showHandlePreview = false;
    @track contractName;
    @track showAllTabsForContract = 'New Mexico Alliance';
    @track hasProgramSupportFee = true;

    @track hasActivityLabel = false;
    @track hasProgram = false;
    @track hasSubcontractor = false;
    @api contractPage = false;
    NM_CYFD_NoDataFound = NM_CYFD_NoDataFound;

    @track grant;
    @track activityId;
    @track contractId;
    @track label;
    @track hasLineItem = false;
    @track hasMatchAmount = false;
    @track grantNotMentoring = false;
    @track programSupportFee = 0;


    @track activityColumn  = [
        {
            'label' : 'Action',
            'fieldname' : 'action',
            'width' : '12%'
        },
        {
            'label' : 'Activity Label',
            'fieldname' : 'Activity_Label',
            'width' : '15%'
        },
        
        {
            'label' : 'Activity Expenditure ',
            'fieldname' : 'Activity_Expenditure_Amount',
            'width' : '20%'
        }
        // {
        //     'label' : 'Activity Allocated Amount ',
        //     'fieldname' : 'Allocated_Amount',
        //     'width' : '25%'
        // }
    ];

    @track programColumn  = [
        {
            'label' : 'Action',
            'fieldname' : 'action',
            'width' : '12%'
        },
        {
            'label' : 'Program ',
            'fieldname' : 'program',
            'width' : '15%'
        },
        {
            'label' : 'Program Expenditure',
            'fieldname' : 'Program_Expenditure_Amount',
            'width' : '20%'
        },
        {
            'label' : 'Program Allocated Amount',
            'fieldname' : 'Allocated_Amount',
            'width' : '25%'
        }
    ];

    @track subcontractorColumn  = [
        {
            'label' : 'Action',
            'fieldname' : 'action',
            'width' : '12%'
        },
        {
            'label' : 'Sub-contractor',
            'fieldname' : 'Sub_Contractor',
            'width' : '15%'
        },
        {
            'label' : 'Sub-contractor Expenditure',
            'fieldname' : 'Sub_Contract_Expenditure_Amount',
            'width' : '20%'
        },
        {
            'label' : 'Sub-contractor Allocated Amount',
            'fieldname' : 'Allocated_Amount',
            'width' : '25%'
        }
    ];

    get showProgramSupportFee() {
        let allowedGrant = ['JCC', 'JJAC'];
        return this.hasProgramSupportFee && this.contractPage && allowedGrant.includes(this.grant);
    }

    get showActivityExpenditure() {
        let allowedGrant = ['JCC', 'JJAC', 'Mentoring'];
        return this.grant && this.contractName && (allowedGrant.includes(this.grant) /*|| this.contractName.includes(this.showAllTabsForContract)*/);
    }

    get showProgramExpenditure() {
        let allowedGrant = ['JJAC'];
        return this.grant && this.contractName && (allowedGrant.includes(this.grant) /*|| this.contractName.includes(this.showAllTabsForContract)*/);
    }

    get showSubContratorExpenditure() {
        let allowedGrant = ['JJAC', 'Mentoring'];
        return this.grant && this.contractName && (allowedGrant.includes(this.grant) /*|| this.contractName.includes(this.showAllTabsForContract)*/);
    }

    get showMatchExpenditure() {
        let allowedGrant = ['JJAC'];
        return this.grant && this.contractPage && this.contractName && (allowedGrant.includes(this.grant));
    }

    get showNoData() {
        return !this.showActivityExpenditure && !this.showProgramExpenditure && !this.showSubContratorExpenditure && !this.showMatchExpenditure;
    }

    connectedCallback() {
        this.showSpinner = true;
        if (window.location.href.includes('/s/'))
            this.recordId = window.location.href.match(/[a-z0-9]\w{4}0\w{12}|[a-z0-9]\w{4}0\w{9}/g)[0];
        this.getExpenditureAmount();
    }

    getProgramSupportFee() {

        getProgramSupportFee({
            recordId : this.recordId
        })
        .then( result => {
            this.programSupportFee = JSON.parse(JSON.stringify(result));
            this.hasProgramSupportFee = true;

        })
        .catch( error => {
            this.hasProgramSupportFee = false;;
            let msg = error.message || error.body.message;
            this.ShowToastEvent('',msg,'error');
        });
    }

    getExpenditureAmount() {
        
        getExpenditureAmount({
            recordId : this.recordId
        })
        .then( result => {
            if (result && result.length > 0) {
                this.result = JSON.parse(JSON.stringify(result));
                this.contractName = this.result[0].contractName;

                // console.log(' this.result[0].Program_Support_Fee',this.result[0].Program_Support_Fee);
                this.hasLineItem = this.result[0].hasLineItem;

                if ( !this.grant ) {
                    this.grant = this.result[0].contractGrant;
                    // this.hasProgramSupportFee = false;
                }

                //show Activity Allocated Amount
                if (this.result[0].showActivityAllocatedAmount) {
                    this.activityColumn.push({
                        'label' : 'Activity Allocated Amount ',
                        'fieldname' : 'Allocated_Amount',
                        'width' : '25%'
                    });
                }

                this.result.map( item => {

                    //Activity label
                    if (item.Activity_Label) {
                        item.hasActivityLabel = true;
                        this.hasActivityLabel = true;
                    }
                    else {
                        item.hasActivityLabel = false;
                    }

                    //program
                    if (item.Program) {
                        item.hasProgram = true;
                        this.hasProgram = true;

                    }
                    else {
                        item.hasProgram = false;
                    }

                    //sub-contractor
                    if (item.Sub_Contractor) {
                        item.hasSubcontractor = true;
                        this.hasSubcontractor = true;
                    }
                    else {
                        item.hasSubcontractor = false;
                    }

                    //Activity_Allocated_Amount
                    if ( item.Activity_Allocated_Amount ) {
                        item.hasActivityAllocatedAmount = true;
                    }
                    else {
                        item.hasActivityAllocatedAmount = false;
                    }
                    
                    //Program_Allocated_Amount
                    if ( item.Program_Allocated_Amount ) {
                        item.hasProgramAllocatedAmount = true;
                    }
                    else {
                        item.hasProgramAllocatedAmount = false;
                    }

                    //Sub_Contract_Allocated_Amount
                    if ( item.Sub_Contract_Allocated_Amount ) {
                        item.hasSubContractAllocatedAmount = true;
                    }
                    else {
                        item.hasSubContractAllocatedAmount = false;
                    }

                    //Activity_Expenditure_Amount
                    if ( item.Activity_Expenditure_Amount ) {
                        item.hasActivity_Expenditure_Amount = true;
                    }
                    else {
                        item.hasActivity_Expenditure_Amount = false;
                    }
                });

                this.getProgramSupportFee();

                this.showSpinner = false;
            }
            else {
                this.recordCount = 0;
                this.hasActivityLabel = false;
                this.hasProgram = false;
                this.hasSubcontractor = false;

                this.showSpinner = false;
            }
        })
        .catch( error => {
            this.recordCount = 0;
            console.log('erorr',error);
            let msg = error.message || error.body.message;
            this.ShowToastEvent('',msg,'error');
            this.showSpinner = false;

            this.hasActivityLabel = false;
            this.hasProgram = false;
            this.hasSubcontractor = false;
            
        }); 
    }

    handleRefresh() {
        this.showSpinner = true;
        this.getExpenditureAmount();
    }

    handlePreview(event) {
        this.showSpinner = true;
        this.tabName = event.target.dataset.grant;
        this.activityId = event.target.dataset.activityid;
        this.contractId = event.target.dataset.contractid;
        this.label = event.target.dataset.label;
        
        this.showHandlePreview = true;
        this.showSpinner = false;

    }

    closeModal(event) {

        this.grant = event.detail;
        // console.log('inside close modal--->',this.grant);
        this.showHandlePreview = false;
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
}