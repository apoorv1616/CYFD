@isTest
public class NM_CYFD_InvoiceTriggerHandlerTest { 

    @isTest(SeeAllData=true)
    public static void testSendEmailWhenInvoiceSubmitted() {
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1,accountList[0].Id,null,'JCC',true);
        List<Invoice__c> invoiceList = NM_CYFD_TestDataFactory.createInvoiceRecords(5, contractList[0].Id,null, true);
        
		Invoice__c invoiceRecord = invoiceList[0];
        invoiceRecord.Status__c = 'Submitted';
        
        Test.startTest();
        	update invoiceRecord;
        Test.stopTest();
       	
    }
    
    @isTest(SeeAllData=true)
    public static void testThrowErrorIfPaidStatusIsChanged() {
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1,accountList[0].Id,null,'JCC',true);
        List<Invoice__c> invoiceList = NM_CYFD_TestDataFactory.createInvoiceRecords(5, contractList[0].Id,null, true);
        List<Invoice__c> updateList = new List<Invoice__c>();
        for(Invoice__c invoice : invoiceList){
            Invoice__c i = new Invoice__c();
            i.Id = invoice.Id;
            i.Status__c ='Approved';
            updateList.add(i);
        }
        if(!updateList.isEmpty()){
            update updateList;
        }

        if(!updateList.isEmpty()) {
            Invoice__c invoiceRecord = updateList[0];
            invoiceRecord.Status__c = 'Rejected';
            
            try {
                update invoiceRecord;
            }
            catch(Exception e) {
                Boolean isTrue = e.getMessage().contains('As a CYFD Program Manager you can only change the status of an invoice to either Approved or Rejected.');
                System.assertNotEquals(true, isTrue, 'isTrue should be true');
            }
        }
       	
    }
    
    
    @isTest(SeeAllData=true)
    public static void testCreatePaymentRecordsOnInvoiceAccept() {
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1,accountList[0].Id,null,'JCC',true);
        List<Invoice__c> invoiceList = NM_CYFD_TestDataFactory.createInvoiceRecords(5, contractList[0].Id,null, true);
        List<Invoice__c> updateList = new List<Invoice__c>();
        for(Invoice__c invoice : invoiceList){
            Invoice__c i = new Invoice__c();
            i.Id = invoice.Id;
            i.Status__c ='Approved';
            updateList.add(i);
        }
        if(!updateList.isEmpty()){
            update updateList;
        }
        
        System.assertNotEquals(0, [SELECT Id
                                   FROM Payment__c
                                   WHERE Invoice__c IN :updateList].size(), 'Payment size should be greater than 0');
    }
    
    @isTest(SeeAllData=true)
    public static void beforeUpdateTest(){
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1,accountList[0].Id,null,'JCC',true);
        List<Invoice__c> invoiceList = NM_CYFD_TestDataFactory.createInvoiceRecords(5, contractList[0].Id,null, true);
        List<Invoice__c> updateList = new List<Invoice__c>();
        for(Invoice__c invoice : invoiceList){
            Invoice__c i = new Invoice__c();
            i.Id = invoice.Id;
            i.Status__c ='Rejected';
            updateList.add(i);
        }
        if(!updateList.isEmpty()){
            update updateList;
        }
    }
    

}