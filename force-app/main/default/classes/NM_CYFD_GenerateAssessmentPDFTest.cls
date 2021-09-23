@isTest
public class NM_CYFD_GenerateAssessmentPDFTest {
    @isTest
    public static void NM_CYFD_GenerateAssessmentPDF_Test(){
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1, true);
        List<Contact> contactList = NM_CYFD_TestDataFactory.createContacts(1, accountList[0].Id, true);
        List<Contract_Role__c> roleList =  NM_CYFD_TestDataFactory.createContractRole(1, Date.newInstance(1998, 10, 11),accountList[0].Id , contactList[0].Id, 'Clients', true);
        Assessment__c assessment = new Assessment__c();
        assessment.Contract_Role__c = roleList[0].Id;
        insert assessment;
        List<Assessment__c> assessmentList = [SELECT Id FROM Assessment__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.NM_CYFD_AssesmentPDF;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(assessmentList[0].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(assessmentList[0]);
        NM_CYFD_GenerateAssessmentPDF generateAssessment = new NM_CYFD_GenerateAssessmentPDF(sc);
        Test.stopTest();
    }

}