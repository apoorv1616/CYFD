public without sharing class NM_CYFD_PaymentTriggerHandler {
    
    public static Boolean throwError = false;
    public static Boolean stopRollUpAmountToContract = false;
    
    /*
     * Author : Apoorv Anand
     * Desc   : Throw error when Voucher Number or Voucher Date is blank.
     		  : (Before Insert / Before Update).
     * Issue  : I-55358 
    */
    public static void throwRequiredErrorOnPayment(List<Payment__c> newList, Map<Id, Payment__c> oldMap) {
        for(Payment__c paymentRecord : newList) {
            if(!throwError) {
                if(oldMap == null 
                   || (oldMap.get(paymentRecord.Id).Voucher_Number__c != paymentRecord.Voucher_Number__c
                      ||
                       oldMap.get(paymentRecord.Id).Voucher_Date__c != paymentRecord.Voucher_Date__c)) {
                           
                           if(paymentRecord.Voucher_Number__c == null) {
                                paymentRecord.Voucher_Number__c.addError('Please enter the Voucher Number.');
                            }
                            
                            if(paymentRecord.Voucher_Date__c == null) {
                                paymentRecord.Voucher_Date__c.addError('Please enter the Voucher Date.');
                            }
                 }
            }
        }
    }
    
    public static void paymentValidationsOnInsert(List<Payment__c> newList){
   
        set<ID> invoiceIdSet= new set<ID>();
        List<Invoice__c> invoicesToUpdate = new List<Invoice__c>();
        List<Payment__c> paymentList = new List<Payment__c>();
        Map<Id, String> invoiceIdToStatusMap = new Map<Id, String>();
        Map<Id, Payment__c> invoiceIdToPaymentMap = new Map<Id, Payment__c>();
        Set<Id> invoiceIdsWithExistingPayments = new Set<Id>();
        
        for(Payment__c payment: newList){           
           invoiceIdSet.add(payment.Invoice__c);
        }
        
        for(Invoice__c inv : [Select Id, Status__c, (SELECT Id FROM Payments__r) FROM Invoice__c WHERE ID IN: invoiceIdSet]){
            if(!inv.Payments__r.isEmpty()){
                invoiceIdsWithExistingPayments.add(inv.Id);
            }
            if(!invoiceIdToStatusMap.containsKey(inv.Id) && inv.Status__c != null){
                invoiceIdToStatusMap.put(inv.Id, inv.status__c);
            }
        }
         
        for(Payment__c payment : newList){
        
            //logic to prevent user from insert more than payment records for an invoice
            if(invoiceIdsWithExistingPayments.contains(payment.Invoice__c)){               
                payment.addError('One Invoice can have one payment Record');
            }
            
            //logic to prevent user from inserting a payment record for an invoice not in approved status
            else if(!throwError && invoiceIdToStatusMap.containsKey(payment.Invoice__c) && invoiceIdToStatusMap.get(payment.Invoice__c) != 'Approved'){
               payment.addError('Invoice is not in Approved status yet');
            }
            
            //logic to update Invoice status to Paid on successful insertion of Payment.
           /* else{
                Invoice__c inv = new Invoice__c(Id = payment.Invoice__c);
                inv.Status__c = 'Paid';
                invoicesToUpdate.add(inv);
            }*/
        }
        
        if(!invoicesToUpdate.isEmpty()){
            update invoicesToUpdate;
        }
    }
    
    public static void updateInvoiceStatusToPaid(List<Payment__c> newList, Map<Id,Payment__c> oldMap ){
        List<Invoice__c> invoicesToUpdate = new List<Invoice__c>();
        for(Payment__c payment : newList){
            if(payment.Reference_Number__c != null && payment.Reference_Date__c != null){
                Invoice__c inv = new Invoice__c(Id = payment.Invoice__c);
                inv.Status__c = 'Paid';
                invoicesToUpdate.add(inv);
            }
        }
        
        if(!invoicesToUpdate.isEmpty()) {
            try {
                NM_CYFD_InvoiceTriggerHandler.bypassError = true;
                update invoicesToUpdate;
            }
            catch(Exception e) {
                String message = e.getMessage();
                String validationMessage = NM_CYFD_ConfigurationItemTriggerHandler.throwValidationErrors(message);
                String err = validationMessage != null ? validationMessage : message;
                newList[0].addError(err);
            }
        }
            
    }
    
    public static void rollUpAmountToContract(List<Payment__c> newList, Map<Id,Payment__c> oldMap){
        
        Set<Id> contractIds = new Set<Id>();
        Map<Id, Contract__c> contractMap = new Map<ID, Contract__c>();
        Map<Id, Decimal> mapOfContractIdToExpenditure = new Map<Id, Decimal>();
        Map<Id, Decimal> mapOfContractIdToMatchAmountExpenditure = new Map<Id, Decimal>();
        
        for(Payment__c payment : [SELECT Id, Invoice__r.Contract__c, Invoice__r.Status__c 
                                  FROM Payment__c 
                                  WHERE ID IN: newList])
            contractIds.add(payment.Invoice__r.Contract__c);
        
        List<Payment__c> payments = [SELECT Id,Invoice__r.Contract__c,Match_Amount__c,Payment_Amount__c, Invoice__r.Status__c  
                                     FROM Payment__c 
                                     WHERE Invoice__r.Contract__c IN: contractIds];
        
        for (AggregateResult agr : 
                [SELECT sum(Match_Amount__c) sumOfMatchAmount, sum(Payment_Amount__c) sumOfPaymentAmount, 
                 Invoice__r.Contract__c contractId 
                 FROM Payment__c 
                 GROUP BY Invoice__r.Contract__c, Invoice__r.Status__c 
                 HAVING Invoice__r.Status__c IN ('Approved', 'Paid')
                 AND Invoice__r.Contract__c IN :contractIds]) {
                     
                Id contractId = (Id)agr.get('contractId');
                Decimal matchExpenditure = (Decimal)agr.get('sumOfMatchAmount');
                Decimal expenditureAmount = (Decimal)agr.get('sumOfPaymentAmount');
                     
                if ( !mapOfContractIdToExpenditure.containsKey( contractId )) {
                     
                    mapOfContractIdToExpenditure.put( contractId, 0 );
                }  
                Decimal expenditure = mapOfContractIdToExpenditure.get( contractId );
                mapOfContractIdToExpenditure.put( contractId, expenditure + expenditureAmount );  
                     
                if ( !mapOfContractIdToMatchAmountExpenditure.containsKey( contractId )) {
                     
                    mapOfContractIdToMatchAmountExpenditure.put( contractId, 0 );
                }  
                Decimal matchExpenditureFromMap = mapOfContractIdToMatchAmountExpenditure.get( contractId );
                mapOfContractIdToMatchAmountExpenditure.put( contractId, matchExpenditure + matchExpenditureFromMap );  
         }
        
        for(Payment__c payment : payments) {

            Contract__c contract =  new Contract__c();
            contract.Id = payment.Invoice__r.Contract__c;
            
            contract.Match_Expenditure_Amount__c = mapOfContractIdToMatchAmountExpenditure.containsKey(payment.Invoice__r.Contract__c) 
                ? mapOfContractIdToMatchAmountExpenditure.get(payment.Invoice__r.Contract__c) : 0;
            
            contract.Expenditure_Amount__c = mapOfContractIdToExpenditure.containsKey(payment.Invoice__r.Contract__c) 
                ? mapOfContractIdToExpenditure.get(payment.Invoice__r.Contract__c) : 0;
            
            contractMap.put(contract.Id, contract);
            
        }
        
        if (!contractMap.isEmpty()) {
            stopRollUpAmountToContract = true;
            update contractMap.values();
        }
        
    }
}