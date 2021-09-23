@isTest
public class NmcyfdCloneCCControllerTest {
	
    @testSetup
    static void makeData() {
        
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contract_Configuration__c> configList = NM_CYFD_TestDataFactory.createContractConfigurationRecords(1,True);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1,accountList[0].Id,configList[0].Id,'JCC',True);
        List<CYFD_Activity__c> CYFDActivityList = NM_CYFD_TestDataFactory.createDeliverableCYFDActivityRec(1,True);
        List<Contract_Configuration_Line_Item__c> lineItemList = NM_CYFD_TestDataFactory.createContractConfigurationLIRecords(1,configList[0].Id,CYFDActivityList[0].Id,True);
        
    }
    
    @isTest
    static void testGetPreviousConfiguration() {
        List<Contract_Configuration__c> configurationRecord = [SELECT Id FROM Contract_Configuration__c];
        
        Test.startTest();
        	Contract_Configuration__c config = NmcyfdCloneCCController.getPreviousConfiguration(configurationRecord[0].Id);
        Test.stopTest();
        
        System.assertNotEquals(null, config, 'config should not be null');
    }
    
    @isTest
    static void testSaveContractConfiguration() {
         List<Contract_Configuration__c> configurationRecord = [SELECT Id, Name__c FROM Contract_Configuration__c];
         configurationRecord[0].Name__c = 'test1';
         configurationRecord[0].External_Id__c = '12345611';
         //update configurationRecord;
        
        List<Account> accountList1 = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contract_Configuration__c> configList1 = NM_CYFD_TestDataFactory.createContractConfigurationRecords(1,True);
        
        Test.startTest();
        	NmcyfdCloneCCController.saveContractConfiguration( configList1[0].Id, JSON.serialize(configurationRecord[0]));
        Test.stopTest();
    }
}