@isTest
public with sharing class NM_CYFD_AdjustmentTriggerHandlerTest {
	
    @testSetup
    static void makeData() {
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1,accountList[0].Id,null,'JCC',true);
        
        Invoice__c invoiceRecord = new Invoice__c();
        invoiceRecord.Contract__c = contractList[0]?.Id;
        invoiceRecord.Status__c = 'Approved';
        insert invoiceRecord;
    }
    
    static Adjustment__c createAdjustmentRecord(Invoice__c invoiceRecord,String actionOnInvoice,  Boolean isInsert) {
        
        Adjustment__c adjustmentRecord = new Adjustment__c();
        adjustmentRecord.Invoice__c = invoiceRecord.Id;
        adjustmentRecord.Action_on_Invoice__c = actionOnInvoice;
        adjustmentRecord.Adjustment_Amount__c = 100;
        adjustmentRecord.Reason_for_Adjustment__c = 'test';
        
        if(isInsert) {
            insert adjustmentRecord;
        }
        return adjustmentRecord;
    }
    
    @isTest
    static void testThrowErrorIfInvoicePaidOnInsert() {
        Invoice__c invoiceRecord = [SELECT Id, Status__c
                                    FROM Invoice__c 
                                    WHERE Status__c = 'Approved'
                                    LIMIT 1];
        
        Adjustment__c adjustmentRecord = createAdjustmentRecord( invoiceRecord, 'Add', false);
        
        Test.startTest();
        try {
            insert adjustmentRecord;
        }
        catch(Exception e) {
            Boolean checkError = e.getMessage().contains(NM_CYFD_AdjustmentTriggerHandler.errorMessage);
            System.assertEquals(true, checkError,'Error message should be thrown');
        }

        Test.stopTest();
           
    }
        
}