trigger NM_CYFD_ContractConfigurationLineItemTrigger on Contract_Configuration_Line_Item__c (after insert) {
  
    Triggers_Configuration__mdt triggerConfiguration = [SELECT MasterLabel, isActive__c FROM Triggers_Configuration__mdt
            WHERE MasterLabel = 'ContractConfigurationLineItemTrigger' LIMIT 1 ];
            
    if(triggerConfiguration.isActive__c){
        if(Trigger.isAfter){
            if(Trigger.isInsert){
            NM_CYFD_ConfigurationItemTriggerHandler.divideActivities(Trigger.new);
            }
        }
    }    
}