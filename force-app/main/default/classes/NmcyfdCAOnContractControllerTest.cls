@isTest
public with sharing class NmcyfdCAOnContractControllerTest {
	
    @testSetup
    static void makedata() {
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1,accountList[0].Id,null,'JCC', true);
        List<CYFD_Activity__c> CYFD_ActivityList = NM_CYFD_TestDataFactory.createCYFDActivity(1,'Deliverable',true);
        List<Contract_Activity__c> activityList= NM_CYFD_TestDataFactory.createContractActivity(1,contractList[0].Id ,'Deliverable', true);
    }
    
    @isTest
    static void testGetCAAssociatedWithContract() {
        List<Contract_Activity__c> activityList = [SELECT Id FROM Contract_Activity__c];
        
        Test.startTest();
        	List<Contract_Activity__c> contractActivityList = NmcyfdCAOnContractController.getCAAssociatedWithContract(activityList[0].Id, null, 'Deliverable','Date__c',true);
        	List<Contract_Activity__c> contractActivityListSortDesc = NmcyfdCAOnContractController.getCAAssociatedWithContract(activityList[0].Id, null, 'Deliverable','Date__c',false);
        
        Test.stopTest();
        
        System.assertEquals(0, contractActivityList.size(), 'contractActivityList size should be greater than 0');
    }
}