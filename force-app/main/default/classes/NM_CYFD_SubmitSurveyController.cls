public without sharing class  NM_CYFD_SubmitSurveyController{

    
    @AuraEnabled
    public static Map<String, Object> submitYouthData(String surveyJSON, String youthId, String type, String surveyId, String program){ 
        Map<String, Object> response = new Map<String, Object>();
        Survey__c survey = new Survey__c();
        String recordType = '';
        NM_CYFD_SurveyWrapper surveyWrapper = (NM_CYFD_SurveyWrapper)JSON.deserialize(surveyJSON, NM_CYFD_SurveyWrapper.class);
        survey = surveyWrapper.saveYouthdata(survey);
        survey.Contract_Role__C = youthId;
        survey.Status__c = 'Pending';
        survey.Program__c = program;
        if (String.isNotBlank(survey.No_Survey_Available__c) && survey.No_Survey_Available__c != 'None' ) {

            survey.Status__c = 'Completed'; 
        }

        if(String.isNotBlank(surveyId))
           survey.Id = surveyId; 
        
           
        if(type == 'JCC')
            recordType = 'JCC Satisfaction Survey';
        else if(type == 'JJAC')
            recordType = 'JJAC Satisfaction Survey';
        else if(type == 'Mentoring')
            recordType = 'Mentoring Satisfaction Survey';
        system.debug('type %% '+ recordType);
        survey.recordTypeId = NM_CYFD_Utility.getRecordTypeId('Survey__c', recordType);
        upsert survey;
        response.put('success', true);
        response.put('surveyId', survey.Id);
        return response;
        
    }
    @AuraEnabled
    public static Map<String, Object> submitStaffData(String surveyJSON, String surveyId, Boolean submit, String youthId, String type) { 
        Map<String, Object> response = new Map<String, Object>();
        String recordType = '';
        Survey__c survey = new Survey__c();
        // if (String.isBlank(surveyId)) {
            survey.Contract_Role__C = youthId;
        // }
        system.debug('survey data  '  +surveyJSON );
        NM_CYFD_SurveyWrapper surveyWrapper = (NM_CYFD_SurveyWrapper)JSON.deserialize(surveyJSON, NM_CYFD_SurveyWrapper.class);
        survey = surveyWrapper.saveStaffData(survey);
        system.debug('survey data @@ '  +survey );
        survey.Status__c = submit? 'Completed' : 'Pending';

        if (String.isNotBlank(survey.No_Survey_Available__c) && survey.No_Survey_Available__c != 'None' ) {

            survey.Status__c = 'Completed';
        }
        
        if(String.isNotBlank(surveyId))
           survey.Id = surveyId; 

        if(type == 'JCC')
            recordType = 'JCC Satisfaction Survey';
        else if(type == 'JJAC')
            recordType = 'JJAC Satisfaction Survey';
        else if(type == 'Mentoring')
            recordType = 'Mentoring Satisfaction Survey';
        survey.recordTypeId = NM_CYFD_Utility.getRecordTypeId('Survey__c', recordType);

        upsert survey;
        response.put('success', true);
        response.put('surveyId', survey.Id);
        return response;
        
    }
    
    @AuraEnabled
    public static NM_CYFD_SurveyWrapper getYouthData(String surveyId){
        NM_CYFD_SurveyWrapper surveyWrapper = new NM_CYFD_SurveyWrapper();
        List<Survey__c> surveys = new List<Survey__c>();
        Schema.DescribeSObjectResult r = Survey__c.sObjectType.getDescribe();
         List<String>apiNames =  new list<String>();
         for(string apiName : r.fields.getMap().keySet()){
            apiNames.add(apiName);
         }
        String fieldList = String.join(apiNames, ',');
        System.debug(apiNames + '  ' + fieldList);
        String query = 'SELECT ' + fieldList + ' FROM Survey__c  WHERE Id = : surveyId';        
        surveys = Database.query(query);
        surveyWrapper.getYouthData(surveys[0]);
        return surveyWrapper;
       
    }
    @AuraEnabled
    public static NM_CYFD_SurveyWrapper getStaffData(String surveyId){
        NM_CYFD_SurveyWrapper surveyWrapper = new NM_CYFD_SurveyWrapper();
        List<Survey__c> surveys = new List<Survey__c>();
        Schema.DescribeSObjectResult r = Survey__c.sObjectType.getDescribe();
         List<String>apiNames =  new list<String>();
         for(string apiName : r.fields.getMap().keySet()){
            apiNames.add(apiName);
         }
        String fieldList = String.join(apiNames, ',');
        System.debug(apiNames + '  ' + fieldList);
        String query = 'SELECT ' + fieldList + ' FROM Survey__c  WHERE Id = : surveyId';        
        surveys = Database.query(query);
        surveyWrapper.getStaffData(surveys[0]);
        return surveyWrapper;
       
    }
    
    @AuraEnabled
    public static Map<String, Object> startAssessment(String contractId, String youthId, String assessmentType){
        Map<String, Object> response = new Map<String, Object>();
        Assessment__c assessment = new Assessment__c(Contract__c = contractId, Contract_Role__c = youthId, Status__c='Not Started', Assessment_Type__c = assessmentType, Steps_Completed__c =0);
        insert assessment;
        response.put('assessmentId', assessment.Id);
        return response;
        
    }

    
    @AuraEnabled
    public static Map<String, Object> getContractDetails(String contractId){
        Map<String, Object> response = new Map<String, Object>();
        List<Contract__c> contracts = [SELECT Grant__c FROM Contract__c WHERE Id = : contractId LIMIT 1];
        if(!contracts.isEmpty())
        response.put('grant', contracts[0].Grant__c);
        return response;
    }

    @AuraEnabled 
    public static Map<String, Object> getPicklistFields(String youthId, String contractId){
        Map<String, Object> response = new Map<String, Object>();
        //List<NM_CYFD_Utility.SelectOptionWrapper> programValues = NM_CYFD_Utility.fetchPicklist('Survey__c', 'Program__c'); 
        List<NM_CYFD_Utility.SelectOptionWrapper> programValues = new List<NM_CYFD_Utility.SelectOptionWrapper>();
        // List<String> valuesToExclude = new List<String>();
        // for(Survey__c s : [SELECt Program__c FROM Survey__c WHERE Contract_Role__c=: youthId AND Contract__c =: contractId]){
        //     valuesToExclude.add(s.Program__c);
        // }
        
        for(NM_CYFD_Utility.SelectOptionWrapper s : NM_CYFD_Utility.fetchPicklist('Survey__c', 'Program__c')){
            // if(!valuesToExclude.contains(s.value))
                programValues.add(s);
        }
      //  programValues.sort();
        response.put('programValues', programValues);
        return response;
    }
    
    @AuraEnabled
    public static List<YouthWrapper> getYouthDataForSurvey(String searchKey, String contractId) {
        String searchText = '%'+searchKey+'%';
        List<Contract__c> contracts = [SELECT Account__c FROM Contract__c WHERE Id = : contractId limit 1];
        List<Contract_Role__c> contactRole = [SELECT Id,Name__c ,Date_of_Birth__c, (SELECT Id, Status__c, Program__c , Contract__c FROM Surveys__r
                                                WHERE Contract__c =: contractId AND Contract__c != null) FROM Contract_Role__c 
                                                WHERE Name__c LIKE :('%'+searchText+'%') AND Account__c =: contracts[0].Account__c AND Active_Status__c = true AND RecordType.Name != 'Provider'];
    
        List<YouthWrapper> youthWrapper = new List<YouthWrapper>();

        for(Contract_Role__c conRole : contactRole){
            YouthWrapper youth = new YouthWrapper();
            youth.youthId = conRole.Id;
            youth.name = conRole.Name__c;
            youth.birthDate = conRole.Date_of_Birth__c;
            List<surveyWrapper> surveys = new List<surveyWrapper>();
            for(Survey__c s : conRole.Surveys__r){
               surveyWrapper survey = new surveyWrapper();
                survey.surveyId = s.Id;
                survey.status = s.Status__c;
                survey.program = s.Program__c;
                survey.completed = s.Status__c == 'Completed' ? true :  false;
                surveys.add(survey);
            }
            youth.surveys = surveys;
            youthWrapper.add(youth);
        }
        System.debug('youthWrapper ' + youthWrapper);
        return youthWrapper;

    }
    
    @AuraEnabled public static String getStatus(String surveyId){
        List<Survey__c> surveyList = [SELECT Id,Status__c FROM Survey__c WHERE Id =:surveyId LIMIT 1 ];
        if(!surveyList.isEmpty()){
            return  surveyList[0].Status__c;
        }
        return null;
    }

    public class YouthWrapper{
        @AuraEnabled public String youthId;
        @AuraEnabled public String name;
        @AuraEnabled public Date birthDate;
        @AuraEnabled public List<surveyWrapper> surveys;
    }
    
    public class SurveyWrapper{
        @AuraEnabled public String surveyId;
        @AuraEnabled public String status;
        @AuraEnabled public String program;
        @AuraEnabled public Boolean completed;
        
    }
    

}