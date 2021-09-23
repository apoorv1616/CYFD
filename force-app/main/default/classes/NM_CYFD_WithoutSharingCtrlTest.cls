@isTest
public class NM_CYFD_WithoutSharingCtrlTest {
	
    @testSetup
    static void makeData() {
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contract_Configuration__c> configList = NM_CYFD_TestDataFactory.createContractConfigurationRecords(1,True);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1,accountList[0].Id,configList[0].Id,'JCC',True);
        List<CYFD_Activity__c> CYFDActivityList = NM_CYFD_TestDataFactory.createDeliverableCYFDActivityRec(1,True);
        List<Contract_Configuration_Line_Item__c> lineItemList = NM_CYFD_TestDataFactory.createContractConfigurationLIRecords(1,configList[0].Id,CYFDActivityList[0].Id,True);
        
    }
    
    @isTest
    static void testGetConfigurationLineItemRecords() {
        
        List<Contract_Configuration__c> configList = [SELECT Id FROM Contract_Configuration__c];
        List<CYFD_Activity__c> CYFDActivityList = [SELECT Id,RecordTypeId FROM CYFD_Activity__c];
        
        Test.startTest();
        	List<Contract_Configuration_Line_Item__c> lineList = NM_CYFD_WithoutSharingCtrl.getConfigurationLineItemRecords(configList[0].Id, CYFDActivityList[0].RecordTypeId);
        Test.stopTest();
        
        System.assertNotEquals(0, lineList.size(), 'size of lineList should not be 0');
    }
    
    @isTest
    static void testGetConfigurationLineItemRecordsById() {
        List<Contract_Configuration_Line_Item__c> configList = [SELECT Id FROM Contract_Configuration_Line_Item__c];
        
        Test.startTest();
        	List<Contract_Configuration_Line_Item__c> lineList = NM_CYFD_WithoutSharingCtrl.getConfigurationLineItemRecordsById(configList[0].Id);
        Test.stopTest();
        
        System.assertNotEquals(0, lineList.size(), 'size of lineList should not be 0');
    }
    
}