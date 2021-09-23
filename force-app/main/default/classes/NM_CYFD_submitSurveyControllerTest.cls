@isTest 
public class NM_CYFD_submitSurveyControllerTest {
    @testSetup 
    public static void makeData(){
        Account acc = new Account(Name = 'Prateek');
        insert acc;
        
        Contract__c con = new Contract__C(Account__c = acc.Id);
        insert con;
        
        Contract__c conJCC = new Contract__C(Account__c = acc.Id, Grant__c= 'JCC');
        insert conJCC;
        
        Contract__c conJJAC = new Contract__C(Account__c = acc.Id, Grant__c= 'JJAC');
        insert conJJAC;
        
        Contract__c conMentoring = new Contract__C(Account__c = acc.Id, Grant__c= 'Mentoring');
        insert conMentoring;
        
        Contract_Role__c conRole = new Contract_Role__c(Account__c = acc.Id , First_Name__c = 'Prateek', Last_Name__c = 'Bhatt', Date_of_Birth__c = Date.newInstance(1999, 11, 12),RecordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Role__c','JCC Client'));
        insert conRole;
        
        Survey__c surv = new Survey__c();
        surv.Contract_Role__c = conRole.Id;
        surv.Contract__c = con.Id;
        surv.Status__c = 'Completed';
        surv.Program_made_me_feel_better_about_myself__c='Agree';
        surv.Staff_explained_details_about_services__c = 'Yes';
        surv.Did_the_youth_have_arrest_in_the_program__c = 'Yes';
        insert surv;
    }
    @isTest 
    public static void submitSurveyTest(){
        Contract_Role__c cnRl = [SELECT Id FROM Contract_Role__c];
        Survey__c sv = [SELECT Id,Contract__c,Status__c,Staff_explained_details_about_services__c, Program_made_me_feel_better_about_myself__c FROM Survey__c];
        Test.startTest();
        NM_CYFD_SurveyWrapper wrapper = new NM_CYFD_SurveyWrapper();
        wrapper.contractId = sv.Contract__c;
        wrapper.ProgramMadeMeFeelBetterAboutMyself = sv.Program_made_me_feel_better_about_myself__c;
        wrapper.StaffExplainedDetailsAboutServices = sv.Staff_explained_details_about_services__c;
        NM_CYFD_SubmitSurveyController.submitStaffData(JSON.serialize(wrapper),sv.Id,true, cnRl.Id, 'JCC');
        NM_CYFD_SubmitSurveyController.submitYouthData(JSON.serialize(wrapper), cnRl.Id, 'JCC',sv.Id );
        NM_CYFD_SubmitSurveyController.submitYouthData(JSON.serialize(wrapper), cnRl.Id, 'JJAC',sv.Id );
        NM_CYFD_SubmitSurveyController.submitYouthData(JSON.serialize(wrapper), cnRl.Id, 'Mentoring',sv.Id );
        Test.stopTest();
    }
    @isTest
    public static void getYouthDataTest(){
        List<Survey__c> surveyList = [SELECT Id FROM Survey__c LIMIT 1];
        Test.startTest();
        NM_CYFD_SurveyWrapper surveyWrapper = NM_CYFD_SubmitSurveyController.getYouthData(surveyList[0].Id);
        Test.stopTest();
        System.assertEquals('Agree', surveyWrapper.ProgramMadeMeFeelBetterAboutMyself);
    }
    @isTest
    public static void getStaffDataTest(){
        List<Survey__c> surveyList = [SELECT Id FROM Survey__c LIMIT 1];
        Test.startTest();
        NM_CYFD_SurveyWrapper surveyWrapper = NM_CYFD_SubmitSurveyController.getStaffData(surveyList[0].Id);
        Test.stopTest();
        //System.assertEquals('Yes', surveyWrapper.DidTheYouthHaveArrestInTheProgram);
    }
    @isTest
    public static void getStatusTest(){
        List<Survey__c> surveyList = [SELECT Id FROM Survey__c LIMIT 1];
        Test.startTest();
        String status = NM_CYFD_SubmitSurveyController.getStatus(surveyList[0].Id);
        System.assertEquals('Completed', status);
        
    }
    
    @isTest
    public static void startAssessmentTest(){
        List<Contract_Role__c> roleList = [SELECT Id FROM Contract_Role__c LIMIT 1];
        List<Contract__c> contractList =[SELECT Id,Grant__c FROM Contract__c WHERE Grant__c = NULL ];
        Test.startTest();
        Map<String, Object> result = NM_CYFD_SubmitSurveyController.startAssessment(contractList[0].Id,roleList[0].Id,'Initial Assessment');
        Test.stopTest();
    }
    @isTest 
    public static void getContractDetailsTest(){
        Test.startTest();
        Contract__c cont = [SELECT Grant__c FROM Contract__c WHERE Grant__c= null];
        Contract__c contJCC = [SELECT Grant__c FROM Contract__c WHERE Grant__c= 'JCC'];
        Contract__c contJJAC = [SELECT Grant__c FROM Contract__c WHERE Grant__c= 'JJAC'];
        Contract__c contMentoring = [SELECT Grant__c FROM Contract__c WHERE Grant__c= 'Mentoring'];
        Map<String, Object> response1 = NM_CYFD_SubmitSurveyController.getContractDetails(cont.Id);
        Map<String, Object> response2 = NM_CYFD_SubmitSurveyController.getContractDetails(contJCC.Id);
        Map<String, Object> response3 = NM_CYFD_SubmitSurveyController.getContractDetails(contJJAC.Id);
        Map<String, Object> response4 = NM_CYFD_SubmitSurveyController.getContractDetails(contMentoring.Id);
        System.assertEquals(null,response1.get('grant'));
        System.assertEquals('JCC',response2.get('grant'));
        System.assertEquals('JJAC',response3.get('grant'));
        System.assertEquals('Mentoring',response4.get('grant'));
        Test.stopTest();
    }
    
    @isTest 
    public static void getPicklistFieldsTest(){
        List<Contract_Role__c> roleList = [SELECT Id FROM Contract_Role__c LIMIT 1];
        List<Contract__c> contractList =[SELECT Id,Grant__c FROM Contract__c WHERE Grant__c = NULL ];
        Test.startTest();
        NM_CYFD_SubmitSurveyController.getPicklistFields(roleList[0].Id, contractList[0].Id);
        Test.stopTest();
    }
    
    @isTest 
    public static void getYouthDataForSurveyTest(){
        List<Contract_ROle__c> cnRl = [SELECT Id,Name__c ,Date_of_Birth__c FROM Contract_Role__c LIMIT 1];
        List<Contract__c> contractList =[SELECT Id,Grant__c FROM Contract__c WHERE Grant__c = NULL ];
        Test.startTest();
        List<NM_CYFD_SubmitSurveyController.YouthWrapper> response = NM_CYFD_SubmitSurveyController.getYouthDataForSurvey(cnRl[0].Name__c,contractList[0].Id);
        System.assertNotEquals(null, response);
        Test.stopTest();
    }
    
    
    
}