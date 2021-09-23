trigger NM_CYFD_ContractActivityTrigger on Contract_Activity__c (before insert,before update, after insert,after update,before delete,after delete) {
    
    Triggers_Configuration__mdt triggerConfiguration = [SELECT MasterLabel, isActive__c FROM Triggers_Configuration__mdt
                                                        WHERE MasterLabel = 'ContractActivityTrigger' LIMIT 1 ];
            
    if(triggerConfiguration.isActive__c) {
        
        if( Trigger.isBefore && Trigger.isInsert ) {
            NM_CYFD_ContractActivityTriggerHandler.populateHiddenActivityLabelAndSubcontractorScript(Trigger.new, null);
        }
        if( Trigger.isBefore && Trigger.isUpdate ) {
               	NM_CYFD_ContractActivityTriggerHandler.populateHiddenActivityLabelAndSubcontractorScript(Trigger.new, Trigger.oldMap);
        }
        
        if( Trigger.isAfter && Trigger.isUpdate ){
            
            NM_CYFD_ContractActivityTriggerHandler.rollUpInvoiceAmountToInvoice(Trigger.new,Trigger.oldMap);
            
            //if(!NM_CYFD_ContractActivityTriggerHandler.stopThrowErrorForDuplicateDeliverableContract)
            	NM_CYFD_ContractActivityTriggerHandler.throwErrorForDuplicateDeliverableContract(Trigger.new, Trigger.oldMap);
            //updates work only for mentoring
            if (!NM_CYFD_ContractActivityTriggerHandler.stopUpdateExpenditureAmounts)
               	NM_CYFD_ContractActivityTriggerHandler.updateExpenditureAmounts(Trigger.new, Trigger.oldMap);
            
        }
       
        if( Trigger.isAfter && Trigger.isDelete ){
        	NM_CYFD_ContractActivityTriggerHandler.rollUpInvoiceAmountToInvoice(null, Trigger.oldMap);
            
           	if (!NM_CYFD_ContractActivityTriggerHandler.stopUpdateExpenditureAmounts)
               	NM_CYFD_ContractActivityTriggerHandler.updateExpenditureAmounts(Trigger.new, Trigger.oldMap);
        }
        
        if( Trigger.isAfter && Trigger.isInsert) {
            //if(!NM_CYFD_ContractActivityTriggerHandler.stopThrowErrorForDuplicateDeliverableContract)
            	NM_CYFD_ContractActivityTriggerHandler.throwErrorForDuplicateDeliverableContract(Trigger.new, null);
             
            NM_CYFD_ContractActivityTriggerHandler.rollUpInvoiceAmountToInvoice(Trigger.new, null);
            
            if (!NM_CYFD_ContractActivityTriggerHandler.stopUpdateExpenditureAmounts)
            	NM_CYFD_ContractActivityTriggerHandler.updateExpenditureAmounts(Trigger.new, Trigger.oldMap);
        }
        
    }          
}