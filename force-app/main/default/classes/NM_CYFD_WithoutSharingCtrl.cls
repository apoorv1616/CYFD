public without sharing class NM_CYFD_WithoutSharingCtrl {
    
    public static List<Contract_Configuration_Line_Item__c> getConfigurationLineItemRecords ( String contractConfigId, Id activityRecordTypeId ) {

        return [ SELECT Id, CYFD_Activity__c, Sub_Contractor__c, CYFD_Activity__r.Name, CYFD_Activity__r.Activity_Label__c 
                FROM Contract_Configuration_Line_Item__c
                WHERE Contract_Configuration__c = :contractConfigId
                AND CYFD_Activity__r.RecordTypeId = :activityRecordTypeId
                AND CYFD_Activity__r.Active__c = true];
    }

    public static List<Contract_Configuration_Line_Item__c> getConfigurationLineItemRecordsById ( String lineItemId ) {

        return [SELECT Id, CYFD_Activity__c,Program__c, Match_Contribution_Enabled__c , Contract_Configuration__c, CYFD_Activity__r.Activity_Type__c, 
                Activity_Allocated_Amount__c , Sub_Contract_Allocated_Amount__c , Sub_Contractor__c , Program_Allocated_Amount__c, 
                CYFD_Activity__r.Activity_Rate__c, CYFD_Activity__r.Name, CYFD_Activity__r.Activity_Label__c, CYFD_Activity__r.Unit_Type__c, 
                CYFD_Activity__r.Program__c 
                FROM Contract_Configuration_Line_Item__c
                WHERE Id = :lineItemId
                LIMIT 1];
    }

    public static void upsertSObjectList( List<Sobject> sobjectList ) {
        upsert sobjectList;
    }
    
    public static void insertSObjectList( List<Sobject> sobjectList ) {
        insert sobjectList;
    }
    
    public static Sobject upsertObject( Sobject obj ) {
        upsert obj;
        return obj;
    }
    
}