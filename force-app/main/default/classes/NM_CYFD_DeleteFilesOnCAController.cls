/*
    * Author : Apoorv Anand
    * Issue  : I-58115
    * Desc   : this class is used to delete files related to Contract Activity.

*/
public with sharing class NM_CYFD_DeleteFilesOnCAController {

    /*
        * Desc : Get content document query.
    */
    public static List<ContentDocumentLink> getContentDocumentListFromQuery(String recordId, String searchKey) {

        String query = ' SELECT Id, LinkedEntityId,LinkedEntity.Name, '
                     + ' ContentDocumentId, ContentDocument.Title,ContentDocument.FileType, '
                     + ' ContentDocument.Description, Visibility '
                     + ' FROM ContentDocumentLink '
                     + ' WHERE LinkedEntityId = :recordId ';
        
        if(String.isNotBlank(searchKey)) {
            String key = '%' + searchKey + '%';

            query += ' AND (LinkedEntity.Name LIKE :key OR ContentDocument.Title LIKE :key OR ContentDocument.FileType LIKE :key) ';
        }
        return Database.query(query);
    }

    /*
        * Desc : This method is used to fetch all the files related to Contract Activity.
    */
    @AuraEnabled
    public static List<Files> getFilesAssociatedWithCA(String recordId, String searchKey) {

        List<Files> filesList = new List<Files>();

        if(String.isNotBlank(recordId)) {
            for(ContentDocumentLink linkRecord : getContentDocumentListFromQuery(recordId, searchKey)) {
                
                filesList.add(new Files(linkRecord));
            }
        }
        return filesList;
    }

    /*
        * Desc : This method is used to delete the selected files related to Contract Activity.
    */

    @AuraEnabled
    public static void deleteFiles(String wrapperList) {
        List<Files> filesList = (List<Files>) JSON.deserialize(wrapperList, List<Files>.class);

        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();

        for(Files filesRecord : filesList) {
            if(filesRecord.isSelected) {
                contentDocumentLinkList.add(new Files().getContentDocumentLinkFromFiles(filesRecord));
            }
            
        }

        if(!contentDocumentLinkList.isEmpty()) {
            delete contentDocumentLinkList;
        }

    }

    /*
        * Desc : File class wrapper.
    */

    public class Files {

        @AuraEnabled public String Id;
        @AuraEnabled public Boolean isSelected;
        @AuraEnabled public String contractActivity;
        @AuraEnabled public String contractActivityName;
        @AuraEnabled public String title;
        @AuraEnabled public String fileType;

        //Empty constructor
        public Files() {}

        //constructor with argument ContentDocumentLink
        public Files(ContentDocumentLink contentDocumentLinkRecord) {

            this.Id = contentDocumentLinkRecord.Id;
            this.contractActivity = contentDocumentLinkRecord.LinkedEntityId;
            this.contractActivityName = contentDocumentLinkRecord.LinkedEntity.Name;
            this.title = contentDocumentLinkRecord.ContentDocument.Title;
            this.fileType = contentDocumentLinkRecord.ContentDocument.FileType;
            this.isSelected = false;
        }

        public ContentDocumentLink getContentDocumentLinkFromFiles(Files fileRecord) {

            ContentDocumentLink contentDocumentLinkRecord = new ContentDocumentLink();
            contentDocumentLinkRecord.Id = fileRecord.Id;
            return contentDocumentLinkRecord;

        }

    }
}