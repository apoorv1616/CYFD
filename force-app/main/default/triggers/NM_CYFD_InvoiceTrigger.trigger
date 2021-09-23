trigger NM_CYFD_InvoiceTrigger on Invoice__c (before update, after update, before insert, after insert) {

    Triggers_Configuration__mdt triggerConfiguration = [SELECT MasterLabel, isActive__c FROM Triggers_Configuration__mdt
            WHERE MasterLabel = 'InvoiceTrigger' LIMIT 1 ];

    if(triggerConfiguration.isActive__c){
        if(Trigger.isBefore && Trigger.isUpdate){
            NM_CYFD_InvoiceTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);    
        }
        
        if(Trigger.isAfter && Trigger.isUpdate){
            NM_CYFD_InvoiceTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);    
        }
        
        if(Trigger.isAfter && Trigger.isInsert){
            NM_CYFD_InvoiceTriggerHandler.afterInsert( Trigger.new );    
        }
    }
}