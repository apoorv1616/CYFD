public with sharing class NmcyfdCAOnContractController {
    /*
       * Desc : Get contract activity query.
   */
   public static List<Contract_Activity__c> getContractActivityFromQuery(String recordId, String searchKey, String type, String sortFieldName, String sortDirection) {

       String query = ' SELECT Name,Activity_Label__c, Amount__c, Date__c,CreatedById, CreatedBy.Name, Contract__r.Grant__c, '
                    + ' Activity_Expenditure_Amount__c, Program__c, Program_Expenditure_Amount__c, '
                    + ' Sub_Contractor__c, Sub_Contract_Expenditure_Amount__c, Contract__c,Hidden_Name__c, '
                    + ' (SELECT Id, LinkedEntityId,LinkedEntity.Name, ContentDocumentId, ContentDocument.Title,ContentDocument.FileType, '
                    + ' ContentDocument.Description, Visibility '
                    + ' FROM ContentDocumentLinks) ' 
                    + ' FROM Contract_Activity__c '
                    + ' WHERE Contract__c = :recordId ';
       
       if(String.isNotBlank(searchKey)) {
           String key = '%' + searchKey + '%';

           query += ' AND (Activity_Label__c LIKE :key OR Name LIKE :key OR CreatedBy.Name LIKE :key OR Program__c LIKE :key OR Sub_Contractor__c LIKE :key ) ';
       }

       if(String.isNotBlank(type)) {
           query += ' AND RecordType.Name = :type ';
       }

       if(String.isNotBlank(sortFieldName)) {
           query += ' ORDER BY ' + sortFieldName  + ' ' + sortDirection + '  NULLS LAST ';
       }
       else {
           query += ' ORDER BY Date__c DESC NULLS LAST ';
       }

       return Database.query(query);
   }
   
    /*
       * Desc : This method is used to fetch all the files related to Contract Activity.
   */
   @AuraEnabled
   public static List<Contract_Activity__c> getCAAssociatedWithContract(String recordId, String searchKey, String type, String sortFieldName, Boolean sortInAscending) {

       List<Contract_Activity__c> activityList = new List<Contract_Activity__c>();

       if(String.isNotBlank(recordId)) {
           String sortDirection = '';
           if(sortInAscending != null && sortInAscending) {
               sortDirection = ' ASC ';
           }
           else if(sortInAscending != null && !sortInAscending) {   
               sortDirection = ' DESC ';    
           }

           if ( sortFieldName == 'Name' ) {
                sortFieldName = ' Hidden_Name__c ';
           }

           List<Contract_Activity__c> returnedActivityList = getContractActivityFromQuery(recordId, searchKey, type, sortFieldName, sortDirection);
           if(!returnedActivityList.isEmpty()) {
               activityList = returnedActivityList;
           }
       }
       return activityList;
   }

}