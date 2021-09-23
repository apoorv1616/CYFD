trigger NM_CYFD_PaymentTrigger on Payment__c (before insert,before Update, after insert, after update, after delete, after undelete) {
    
    Triggers_Configuration__mdt triggerConfiguration = [SELECT MasterLabel, isActive__c FROM Triggers_Configuration__mdt
            WHERE MasterLabel = 'PaymentTrigger' LIMIT 1 ];

    if(triggerConfiguration.isActive__c){
        if(Trigger.isBefore && Trigger.isInsert){
            NM_CYFD_PaymentTriggerHandler.paymentValidationsOnInsert(Trigger.new);
            NM_CYFD_PaymentTriggerHandler.updateInvoiceStatusToPaid(Trigger.new,null);
        }
        /*if(Trigger.isBefore && Trigger.isUpdate){
            NM_CYFD_PaymentTriggerHandler.insertPaymentOnApproved(Trigger.new,Trigger.oldMap);
        }*/
        
        if(Trigger.isAfter && Trigger.isUpdate){
            NM_CYFD_PaymentTriggerHandler.rollUpAmountToContract(Trigger.new,Trigger.oldMap);
            NM_CYFD_PaymentTriggerHandler.updateInvoiceStatusToPaid(Trigger.new,null);
        }
        if(Trigger.isAfter && Trigger.isInsert){
          //  NM_CYFD_PaymentTriggerHandler.paymentValidationsOnInsert(Trigger.new);
            NM_CYFD_PaymentTriggerHandler.rollUpAmountToContract(Trigger.new,null);
        }
        if(Trigger.isAfter && Trigger.isDelete){
            NM_CYFD_PaymentTriggerHandler.rollUpAmountToContract(Trigger.old, null);
        }
    }        
}