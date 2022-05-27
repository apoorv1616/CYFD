@isTest
public class NM_CYFD_ActivityRoleTriggerHandlerTest {
    @isTest
    static void makeData(){
        Id caRecordTypeId = Schema.SObjectType.Contract_Activity__c.getRecordTypeInfosByName().get('Billable Activity').getRecordTypeId();
        Contract_Configuration__c contractConfig = NM_CYFD_TestDataFactory.createContractConfigurationRecords(1, true)[0];
        List<CYFD_Activity__c> billableCYFDActivities = NM_CYFD_TestDataFactory.createCYFDActivity (2, 'Billable Activity', false);
        billableCYFDActivities[0].Name__c = 'JCC - Job Preparation';
        billableCYFDActivities[0].Unit_Type__c = 'Per Hour';
        billableCYFDActivities[0].Activity_Type__c = 'Individual';
        billableCYFDActivities[0].Activity_Rate__c = 100;
        billableCYFDActivities[0].Program__c = 'Travel';
        billableCYFDActivities[1].Name__c = 'JCC - Financial Assistance';
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
        
        List<Contract_Activity__c > contractacitivites = NM_CYFD_TestDataFactory.createContractActivity(2,contractList[0].Id, 'Billable Activity', true);
        
        List<Contract_COnfiguration_Line_Item__c> configLineItems = new List<Contract_COnfiguration_Line_Item__c>();
        for(CYFD_Activity__c act : billableCYFDActivities){
            Contract_Configuration_Line_Item__c configLI = NM_CYFD_TestDataFactory.createContractConfigurationLIRecords(1, contractConfig.Id, act.Id, false)[0];
            configLineItems.add(configLI);
        }
        insert configLineItems;
        Id staffRecordTypeId = NM_CYFD_Utility.getRecordTypeId('Activity_Role__c','Provider');
        Test.startTest();
            Activity_Role__c ar = new Activity_Role__c(RecordTypeId = staffRecordTypeId, Contract_Activity__c = contractacitivites[0].Id, Contract_Role__c = staffContractRoleList[0].Id);
            ar.Contract__c = contractList[0].Id;
        	insert ar;
        Test.stopTest();
        List<User> jjacUserList = NM_CYFD_TestDataFactory.createPortalUserList(contactList, 'JJAC Community User', true);
        
    }
    
    @isTest
    static void testCountNumberOfYouthsOnContract() {
         Id caRecordTypeId = Schema.SObjectType.Contract_Activity__c.getRecordTypeInfosByName().get('Billable Activity').getRecordTypeId();
        Contract_Configuration__c contractConfig = NM_CYFD_TestDataFactory.createContractConfigurationRecords(1, true)[0];
        List<CYFD_Activity__c> billableCYFDActivities = NM_CYFD_TestDataFactory.createCYFDActivity (2, 'Billable Activity', false);
        billableCYFDActivities[0].Name__c = 'JCC - Job Preparation';
        billableCYFDActivities[0].Unit_Type__c = 'Per Hour';
        billableCYFDActivities[0].Activity_Type__c = 'Individual';
        billableCYFDActivities[0].Activity_Rate__c = 100;
        billableCYFDActivities[0].Program__c = 'Travel';
        billableCYFDActivities[1].Name__c = 'JCC - Financial Assistance';
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
        
        List<Contract_Role__c> clientContractRole1List = NM_CYFD_TestDataFactory.createContractRole(1,Date.newInstance(1998, 10, 11),accountList[0].Id,contactList[0].Id,'Clients', false);
        for(Contract_Role__c cr : clientContractRole1List){
            cr.Contract_Role__c = 'JCC Client';
            cr.Contact__c = contactList[0].id;
        }
        
        insert clientContractRole1List;
        
        List<Contract_Activity__c > contractacitivites = NM_CYFD_TestDataFactory.createContractActivity(2,contractList[0].Id, 'Billable Activity', true);
        Id clientsRecordTypeId = NM_CYFD_Utility.getRecordTypeId('Activity_Role__c','Clients');
        Test.startTest();
            Activity_Role__c ar = new Activity_Role__c(RecordTypeId = clientsRecordTypeId, Contract_Activity__c = contractacitivites[0].Id, Contract_Role__c = clientContractRoleList[0].Id);
            ar.Contract__c = contractList[0].Id;
        	insert ar;
        
        	Activity_Role__c ar1 = new Activity_Role__c(RecordTypeId = clientsRecordTypeId, Contract_Activity__c = contractacitivites[0].Id, Contract_Role__c = clientContractRole1List[0].Id);
            ar1.Contract__c = contractList[0].Id;
        	insert ar1;
        
        Test.stopTest();
        
    }
  
