@isTest
public class NM_CYFD_SubmitAssessmentControllerTest {
    @testSetup
    public static  void testData(){
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1, true);
        List<Contact> contactList = NM_CYFD_TestDataFactory.createContacts(1, accountList[0].Id, true);
        List<Contract_Role__c> roleList = NM_CYFD_TestDataFactory.createContractRole(3,Date.newInstance(1998, 10, 11) , accountList[0].Id, contactList[0].Id, 'JCC Client', true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(2,accountList[0].Id,null,'JCC', true);
        Assessment__c assessment = new Assessment__c();
        assessment.Contract__c  = contractList[0].Id;
        assessment.Contract_Role__c = roleList[0].Id;
        assessment.Status__c = 'In Progress';
        assessment.Assessment_Type__c = 'Initial Assessment';
        assessment.Steps_Completed__c = 0;   
        insert assessment;
    }
    @isTest
    public static void submitAssessmentTest(){
        List<Contract__c> contractList = [SELECT Id FROM Contract__c LIMIT 1 ];
        List<Contract_Role__c> roleList = [SELECT Id FROM Contract_Role__c LIMIT 1];
        Test.startTest();
        Map<String,Object> response = NM_CYFD_SubmitAssessmentController.startAssessment(contractList[0].Id,roleList[0].Id,'Discharge Assessment');
        Test.stopTest();
        List<Assessment__c> assessmentList = [SELECT Id,Contract_Role__c FROM Assessment__c WHERE Assessment_Type__c ='Discharge Assessment' ];
        System.assertEquals(roleList[0].Id, assessmentList[0].Contract_Role__c);
        
    }
    @isTest
    public static void startAssessmentTest(){
        List<Contract__c> contractList = [SELECT Id FROM Contract__c LIMIT 1 ];
        List<Contract_Role__c> roleList = [SELECT Id FROM Contract_Role__c LIMIT 1];
        List<Assessment__c> assessmentList = [SELECT Id FROM Assessment__c WHERE Assessment_Type__c = 'Initial Assessment' ];
        NM_CYFD_AssessmentWrapper assessmentWrapper = new NM_CYFD_AssessmentWrapper();
        assessmentWrapper.IKnowAnAdultWhoWillGoWithMePERM = '4';
        assessmentWrapper.IKnowWhereToGoForTheInternet = '4';
        assessmentWrapper.IHaveOneTrustedAdultWhoWillVisitSC = '2';
        assessmentWrapper.IKnowHowToShowRespectToPeople = '1';
        assessmentWrapper.IUseOnlineBankingToTrackMyMoney = '3';
        assessmentWrapper.IKnowAnAdultWhoWillGoWithMeWS = '2';
        assessmentWrapper.IKnowTheEducationINeedForWork = '1';
        assessmentWrapper.IBelieveICanInfluenceLifeTurnOut = '3';
        Test.startTest();
        Boolean result = NM_CYFD_SubmitAssessmentController.submitAssessment(JSON.serialize(assessmentWrapper),'1',String.valueOf(assessmentList[0].Id),'false');
        NM_CYFD_SubmitAssessmentController.submitAssessment(JSON.serialize(assessmentWrapper),'2',String.valueOf(assessmentList[0].Id),'false');
        NM_CYFD_SubmitAssessmentController.submitAssessment(JSON.serialize(assessmentWrapper),'3',String.valueOf(assessmentList[0].Id),'false');
        NM_CYFD_SubmitAssessmentController.submitAssessment(JSON.serialize(assessmentWrapper),'4',String.valueOf(assessmentList[0].Id),'false');
        NM_CYFD_SubmitAssessmentController.submitAssessment(JSON.serialize(assessmentWrapper),'5',String.valueOf(assessmentList[0].Id),'false');
        NM_CYFD_SubmitAssessmentController.submitAssessment(JSON.serialize(assessmentWrapper),'6',String.valueOf(assessmentList[0].Id),'false');
        NM_CYFD_SubmitAssessmentController.submitAssessment(JSON.serialize(assessmentWrapper),'7',String.valueOf(assessmentList[0].Id),'false');
        NM_CYFD_SubmitAssessmentController.submitAssessment(JSON.serialize(assessmentWrapper),'8',String.valueOf(assessmentList[0].Id),'false');
        Test.stopTest();
        System.assertEquals(result,true);
    }
    @isTest
    public static void getAssessmentTest(){
        List<Contract__c> contractList = [SELECT Id FROM Contract__c LIMIT 1 ];
        List<Contract_Role__c> roleList = [SELECT Id FROM Contract_Role__c LIMIT 1];
        List<Assessment__c> assessmentList = [SELECT Id FROM Assessment__c WHERE Assessment_Type__c = 'Initial Assessment' ];
        Assessment__c assessment = new Assessment__c();
        assessment.Id = assessmentList[0].Id;
        assessment.Steps_Completed__c = 0;
        assessment.I_know_an_adult_who_will_go_with_me__c = '3';
        assessment.I_know_where_to_go_for_the_internet__c = '4';
        assessment.I_have_one_trusted_adult_who_will_visit__c = '3';
        assessment.I_know_how_to_show_respect_to_people__c = '4';
        assessment.I_use_online_banking_to_track_my_money__c = '4';
        assessment.I_know_an_adult_who_will_go_with_me_WS__c = '3';
        assessment.I_know_the_education_I_need_for_work__c = '1';
        assessment.I_believe_I_can_influence_life_turn_out__c = '2';
        update assessment;
        Test.startTest();
        NM_CYFD_SubmitAssessmentController.getAssessment(assessmentList[0].Id, '2');
        NM_CYFD_SubmitAssessmentController.getAssessment(assessmentList[0].Id, '3');
        NM_CYFD_SubmitAssessmentController.getAssessment(assessmentList[0].Id, '4');
        NM_CYFD_SubmitAssessmentController.getAssessment(assessmentList[0].Id, '5');
        NM_CYFD_SubmitAssessmentController.getAssessment(assessmentList[0].Id, '6');
        NM_CYFD_SubmitAssessmentController.getAssessment(assessmentList[0].Id, '7');
        NM_CYFD_SubmitAssessmentController.getAssessment(assessmentList[0].Id, '8');
        NM_CYFD_SubmitAssessmentController.getAssessment(assessmentList[0].Id, '9');
        Test.stopTest();
    }
    @isTest
    public static void getYouthTest(){
        List<Contract__c> contractList = [SELECT Id FROM Contract__c ];
        Test.startTest();
        Map<String,Object> result = NM_CYFD_SubmitAssessmentController.getYouthDataForAssessment(contractList[0].Id, '', 'Initial Assessment','Start Initial Assessment' );
        NM_CYFD_SubmitAssessmentController.getYouthDataForAssessment(contractList[0].Id, 'A', 'Initial Assessment','Start Initial Assessment' );
        Test.stopTest();
        //System.assertEquals(result, actual);

        
    }
    @isTest
    public static void getYouthTestDischargeAssessmentTest(){
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1, true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(2,accountList[0].Id,null,'JJAC', true);
        List<Contact> contactList = [SELECT Id FROM Contact LIMIT 1];
        List<Contract_Role__c> roleList = NM_CYFD_TestDataFactory.createContractRole(3,Date.newInstance(1998, 10, 11) , accountList[0].Id, contactList[0].Id, 'JCC Client', true);
        Assessment__c assessment = new Assessment__c();
        assessment.Contract__c  = contractList[0].Id;
        assessment.Contract_Role__c = roleList[0].Id;
        assessment.Status__c = 'In Progress';
        assessment.Assessment_Type__c = 'Discharge Assessment';
        assessment.Steps_Completed__c = 0;   
        insert assessment;
        Test.startTest();
        Map<String,Object> result = NM_CYFD_SubmitAssessmentController.getYouthDataForAssessment(contractList[0].Id, '', 'Discharge Assessment','Start Initial Assessment' );
        Test.stopTest();
    }
    @isTest
    public static void getStatusTest(){
	    List<Assessment__c> assessmentList = [SELECT Id,Status__c FROM Assessment__c LIMIT 1 ];
        Test.startTest();
        String result = NM_CYFD_SubmitAssessmentController.getStatus(assessmentList[0].Id);
        NM_CYFD_SubmitAssessmentController.getStatus('');
        Test.stopTest();
        System.assertEquals(assessmentList[0].Status__c, result);
    }
}