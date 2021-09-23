trigger NM_CYFD_ActivityRoleTrigger on Activity_Role__c ( before insert, before update, after insert, after delete, before delete ) {

    Triggers_Configuration__mdt triggerConfiguration = [SELECT MasterLabel, isActive__c FROM Triggers_Configuration__mdt
            WHERE MasterLabel = 'ActivityRoleTrigger' LIMIT 1 ];

    Public static Boolean bulkUpdate = Label.nmcyfdBulkUpdateExpenditure == 'true';
    
    if(triggerConfiguration.isActive__c) {
        
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                NM_CYFD_ActivityRoleTriggerHandler.populateContractOnActivityRole(Trigger.new, null);
            }
            if (Trigger.isUpdate) {
                NM_CYFD_ActivityRoleTriggerHandler.populateContractOnActivityRole(Trigger.new, Trigger.oldMap);
            }
        }

        if(Trigger.isAfter && Trigger.isInsert) {

            NM_CYFD_ActivityRoleTriggerHandler.updateYouthNamesOnStaffRecords(Trigger.new,null);
            NM_CYFD_ActivityRoleTriggerHandler.updateContractActivityAmountForMentoring( Trigger.new, null );
        }
        if (bulkUpdate) {
            NM_CYFD_ActivityRoleTriggerHandler.updateContractActivityAmountForMentoring(Trigger.new, null);
        }
        if(Trigger.isAfter && Trigger.isDelete) {
            NM_CYFD_ActivityRoleTriggerHandler.updateContractActivityAmountForMentoring( Trigger.new, Trigger.oldMap );
        }
    }
    
}