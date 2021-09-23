@isTest
public class NM_CYFD_ContractActvityTrigHandlerTest {
    @testSetup
    public static void testSetUp(){
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1,accountList[0].Id,null,'JCC', true);
        List<CYFD_Activity__c> CYFD_ActivityList = NM_CYFD_TestDataFactory.createCYFDActivity(1,'Deliverable',true);
        
        Contract_Configuration__c contractConfig = new Contract_Configuration__c(Name__c = 'Test Config');
        insert contractConfig;

        Contract_Configuration_Line_Item__c conConfigLineItem = new Contract_Configuration_Line_Item__c(Contract_Configuration__c = contractConfig.Id, Activity_Allocated_Amount__c = 213,
                             CYFD_Activity__c = CYFD_ActivityList[0].Id);
		conConfigLineItem.Sub_Contractor__c = 'test';
        insert conConfigLineItem;
        
        List<Contract_Activity__c> activityList= NM_CYFD_TestDataFactory.createContractActivity(1,contractList[0].Id ,'Deliverable', false);
        List<Invoice__c> invoiceList = NM_CYFD_TestDataFactory.createInvoiceRecords(1,contractList[0].Id, Date.newInstance(Date.today().year(), 10, 11), true);
    }
    @isTest
    public static void test(){
        List<Contract__c> contractList = [SELECT Id FROM Contract__c LIMIT 1];
        List<Invoice__c> invoiceList = [SELECT Id FROM Invoice__c LIMIT 1];
        List<Contract_Configuration_Line_Item__c> configList = [SELECT Id FROM Contract_Configuration_Line_Item__c LIMIT 1];
        List<CYFD_Activity__c> CYFD_ActivityList =[SELECT Id FROM CYFD_Activity__c LIMIT 1];
        CYFD_ActivityList[0].name__c = 'test';
        CYFD_ActivityList[0].activity_type__c = 'Individual';
        update CYFD_ActivityList;
        
        List<Contract_Activity__c> activityList= NM_CYFD_TestDataFactory.createContractActivity(1,contractList[0].Id ,'Deliverable', false);
        
        List<Contract_Activity__c> billableActivityList = NM_CYFD_TestDataFactory.createContractActivity(1,contractList[0].Id,'Billable Activity',false);
        billableActivityList[0].Program__c = 'test';
        billableActivityList[0].Invoice_Amount__c = 100.0;
        billableActivityList[0].Contract_Configuration_Line_Item__c  = configList[0].Id;
        
        if(!billableActivityList.isEmpty()){
            for(Integer i=0;i<billableActivityList.size();i++){
                    billableActivityList[i].CYFD_Activity__c = CYFD_ActivityList[0].Id;
                    billableActivityList[i].Date__c =  Date.newInstance(Date.today().year(), 10, 24);
                    billableActivityList[i].Invoice__c = invoiceList[0].Id;
                    //activityList[i].Rate__c = 10;
                    billableActivityList[i].Unit__c = 5;
                }
            
            insert billableActivityList;
            }            
        Test.startTest();
        if(!activityList.isEmpty()){
            for(Integer i=0;i<activityList.size();i++){
                    activityList[i].CYFD_Activity__c = CYFD_ActivityList[0].Id;
                    activityList[i].Date__c =  Date.newInstance(Date.today().year(), 10, 24);
                    activityList[i].Invoice__c = invoiceList[0].Id;
                    //activityList[i].Rate__c = 10;
                    activityList[i].Unit__c = 5;
                }
            insert activityList;
            }
        List<Contract_Activity__c> QueryActivityList = [SELECT Id,Unit__c,Invoice__c,Date__c,Rate__c,CYFD_Activity__c FROM Contract_Activity__c];
        if(!QueryActivityList.isEmpty()){
            for(Integer i=0;i<activityList.size();i++){
                QueryActivityList[i].Date__c = Date.newInstance(Date.today().year(), 10, 4);
            }
            update QueryActivityList;
        }
        
        delete billableActivityList;
        undelete billableActivityList;
        Test.stopTest();
        List<Contract_Activity__c> activityListInserted = [SELECT ID FROM Contract_Activity__c];
        System.assertEquals(false,activityListInserted.isEmpty());
    }
}