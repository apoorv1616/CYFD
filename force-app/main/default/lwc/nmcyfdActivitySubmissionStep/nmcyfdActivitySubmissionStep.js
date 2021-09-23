import { LightningElement, track, api} from 'lwc';
import deleteDocument from '@salesforce/apex/NM_CYFD_ActivityController.deleteDocument';

export default class NmcyfdActivitySubmissionStep extends LightningElement {
    @api contractId;
    @api contract;
    @api activityData;
    @track docs = [];
    @track addFile = false;
    @track heading = 'Add Document';
    @api contractActivityId;

    get acceptedFormats() {
        return ['.pdf', '.png'];
    }

    @api returnData(){
        return this.docs;
    }

    connectedCallback(){
        if(this.activityData.length != 0){
            this.docs = JSON.parse(JSON.stringify(this.activityData));
        }
    }

    addDocument(){
        this.addFile = true;
    }

    handleCloseModal(){
        this.addFile = false;
    }

    handleUploadFinished(event) {
        var document = {};
        var fileDets = event.detail.files[0];
        var index = fileDets.name.lastIndexOf(".");
        var type = fileDets.name.substring(index+1, fileDets.name.length);
        document.name = fileDets.name;
        document.type = type;
        document.id = fileDets.documentId ;
        this.docs.push(document);
        // Get the list of uploaded files
        
    }
    handleDeleteFile(event){
        var docId = event.target.dataset.id;
        var index = event.target.dataset.index;
        deleteDocument({documentId : docId}).then(result =>{
            this.docs.splice(index, 1);
        
        }).catch(error=>{
            console.log('error --> ', error);
        });
    }



}