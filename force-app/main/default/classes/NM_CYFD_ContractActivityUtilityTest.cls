@isTest
public class NM_CYFD_ContractActivityUtilityTest {
     @testSetup
    public static void testSetup(){
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1, true);
        List<Contact> contactList = NM_CYFD_TestDataFactory.createContacts(1,accountList[0].Id,true);
        List<Contract_Configuration__c> configList = NM_CYFD_TestDataFactory.createContractConfigurationRecords(1, true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1, accountList[0].Id, configList[0].Id, 'Mentoring', true);
        List<Contract__c> contractListJCC = NM_CYFD_TestDataFactory.createContractRecords(1, accountList[0].Id, configList[0].Id, 'JCC', true);
        List<CYFD_Activity__c> cyfdActivityList = NM_CYFD_TestDataFactory.createCYFDActivity(1, 'Billable Activity', true);
        List<Contract_Configuration_Line_Item__c> lineItemList = NM_CYFD_TestDataFactory.createContractConfigurationLIRecords(1, configList[0].Id, cyfdActivityList[0].Id, false);
        lineItemList[0].Minimum_Unit__c  = '2';
        lineItemList[0].Sub_Contractor__c  = 'Test Contracter';
        lineItemList[0].Program__c  = 'Botvin Life Skills';
        insert lineItemList;
        List<Contract_Activity__c> activityList = NM_CYFD_TestDataFactory.createContractActivity(1, contractList[0].Id, 'Billable Activity', false);
        activityList[0].Date__c  = system.today() -1;
        activityList[0]. Unit__c = 3.0;
        activityList[0].Contract_Configuration_Line_Item__c = lineItemList[0].Id;
        activityList[0].Invoice_Amount__c = 200;
        insert activityList;
        
        List<Contract_Activity__c> activityList2 = NM_CYFD_TestDataFactory.createContractActivity(1, contractListJCC[0].Id, 'Billable Activity', false);
        activityList2[0].Date__c  = system.today() -1;
        activityList2[0]. Unit__c = 3.0;
        activityList2[0].Contract_Configuration_Line_Item__c = lineItemList[0].Id;
        activityList2[0].Invoice_Amount__c = 200;
        insert activityList2;
        
        
        List<Contract_Role__c> contractRoleList = NM_CYFD_TestDataFactory.createContractRole(1, Date.newInstance(1998, 10, 11),accountList[0].Id , contactList[0].Id, 'JCC Client', true);
        Activity_Role__c  role = new Activity_Role__c();
        role.RecordTypeId = NM_CYFD_Utility.getRecordTypeId('Activity_Role__c', 'Clients');
        role.Contract_Activity__c =activityList[0].Id;
        role.Contract_Role__c = contractRoleList[0].Id;
        insert role;
    }
    @isTest
    public static void updateMentoringActivityAmountsTest(){
        List<Contract__c> contractList = [SELECT Id FROM Contract__c LIMIT 1];
        Test.startTest();
        NM_CYFD_ContractActivityUtility obj = new NM_CYFD_ContractActivityUtility('Test Contracter',System.today(),contractList[0].Id);
        System.enqueueJob(obj);
        Test.stopTest();
    }
    
    @isTest
    public static void updateExpenditureAmountsTests(){
        List<Contract__c> contractList = [SELECT Id FROM Contract__c where Grant__c = 'JCC' LIMIT 1];

        List<Contract_Activity__c> activityList = [SELECT Activity_Label__c 
                                                   FROM Contract_Activity__c 
                                                   LIMIT 1];
        
        Test.startTest();
        NM_CYFD_ContractActivityUtility.updateExpenditureAmounts(activityList[0].Activity_LAbel__c, 'Botvin Life Skills', 'Test Contracter',System.today(),contractList[0].Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testExecute(){
        List<Contract__c> contractList = [SELECT Id FROM Contract__c LIMIT 1];
        Test.startTest();
        NM_CYFD_ContractActivityUtility obj = new NM_CYFD_ContractActivityUtility('Test Contracter',System.today(),contractList[0].Id);
        System.enqueueJob(obj);
        Test.stopTest();
    }

}