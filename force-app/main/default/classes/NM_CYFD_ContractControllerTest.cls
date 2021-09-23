@isTest
public class NM_CYFD_ContractControllerTest {
    @TestSetup
    static void makeData(){
        Id caRecordTypeId = Schema.SObjectType.Contract_Activity__c.getRecordTypeInfosByName().get('Billable Activity').getRecordTypeId();
        Contract_Configuration__c contractConfig = NM_CYFD_TestDataFactory.createContractConfigurationRecords(1, true)[0];
        List<CYFD_Activity__c> billableCYFDActivities = NM_CYFD_TestDataFactory.createCYFDActivity (2, 'Billable Activity', true);
        List<CYFD_Activity__c> deliverableCYFDActivities = NM_CYFD_TestDataFactory.createCYFDActivity (2, 'Deliverable', true);
        
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contact> contactList = NM_CYFD_TestDataFactory.createContacts(2,accountList[0].Id,true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(2,accountList[0].Id,contractConfig.Id,'JCC',true);
        
       
        List<Contract_Activity__c > contractacitivites = NM_CYFD_TestDataFactory.createContractActivity(2,contractList[0].Id, 'Deliverable', true);
        
    }
    
    @isTest
    public static void getNavigationNodesTest(){
        Test.startTest();
            List<NM_CYFD_Utility.StepsWrapper> steps = NM_CYFD_Utility.getNavigationNodes('Log Activity');
            System.assertNotEquals(steps, null);
        Test.stopTest();
    }
        
    @isTest
    public static void getContractRecordTest(){
        Contract__c c = [SELECT Id FROM Contract__c LIMIT 1];      
        Test.startTest();
        Contract__c contract = NM_CYFD_ContractController.getContractRecord(c.Id);
        System.assertNotEquals(contract, null);
        Test.stopTest();
        
    }
    
    @isTest
    public static void updateContractActivityStatusTest(){
        Contract_Activity__c activity = [SELECT Id FROM Contract_Activity__c WHERE RecordType.DeveloperName = 'Deliverable' LIMIT 1];      
        Test.startTest();
            Contract_Activity__c contractActivity = NM_CYFD_ContractController.updateContractActivityStatus(activity.Id, 'Submitted');
            System.assertNotEquals(contractActivity, null);
        Test.stopTest();
        
    }
    
    @isTest
    public static void getContractActivitiesTest(){
        Contract__c c = [SELECT Id FROM Contract__c LIMIT 1];            
        Test.startTest();
            Map<String,List<Object>> obj = NM_CYFD_ContractController.getContractActivities(c.Id);
            System.assertNotEquals(obj, null);
        Test.stopTest();
        
    }
    
}