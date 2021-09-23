@isTest
public class NM_CYFD_ConfigurationControllerTest {
    @TestSetup
    static void makeData(){
        
        Id caRecordTypeId = Schema.SObjectType.Contract_Activity__c.getRecordTypeInfosByName().get('Billable Activity').getRecordTypeId();
        Contract_Configuration__c contractConfig = NM_CYFD_TestDataFactory.createContractConfigurationRecords(1, true)[0];
        List<CYFD_Activity__c> billableCYFDActivities = NM_CYFD_TestDataFactory.createCYFDActivity (2, 'Billable Activity', true);
        List<CYFD_Activity__c> deliverableCYFDActivities = NM_CYFD_TestDataFactory.createCYFDActivity (2, 'Deliverable', true);
        
    }
    
    @isTest
    public static void getCYFDActivitiesTest(){
        
        Contract_Configuration__c contractConfig = [SELECT Id FROM Contract_Configuration__c LIMIT 1];
        Test.startTest();
            Map<String, Object> response = NM_CYFD_ConfigurationController.getCYFDActivities(contractConfig.Id);
            System.assertNotEquals(response.get('billables'), null);
        Test.stopTest();
    }
        
    @isTest
    public static void createContractCongifLineitemsTest(){
        Contract_Configuration__c contractConfig = [SELECT Id FROM Contract_Configuration__c LIMIT 1];
        Map<String, Object> response = NM_CYFD_ConfigurationController.getCYFDActivities(contractConfig.Id);
        List<NM_CYFD_ConfigurationController.CYFDActivityWrapper> activities = (List<NM_CYFD_ConfigurationController.CYFDActivityWrapper>)response.get('billables');
        
        Test.startTest();
            Boolean result = NM_CYFD_ConfigurationController.createContractCongifLineitems(JSON.serialize(activities));
            System.assertEquals(result, true);
        Test.stopTest();
    }
}