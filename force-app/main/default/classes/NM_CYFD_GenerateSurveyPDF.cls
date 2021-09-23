public with sharing class NM_CYFD_GenerateSurveyPDF {
    public NM_CYFD_GenerateSurveyPDF(ApexPages.StandardController controller){
        String surveyId = ApexPages.CurrentPage().getparameters().get('id');
        survey = new NM_CYFD_SurveyWrapper();
        List<Survey__c> surveyList = new List<Survey__c>();
        
        List<String>apiNames =  new list<String>();
        for ( Schema.FieldSetMember f :  SObjectType.Survey__c.FieldSets.Questions.getFields() ) {   
            system.debug( f.getFieldPath() );  
            apiNames.add('toLabel('+f.getFieldPath()+ ')');
              
        } 
        String fieldList = String.join(apiNames, ',');
        System.debug(apiNames + '  ' + fieldList);
        String query = 'SELECT id, Name,RecordTypeId,createdDate,lastModifiedDate, Program__c ,Contract_Role__c, Contract_Role__r.Youth_Id__c ,Contract__r.Name__c ,Contract__r.Grant__c , ' + fieldList + ' FROM Survey__c  WHERE Id = : surveyId';
        surveyList = Database.query(query);
        jjac = surveyList[0].Contract__r.Grant__c == 'JJAC' ? true : false;
        jcc  = surveyList[0].Contract__r.Grant__c == 'JCC' ? true: false;
        mentoring = surveyList[0].Contract__r.Grant__c == 'Mentoring' ? true : false;
        
        completionDate = formatDate(date.newinstance(surveyList[0].lastModifiedDate.year(),surveyList[0].lastModifiedDate.month(),surveyList[0].lastModifiedDate.day()));
        startDate = formatDate(date.newinstance(surveyList[0].createdDate.year(),surveyList[0].createdDate.month(),surveyList[0].createdDate.day()));
        program = surveyList[0].Program__c;
        youthId = surveyList[0].Contract_Role__r.Youth_Id__c;
        contractName = surveyList[0].Contract__r.Name__c;
        survey.getStaffdata(surveyList[0]);
        survey.getYouthdata(surveyList[0]);
    }
    
    
    public static String formatDate(Date d) {
        
            return  d.month() + '/' + d.day() + '/' + d.year() ;
        
    }
    
    public NM_CYFD_SurveyWrapper survey{get;set;}
    public Boolean jjac{get;set;}
    public Boolean jcc{get;set;}
    public Boolean mentoring{get;set;}
    public String program{get;set;}
    public String youthId{get;set;}
    public String contractName {get;set;}
    public String completionDate {get;set;}
    public String startDate {get;set;}
    

}