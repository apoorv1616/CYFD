trigger NM_CYFD_ContentDocumentLinkTrigger on ContentDocumentLink (before insert, before update) {
    Triggers_Configuration__mdt triggerConfiguration = [SELECT MasterLabel, isActive__c 
                                                        FROM Triggers_Configuration__mdt
            											WHERE MasterLabel = 'ContentDocumentLinkTrigger' 
                                                        LIMIT 1 ];
    if(triggerConfiguration.isActive__c) {
        if(Trigger.isBefore) {
            //Before Insert
            if(Trigger.isInsert) {
                NM_CYFD_ContentDocLinkTriggerHandler.beforeInsert(Trigger.new);
            }
            //Before Update
            /*
            if(Trigger.isUpdate) {
                NM_CYFD_ContentDocLinkTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
            }  */
            
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