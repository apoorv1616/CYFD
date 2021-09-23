@isTest
public class NM_CYFD_GenerateSurveyPDFTest {
    @isTest
    public static void NM_CYFD_GenerateSurveyPDF_Test(){
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1, true);
        List<Contact> contactList = NM_CYFD_TestDataFactory.createContacts(1, accountList[0].Id, true);
        List<Contract_Role__c> roleList =  NM_CYFD_TestDataFactory.createContractRole(1, Date.newInstance(1998, 10, 11),accountList[0].Id , contactList[0].Id, 'Clients', true);
        Survey__c survey = new Survey__c();
        survey.Contract_Role__c = roleList[0].Id;
        insert survey;
        List<Survey__c> surveyList = [SELECT Id FROM Survey__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.NM_CYFD_SurveyPDF;
        Test.setCurrentPage(pageRef);
     	pageRef.getParameters().put('Id', String.valueOf(surveyList[0].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(surveyList[0]);
        NM_CYFD_GenerateSurveyPDF generateAssessment = new NM_CYFD_GenerateSurveyPDF(sc);
        Test.stopTest();
        
        
    }

}