    @isTest
    static void testUpdateContractActivityAmountForMentoring() {
        Id caRecordTypeId = Schema.SObjectType.Contract_Activity__c.getRecordTypeInfosByName().get('Billable Activity').getRecordTypeId();
        Contract_Configuration__c contractConfig = NM_CYFD_TestDataFactory.createContractConfigurationRecords(1, true)[0];
        List<CYFD_Activity__c> billableCYFDActivities = NM_CYFD_TestDataFactory.createCYFDActivity (2, 'Billable Activity', false);
        billableCYFDActivities[0].Name__c = 'JCC - Job Preparation';
        billableCYFDActivities[0].Unit_Type__c = 'Per Hour';
        billableCYFDActivities[0].Activity_Type__c = 'Individual';
        billableCYFDActivities[0].Activity_Rate__c = 100;
        billableCYFDActivities[0].Program__c = 'Travel';
        billableCYFDActivities[1].Name__c = 'JCC - Financial Assistance';
        billableCYFDActivities[1].Unit_Type__c = 'Per Youth';
        billableCYFDActivities[1].Activity_Type__c = '';
        billableCYFDActivities[1].Activity_Rate__c = 200;
        billableCYFDActivities[1].Program__c = 'Travel';
        upsert billableCYFDActivities;
            
        List<CYFD_Activity__c> deliverableCYFDActivities = NM_CYFD_TestDataFactory.createCYFDActivity (2, 'Deliverable', true);
        
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contact> contactList = NM_CYFD_TestDataFactory.createContacts(2,accountList[0].Id,true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1,accountList[0].Id,contractConfig.Id,'Mentoring',true);
        contractList[0].Grant__c = 'Mentoring';
        update contractList;
        
        List<Contract_Role__c> clientContractRoleList = NM_CYFD_TestDataFactory.createContractRole(1,Date.newInstance(1998, 10, 11),accountList[0].Id,contactList[0].Id,'Clients', false);
        for(Contract_Role__c cr : clientContractRoleList){
            cr.Contract_Role__c = 'Mentoring Client';
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
        
        List<Contract_Activity__c > contractacitivites = NM_CYFD_TestDataFactory.createContractActivity(2,contractList[0].Id, 'Billable Activity', true);
        contractacitivites[0].Date__c = date.today();
        update contractacitivites;
        
        List<Contract_COnfiguration_Line_Item__c> configLineItems = new List<Contract_COnfiguration_Line_Item__c>();
        for(CYFD_Activity__c act : billableCYFDActivities){
            Contract_Configuration_Line_Item__c configLI = NM_CYFD_TestDataFactory.createContractConfigurationLIRecords(1, contractConfig.Id, act.Id, false)[0];
            configLineItems.add(configLI);
        }
        insert configLineItems;
        Id staffRecordTypeId = NM_CYFD_Utility.getRecordTypeId('Activity_Role__c','Provider');
        Test.startTest();
            Activity_Role__c ar = new Activity_Role__c(RecordTypeId = staffRecordTypeId, Contract_Activity__c = contractacitivites[0].Id, Contract_Role__c = staffContractRoleList[0].Id);
        	ar.RecordTypeId = NM_CYFD_Utility.getRecordTypeId('Activity_Role__c','Clients');
        	insert ar;
        Test.stopTest();
        List<User> jjacUserList = NM_CYFD_TestDataFactory.createPortalUserList(contactList, 'JJAC Community User', true);
       
    }
}