@isTest
public class NM_CYFD_ConfigLineItemTriggerHandlerTest {
    @isTest
    public static void createContractActivitiesTest(){
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contract_Configuration__c> configList = NM_CYFD_TestDataFactory.createContractConfigurationRecords(1,True);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1,accountList[0].Id,configList[0].Id,'JCC',True);
        List<CYFD_Activity__c> CYFDActivityList = NM_CYFD_TestDataFactory.createDeliverableCYFDActivityRec(1,True);
        List<Contract_Configuration_Line_Item__c> lineItemList = NM_CYFD_TestDataFactory.createContractConfigurationLIRecords(1,configList[0].Id,CYFDActivityList[0].Id,True);
        
        List<Contract_Activity__c> activityList = [SELECT Id,Contract_Configuration__c,Contract__c FROM Contract_Activity__c WHERE Contract_Configuration__c =:configList[0].Id AND CYFD_Activity__c =: CYFDActivityList[0].Id];
        System.assert(activityList.isEmpty() == false);
        System.assertEquals(contractList[0].Id, activityList[0].Contract__c);
    }
}