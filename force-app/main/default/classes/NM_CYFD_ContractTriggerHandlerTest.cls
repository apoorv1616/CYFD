@isTest
public with sharing class NM_CYFD_ContractTriggerHandlerTest {
    @isTest
    static void makeData(){
        Id caRecordTypeId = Schema.SObjectType.Contract_Activity__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId();
        Id cyfdActivityRecordTypeId = Schema.SObjectType.CYFD_Activity__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId();

        Contract_Configuration__c contractConfig = new Contract_Configuration__c(Name__c = 'Test Config');
        insert contractConfig;

        CYFD_Activity__c cyfdActivity = new CYFD_Activity__c(Name__c = 'Test Activity', Activity_Rate__c = 123, RecordTypeId= cyfdActivityRecordTypeId);
        insert cyfdActivity;

        Contract_Configuration_Line_Item__c conConfigLineItem = new Contract_Configuration_Line_Item__c(Contract_Configuration__c = contractConfig.Id, Activity_Allocated_Amount__c = 213,
                             CYFD_Activity__c = cyfdActivity.Id);

        insert conConfigLineItem;
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        Contract__c con = new Contract__c(Contract_Configuration__c = contractConfig.Id, Account__c = accountList[0].Id);       
        insert con;

        Invoice__c inv = new Invoice__c(Contract__c = con.Id, Status__c = 'Rejected', Invoice_Date__c = date.newinstance(2020, 11, 11), Amount__c = 123);
        insert inv;

        Invoice__c inv1 = new Invoice__c(Contract__c = con.Id, Status__c = 'approved', Invoice_Date__c = date.newinstance(2020, 10, 11), Amount__c = 123);
        insert inv1;

        Payment__c payment = new Payment__c(Invoice__c = inv1.Id, Voucher_Number__c = '123',Reference_Number__c = '213');
        insert payment;

        payment.Voucher_Number__c = '1231';
        update payment;       
        
        List<Contract_Activity__c> conActivityList = [SELECT Id FROM Contract_Activity__c];
       // System.Assertequals(1,conActivityList.size());
    }

}