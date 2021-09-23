trigger NM_CYFD_ContractRoleTrigger on Contract_Role__c (before insert,after insert, before update, after update) {

    Triggers_Configuration__mdt triggerConfiguration = [SELECT MasterLabel, isActive__c FROM Triggers_Configuration__mdt
            WHERE MasterLabel = 'ContractRoleTrigger' LIMIT 1 ];
    if(triggerConfiguration.isActive__c){
        if(Trigger.IsBefore && Trigger.isInsert){
            NM_CYFD_ContractRoleTriggerHandler.beforeInsert(Trigger.New);
        }
        if(Trigger.IsBefore && Trigger.isUpdate){
            NM_CYFD_ContractRoleTriggerHandler.beforeUpdate(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                NM_CYFD_ContractRoleTriggerHandler.afterInsert(Trigger.New);
            }
            if(Trigger.isUpdate){
                NM_CYFD_ContractRoleTriggerHandler.afterUpdate(Trigger.New, Trigger.oldMap);
            }
        }
    }   
}