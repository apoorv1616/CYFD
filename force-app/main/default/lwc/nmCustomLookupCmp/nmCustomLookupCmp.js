import { LightningElement, track, api } from 'lwc';
import findRecords from '@salesforce/apex/NM_CYFD_ActivityController.findActivityRecords';
export default class OkCustomLookupCmp extends LightningElement {
    @track records;
    @track error;
    @track selectedRecord;
    @api index;
    @api contractId;
    @api relationshipfield;
    @api iconname = "standard:account";
    @api objectName = '';
    @api searchfield = 'Name';
    @api contractConfigId ;

    handleOnchange(event){
        //event.preventDefault();
        const searchKey = event.detail.value;
        findRecords({
            searchKey : searchKey, 
            contractId : this.contractId,
            contractConfigId : this.contractConfigId
        })
        .then(result => {
            this.records = result;
            for(let i=0; i < this.records.length; i++){
                const rec = this.records[i];
                this.records[i].activityLabel = rec.activityLabel;
            }
            this.error = undefined;
            //console.log(' records ', this.records);
        })
        .catch(error => {
            this.error = error;
            this.records = undefined;
        });
    }
     handleSelect(event){
        this.selectedRecord = event.detail;
        const value = this.selectedRecord;
        const valueChangeEvent = new CustomEvent("select", {
        detail: this.selectedRecord
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
    }

    handleRemove(event){
        event.preventDefault();
        this.selectedRecord = undefined;
        this.records = undefined;
        this.error = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "removeactivity",
            {
                detail : 'remove'
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }


}