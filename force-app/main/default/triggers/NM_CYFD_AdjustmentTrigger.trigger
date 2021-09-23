trigger NM_CYFD_AdjustmentTrigger on Adjustment__c (before insert, after insert, before update, after update) {
	Triggers_Configuration__mdt triggerConfiguration = [SELECT MasterLabel, isActive__c 
                                                        FROM Triggers_Configuration__mdt
            											WHERE MasterLabel = 'AdjustmentTrigger' 
                                                        LIMIT 1 ];
    if(triggerConfiguration.isActive__c){
        if(Trigger.isBefore) {
            //Before Insert
            if(Trigger.isInsert) {
                NM_CYFD_AdjustmentTriggerHandler.beforeInsert(Trigger.new);
            }
            //Before Update
            if(Trigger.isUpdate) {
                NM_CYFD_AdjustmentTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
            }
            
        }
        /*
        if(Trigger.isAfter) {
            //After Insert
            if(Trigger.isInsert) {
                
            }
            //After Update
            if(Trigger.isUpdate) {
                
            } 
        } */
    }
}