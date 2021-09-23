@isTest
public class NM_CYFD_InvoiceBatchTest {
    @isTest
    public static void testBatchInvoice(){
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1,accountList[0].Id,null,'JCC',true);
        List<Contract_Activity__c> activityList = NM_CYFD_TestDataFactory.createBillableContractActivityRec(2,contractList[0].Id,false);
        if(activityList.size()>0){
            for(Integer i=0;i<activityList.size();i++){
                if(i== 0){
                    activityList[i].Date__c = Date.newInstance(Date.Today().Year() - 1,12,date.daysInMonth(Date.Today().Year() - 1, 12));
                    activityList[i].RecordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Activity__c','Billable Activity');
                }
                else{
                    activityList[i].Date__c = Date.newInstance(Date.Today().Year() ,Date.Today().month()-1,24);
                    activityList[i].RecordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Activity__c','Billable Activity');
                }
                
            }
        }
        if(activityList.size()>0){
            insert activityList;
        }
        Test.startTest();
        NM_CYFD_InvoiceBatch batchObject = new NM_CYFD_InvoiceBatch();
        Database.executeBatch(batchObject);
        //List<Invoice__c> InvoiceList = [SELECT Id,Contract__c FROM Invoice__c];
        //System.assertEquals(contractList[0].Id, InvoiceList[0].Contract__c);
        
        List<Contract_Activity__c> actList = NM_CYFD_TestDataFactory.createBillableContractActivityRec(2,contractList[0].Id,false);
        if(actList.size()>0){
            for(Integer i=0;i<actList.size();i++){
                if(i== 0){
                    actList[i].Date__c = Date.newInstance(Date.Today().Year() - 1,12,date.daysInMonth(Date.Today().Year() - 1, 12));
                    actList[i].RecordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Activity__c','Billable Activity');
                }
                else{
                    actList[i].Date__c = Date.newInstance(Date.Today().Year() ,Date.Today().month()-1,24);
                    actList[i].RecordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Activity__c','Billable Activity');
                }
            }
        }
        if(actList.size()>0){
            insert actList;
        }
         
        NM_CYFD_InvoiceBatch Obj= new NM_CYFD_InvoiceBatch();
        Database.executeBatch(Obj);
        
        NM_CYFD_InvoiceBatch Obj1 =  new NM_CYFD_InvoiceBatch();
        String cron = '0 0 23 * * ?';
        system.schedule('Scheduling Batch for Invoice',cron ,Obj1 );
        Test.stopTest();
        List<Invoice__c> InvList = [SELECT Id,Contract__c FROM Invoice__c];
  //      System.assertEquals(2, InvList.size());
    }
    @isTest
    public static void testBatchInvoiceWithInvoices(){
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1,accountList[0].Id,null,'JCC',true);
        List<Contract_Activity__c> activityList = NM_CYFD_TestDataFactory.createBillableContractActivityRec(2,contractList[0].Id,false);
        if(activityList.size()>0){
            for(Integer i=0;i<activityList.size();i++){
                if(i== 0){
                    activityList[i].Date__c = Date.newInstance(Date.Today().Year() - 1,12,date.daysInMonth(Date.Today().Year() - 1, 12));
                    activityList[i].RecordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Activity__c','Billable Activity');
                }
                else{
                    activityList[i].Date__c = Date.newInstance(Date.Today().Year() ,Date.Today().month()-1,24);
                    activityList[i].RecordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Activity__c','Billable Activity');
                }
                
            }
        }
        List<Invoice__c> invoiceList = NM_CYFD_TestDataFactory.createInvoiceRecords(1,contractList[0].Id,Date.newInstance(Date.Today().Year() ,Date.Today().month()-1,11), false);
        if(!invoiceList.isEmpty()){
            insert invoiceList;
        }
        if(activityList.size()>0){
            insert activityList;
        }
        Test.startTest();
        NM_CYFD_InvoiceBatch batchObject = new NM_CYFD_InvoiceBatch();
        Database.executeBatch(batchObject);
        Test.stopTest();
    }
}