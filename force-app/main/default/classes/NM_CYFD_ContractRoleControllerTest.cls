@isTest
public class NM_CYFD_ContractRoleControllerTest {
    @TestSetup
    static void makeData(){
        Id caRecordTypeId = Schema.SObjectType.Contract_Activity__c.getRecordTypeInfosByName().get('Billable Activity').getRecordTypeId();
        Contract_Configuration__c contractConfig = NM_CYFD_TestDataFactory.createContractConfigurationRecords(1, true)[0];
        List<CYFD_Activity__c> billableCYFDActivities = NM_CYFD_TestDataFactory.createCYFDActivity (2, 'Billable Activity', false);
        billableCYFDActivities[0].Name__c = 'Job Preparation';
        billableCYFDActivities[0].Unit_Type__c = 'Per Hour';
        billableCYFDActivities[0].Activity_Type__c = 'Individual';
        billableCYFDActivities[0].Activity_Rate__c = 100;
        billableCYFDActivities[0].Program__c = 'Travel';
        billableCYFDActivities[1].Name__c = 'Financial Assistance';
        billableCYFDActivities[1].Unit_Type__c = 'Per Youth';
        billableCYFDActivities[1].Activity_Type__c = '';
        billableCYFDActivities[1].Activity_Rate__c = 200;
        billableCYFDActivities[1].Program__c = 'Travel';
        upsert billableCYFDActivities;
            
        List<CYFD_Activity__c> deliverableCYFDActivities = NM_CYFD_TestDataFactory.createCYFDActivity (2, 'Deliverable', true);
        
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contact> contactList = NM_CYFD_TestDataFactory.createContacts(2,accountList[0].Id,true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1,accountList[0].Id,contractConfig.Id,'JCC',true);
        
        List<Contract_Role__c> clientContractRoleList = NM_CYFD_TestDataFactory.createContractRole(1,Date.newInstance(1998, 10, 11),accountList[0].Id,contactList[0].Id,'Clients', false);
        for(Contract_Role__c cr : clientContractRoleList){
            cr.Contract_Role__c = 'JCC Client';
            cr.Contact__c = contactList[0].id;
        }
        insert clientContractRoleList;
        List<Contract_Role__c> staffContractRoleList = NM_CYFD_TestDataFactory.createContractRole(1,Date.newInstance(1998, 11, 11),accountList[0].Id,contactList[0].Id,'Provider', false);
        for(Contract_Role__c cr : staffContractRoleList){
            cr.Contract_Role__c = 'Staff';
            cr.Contact__c = contactList[0].id;
        }
        insert staffContractRoleList;
       // List<User> userList = NM_CYFD_TestDataFactory.createJCCPortalUserList(contactList,true);
        
        List<Contract_Activity__c > contractacitivites = NM_CYFD_TestDataFactory.createContractActivity(2,contractList[0].Id, 'Deliverable', true);
        
        List<Contract_COnfiguration_Line_Item__c> configLineItems = new List<Contract_COnfiguration_Line_Item__c>();
        for(CYFD_Activity__c act : billableCYFDActivities){
            Contract_Configuration_Line_Item__c configLI = NM_CYFD_TestDataFactory.createContractConfigurationLIRecords(1, contractConfig.Id, act.Id, false)[0];
            configLineItems.add(configLI);
        }
        insert configLineItems;
        List<User> jjacUserList = NM_CYFD_TestDataFactory.createPortalUserList(contactList, 'JJAC Community User', true);
        
    }
    
    @isTest
    public static void getPicklistFieldsTest(){
        Contract_Role__c cr = [SELECT Id FROM Contract_Role__C LIMIT 1];
        Test.startTest();
           NM_CYFD_ContractRoleController.getRecordTypeDetails(cr.Id);
           NM_CYFD_ContractRoleController.getContractRoleDetails(cr.Id);
        Test.stopTest();
    }
    
    
    @isTest
    public static void createContractActivityTest(){
        User u = [SELECT Id FROM User WHERE Profile.Name = 'JJAC Community User'  AND isactive = true  LIMIT 1];
        Contract__c c = [SELECT Id, Contract_Configuration__c FROM Contract__c LIMIT 1];
        Contract_COnfiguration_Line_Item__c ccli = [SELECT Id FROM Contract_COnfiguration_Line_Item__c WHERE CyFD_Activity__r.Activity_Label__c = 'Financial Assistance' LIMIT 1];      
        List<ContractRoleWrapper> clients = new List<ContractRoleWrapper>();
        ContractRoleWrapper cl = new ContractRoleWrapper();
        cl.firstName = 'first';
        cl.lastName = 'client';
        cl.dob = system.today();
        clients.add(cl);
        List<ContractRoleWrapper> staffs = new List<ContractRoleWrapper>();
        ContractRoleWrapper s = new ContractRoleWrapper();
        s.firstName = 'first';
        s.lastName = 'staff';
        s.dob = system.today();
        
    
       
        Test.startTest();
            NM_CYFD_ContractRoleController.saveContractRole(JSON.serialize(cl),c.Id, 'Client', null);
        Test.stopTest();
              
    }
    
    
  }