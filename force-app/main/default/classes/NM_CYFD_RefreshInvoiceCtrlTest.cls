@isTest
public with sharing class NM_CYFD_RefreshInvoiceCtrlTest {
    @TestSetup
    static void makeData(){
        Id caRecordTypeId = Schema.SObjectType.Contract_Activity__c.getRecordTypeInfosByName().get('Billable Activity').getRecordTypeId();
        
        List<Account> accountList1 = NM_CYFD_TestDataFactory.createAccounts(1,true);

        Contract__c con = new Contract__c(Account__c = accountList1[0].Id);       
        insert con;

        Invoice__c inv = new Invoice__c(Contract__c = con.Id, Status__c = 'Rejected', Invoice_Date__c = date.newinstance(2020, 11, 11));
        insert inv;

        Invoice__c inv1 = new Invoice__c(Contract__c = con.Id, Status__c = 'New', Invoice_Date__c = date.newinstance(2020, 10, 11));
        insert inv1;

        Contract_Activity__c ca = new Contract_Activity__c(Date__c = date.newinstance(2020, 10, 20), RecordTypeId = caRecordTypeId, Contract__c = con.Id);
        insert ca;

        Contract_Activity__c ca1 = new Contract_Activity__c(Date__c = date.newinstance(2020, 9, 20), Invoice__c=inv.Id, RecordTypeId = caRecordTypeId, Contract__c = con.Id);
        insert ca1;

        insert new Activity_Role__c(Contract_Activity__c = ca.Id);
        
        
        
         List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
         List<Contact> contactList = NM_CYFD_TestDataFactory.createContacts(2,accountList[0].Id,true);
         List<Contract_Role__c> staffContractRoleList = NM_CYFD_TestDataFactory.createContractRole(1,Date.newInstance(1998, 11, 11),accountList[0].Id,contactList[0].Id,'Provider', false);
        for(Contract_Role__c cr : staffContractRoleList){
            cr.Contract_Role__c = 'Staff';
            cr.Contact__c = contactList[0].id;
        }
        insert staffContractRoleList;
         List<User> jjacUserList = NM_CYFD_TestDataFactory.createPortalUserList(contactList, 'JJAC Community User', true);
    }
    @isTest
    public static void testrefreshInvoiceWithActivity(){
        Invoice__c invoice = [SELECT Id FROM Invoice__c LIMIT 1];
       
        String returnValue = NM_CYFD_RefreshInvoiceCtrl.refreshInvoiceWithActivity(invoice.Id);
        Contract_Activity__c CA = [SELECT Id,Invoice__c FROM Contract_Activity__c LIMIT 1];
        System.AssertEquals(invoice.Id,CA.Invoice__c);
       // System.AssertEquals('success',returnValue);
        
        String returnValue_error = NM_CYFD_RefreshInvoiceCtrl.refreshInvoiceWithActivity(invoice.Id);
        System.AssertEquals('No Activities to update',returnValue_error);
    
    }
    @isTest
    public static void testrefreshInvoiceWithActivityNewStatus(){
    
        Invoice__c invoice = [SELECT Id, Status__c FROM Invoice__c WHERE Status__c = 'New' LIMIT 1];
        Contract_Activity__c CA = [SELECT Id,Invoice__c FROM Contract_Activity__c LIMIT 1];
        //invoice.Status__c = 'New';
        //update invoice;      
        String returnValue = NM_CYFD_RefreshInvoiceCtrl.refreshInvoiceWithActivity(invoice.Id);
       // System.AssertEquals('Invoice must be in rejected status',returnValue);        
    }
    @isTest
    public static void testrefreshInvoiceException(){
        try{
           String returnValue = NM_CYFD_RefreshInvoiceCtrl.refreshInvoiceWithActivity(null); 
        }catch(Exception e){
            system.debug('error' + e);
        }
        
        //        System.AssertEquals('Invoice must be in rejected status',returnValue);
        
    }
    @isTest
    public static void testdeleteContractActivity(){
        Contract_Activity__c CA = [SELECT Id FROM Contract_Activity__c LIMIT 1];
        NM_CYFD_RefreshInvoiceCtrl.deleteContractActivity(CA.Id);
    }
    @isTest
    public static void testSubmitInvoice(){
        Invoice__c invoice = [SELECT Id, Status__c FROM Invoice__c LIMIT 1];
        System.debug('invoice test classs ' + invoice);
        User u = [SELECT Id FROM User WHERE Profile.Name = 'JJAC Community User' AND Username LIKE '%testPortalNMYFDPUser%' LIMIT 1];
        
        //System.runAs(u){
            NM_CYFD_RefreshInvoiceCtrl.submitInvoice(invoice.Id, UserInfo.getUserId());
            Map<String, Object> response = NM_CYFD_RefreshInvoiceCtrl.submitInvoice(invoice.Id, UserInfo.getUserId());
            System.AssertEquals(false,response.get('success'));
            
       // }
    }
}