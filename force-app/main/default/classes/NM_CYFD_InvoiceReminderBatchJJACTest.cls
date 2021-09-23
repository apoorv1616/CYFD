@isTest
public class NM_CYFD_InvoiceReminderBatchJJACTest {
    @TestSetup
    static void makeData(){
        Id caRecordTypeId = Schema.SObjectType.Contract_Activity__c.getRecordTypeInfosByName().get('Billable Activity').getRecordTypeId();
        Integer month = System.today().month();
        Integer year = System.today().year();
        List<Account> accountList1 = NM_CYFD_TestDataFactory.createAccounts(1,true);

        Contract__c con = new Contract__c(Account__c = accountList1[0].Id, Grant__c = 'JJAC');       
        insert con;

        Invoice__c inv = new Invoice__c(Contract__c = con.Id, Status__c = 'Rejected', Invoice_Date__c = date.newinstance(year, month, 15));
        insert inv;

        Invoice__c inv1 = new Invoice__c(Contract__c = con.Id, Status__c = 'New', Invoice_Date__c = date.newinstance(year, month, 15));
        insert inv1;

        Contract_Activity__c ca = new Contract_Activity__c(Date__c = date.newinstance(year, 10, 20), RecordTypeId = caRecordTypeId, Contract__c = con.Id);
        insert ca;

        Contract_Activity__c ca1 = new Contract_Activity__c(Date__c = date.newinstance(year, 9, 20), Invoice__c=inv.Id, RecordTypeId = caRecordTypeId, Contract__c = con.Id);
        insert ca1;

        insert new Activity_Role__c(Contract_Activity__c = ca.Id);
        
        
        
         List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
         List<Contact> contactList = NM_CYFD_TestDataFactory.createContacts(2,accountList1[0].Id,true);
         List<Contract_Role__c> staffContractRoleList = NM_CYFD_TestDataFactory.createContractRole(1,Date.newInstance(1998, 11, 11),accountList1[0].Id,contactList[0].Id,'Provider', false);
        for(Contract_Role__c cr : staffContractRoleList){
            cr.Contract_Role__c = 'Provider';
            cr.Contact__c = contactList[0].id;
        }
        insert staffContractRoleList;
         List<User> jjacUserList = NM_CYFD_TestDataFactory.createPortalUserList(contactList, 'JJAC Community User', true);
    }
    
    @isTest
    public static void testInvoiceReminderBatch(){
        Test.startTest();
        NM_CYFD_InvoiceReminderBatchJJAC batchObject = new NM_CYFD_InvoiceReminderBatchJJAC(); 
        Database.executeBatch(batchObject);   
        NM_CYFD_InvoiceReminderBatchJJAC Obj1 =  new NM_CYFD_InvoiceReminderBatchJJAC();
        String cron = '0 0 23 * * ?';
        system.schedule('Scheduling Batch for Invoice',cron ,Obj1 );   
        Test.stopTest();
    }
}