@isTest
public class NM_CYFD_UserTriggerHandlerTest {
    @isTest
    public static void contractSharingToPortalUsersTest(){
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contact> contactList = NM_CYFD_TestDataFactory.createContacts(1,accountList[0].Id,true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1,accountList[0].Id,null,'JCC',true);
        List<Contract_Role__c> contractRoleList = NM_CYFD_TestDataFactory.createContractRole(1,Date.newInstance(1998, 10, 11),accountList[0].Id,contactList[0].Id,'Clients', true);
        Test.startTest();
        List<User> userList = NM_CYFD_TestDataFactory.createJCCPortalUserList(contactList,true);
        Test.stopTest();
        System.assertEquals(false, userList.isEmpty());
    }
}