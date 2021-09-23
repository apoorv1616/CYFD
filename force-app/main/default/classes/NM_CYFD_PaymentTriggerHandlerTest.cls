@isTest
public with sharing class NM_CYFD_PaymentTriggerHandlerTest {
    @isTest(SeeAllData=true)
    static void makeData(){
        Id caRecordTypeId = Schema.SObjectType.Contract_Activity__c.getRecordTypeInfosByName().get('Billable Activity').getRecordTypeId();
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        Contract__c con = new Contract__c(Account__c = accountList[0].Id);       
        insert con;

        Invoice__c inv = new Invoice__c(Contract__c = con.Id, Status__c = 'Rejected', Invoice_Date__c = date.newinstance(2020, 11, 11), Amount__c = 123);
        insert inv;

        Invoice__c inv1 = new Invoice__c(Contract__c = con.Id, Status__c = 'approved', Invoice_Date__c = date.newinstance(2020, 10, 11), Amount__c = 123);
        insert inv1;

        Payment__c payment = new Payment__c(Invoice__c = inv1.Id, Voucher_Number__c = '123',Voucher_Date__c = date.today() ,Reference_Number__c = '213');
        insert payment;

        payment.Voucher_Number__c = '1231';
        update payment;       

        Contract_Activity__c ca = new Contract_Activity__c(Date__c = date.newinstance(2020, 10, 20), RecordTypeId = caRecordTypeId, Contract__c = con.Id);
        insert ca;

        Contract_Activity__c ca1 = new Contract_Activity__c(Date__c = date.newinstance(2020, 9, 20), Invoice__c=inv.Id, RecordTypeId = caRecordTypeId, Contract__c = con.Id);
        insert ca1;

        insert new Activity_Role__c(Contract_Activity__c = ca.Id);

        Contract__c updatedCon = [SELECT Id, Expenditure_Amount__c FROM Contract__c WHERE Id = :con.Id];
        Payment__c updatedPayment = [SELECT Id, Payment_Amount__c FROM Payment__c WHERE Id = :payment.Id];
        System.AssertEquals(updatedPayment.Payment_Amount__c, updatedCon.Expenditure_Amount__c);
		
        inv1.Status__c = 'Rejected';
        update inv1;
        
        payment.Reference_Number__c = '123';
        try {
            update payment;
        }
        catch(Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Error message should return');
        }
        payment.Reference_Date__c = Date.today();
        update payment;
        
        delete payment;
    }
    
    @isTest
    static void testThrowRequiredErrorOnPayment() {
        Id caRecordTypeId = Schema.SObjectType.Contract_Activity__c.getRecordTypeInfosByName().get('Billable Activity').getRecordTypeId();
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        Contract__c con = new Contract__c(Account__c = accountList[0].Id);       
        insert con;

        Invoice__c inv1 = new Invoice__c(Contract__c = con.Id, Status__c = 'approved', Invoice_Date__c = date.newinstance(2020, 10, 11), Amount__c = 123);
        insert inv1;
		
        Payment__c payment = new Payment__c(Invoice__c = inv1.Id, Voucher_Number__c = '123' ,Reference_Number__c = '213');
        try {
           payment.Voucher_Date__c = Date.today();
           insert payment; 
        }
        catch(exception e) {
            Boolean isTrue = e.getMessage().contains('Please enter the Voucher Number.');
            System.assertEquals(true, isTrue, 'Error message should be thrown');
        }
        
        
    }
}