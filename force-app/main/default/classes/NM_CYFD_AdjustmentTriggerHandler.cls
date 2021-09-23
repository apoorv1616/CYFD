public with sharing class NM_CYFD_AdjustmentTriggerHandler {
	public static Boolean stopThrowingError = false;
    public static String errorMessage = 'You cannot adjust the amount of an invoice after it has been approved or paid.';
    
    public static void beforeInsert(List<Adjustment__c> newList) {
        throwErrorIfInvoicePaid(newList, null); //throw error on adjustment record
    }
    
    public static void beforeUpdate(List<Adjustment__c> newList, Map<Id, Adjustment__c> oldMap) {
        throwErrorIfInvoicePaid(newList, oldMap); //throw error on adjustment record
    }
    
    /*
     * Author : Apoorv Anand
     * Issue  : I-54462
     * Desc   : throw error on adjustment record on insert or update if invoice is already paid.
    */
    public static void throwErrorIfInvoicePaid(List<Adjustment__c> newList, Map<Id, Adjustment__c> oldMap) {
        Set<Id> invoiceIdSet = new Set<Id>();
       
        for(Adjustment__c adjustmentRecord : newList) {
            
            if(adjustmentRecord.Invoice__c != null
              && !stopThrowingError) {
                  
                  //insert and update conditions
                if(oldMap == null || (oldMap.get(adjustmentRecord.Id).Status__c != adjustmentRecord.Status__c 
                                     && adjustmentRecord.Status__c == 'Approved'))
                
                   invoiceIdSet.add(adjustmentRecord.Invoice__c);
            }
        } 
        
        if(!invoiceIdSet.isEmpty()) {
            Map<Id, Invoice__c> mapOfInvoiceIdToInvoice = new Map<Id, Invoice__c>([SELECT Id, Status__c
                                                                                  FROM Invoice__c
                                                                                  WHERE Id IN :invoiceIdSet]);
            
            for(Adjustment__c adjustmentRecord : newList) {
                if(mapOfInvoiceIdToInvoice.containsKey(adjustmentRecord.Invoice__c)) {
                    Invoice__c invoiceRecord = mapOfInvoiceIdToInvoice.get(adjustmentRecord.Invoice__c);
                    if(invoiceRecord.Status__c == 'Approved' || invoiceRecord.Status__c == 'Paid') {
                        adjustmentRecord.addError(errorMessage);
                    }
                }
            }
        } 
    }
}