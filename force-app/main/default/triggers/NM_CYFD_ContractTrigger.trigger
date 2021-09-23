trigger NM_CYFD_ContractTrigger on Contract__c (before insert,after insert, before update, after update) {
 
    Triggers_Configuration__mdt triggerConfiguration = [SELECT MasterLabel, isActive__c FROM Triggers_Configuration__mdt
            WHERE MasterLabel = 'ContractTrigger' LIMIT 1 ];

    if(triggerConfiguration.isActive__c){
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                NM_CYFD_ContractTriggerHandler.afterInsert(Trigger.New);
            }
            if(Trigger.isUpdate){
                NM_CYFD_ContractTriggerHandler.afterUpdate(Trigger.New, Trigger.oldMap);
            }
        }
        
        
    }    
}