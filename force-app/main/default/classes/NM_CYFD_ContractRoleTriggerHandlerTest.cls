@isTest
public class NM_CYFD_ContractRoleTriggerHandlerTest {
@isTest
    static void makeData(){
        
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contact> contactList = NM_CYFD_TestDataFactory.createContacts(2,accountList[0].Id,true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(2,accountList[0].Id,null,'JCC',true);
        List<Contract_Role__c> contractRoleList = NM_CYFD_TestDataFactory.createContractRole(1,Date.newInstance(1998, 10, 11),accountList[0].Id,null,'Provider', true);
       /* List<Contract_Role__c> insertContractRole = new List<Contract_Role__c>();
        for(Contract_Role__c cR : contractRoleList){
            cR.RecordTypeId = NM_CYFD_Constants.NM_CYFD_CONTRACT_ROLE_RECORDTYPEID;
            insertContractRole.add(cR);
        }
        insert contractRoleList;*/
        Test.startTest();
        List<User> userList = NM_CYFD_TestDataFactory.createJCCPortalUserList(contactList,true);
        contractRoleList[0].Contact__c = contactList[1].id;
        update contractRoleList[0];
        Test.stopTest();
    }
}