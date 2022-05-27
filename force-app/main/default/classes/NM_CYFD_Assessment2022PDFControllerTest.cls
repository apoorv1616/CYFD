@isTest
public class NM_CYFD_Assessment2022PDFControllerTest {
    
    @isTest
    static void test() {
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1, true);
        List<Contact> contactList = NM_CYFD_TestDataFactory.createContacts(1, accountList[0].Id, true);
        List<Contract_Role__c> roleList =  NM_CYFD_TestDataFactory.createContractRole(1, Date.newInstance(1998, 10, 11),accountList[0].Id , contactList[0].Id, 'Clients', true);
        
        Assessment_2022__c assessment = new Assessment_2022__c();
        //assessment.Contract__c  = contractList[0].Id;
        assessment.Contract_Role__c = roleList[0].Id;
        assessment.Status__c = 'In Progress';
        assessment.Assessment_Type__c = 'Initial Assessment';
        assessment.Steps_Completed__c = 0; 
        assessment.completion_date__c = Date.today();
        insert assessment;
        
        List<Assessment_2022__c> assessmentList = [SELECT Id FROM Assessment_2022__c LIMIT 1];
        
        Test.startTest();
            PageReference pageRef = Page.NM_CYFD_AssesmentPDF;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', String.valueOf(assessmentList[0].Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(assessmentList[0]);
            NM_CYFD_Assessment2022PDFController generateAssessment = new NM_CYFD_Assessment2022PDFController(sc);
        Test.stopTest();
    }
 }