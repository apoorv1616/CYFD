public with sharing class NM_CYFD_GenerateAssessmentPDF {
    public NM_CYFD_GenerateAssessmentPDF(ApexPages.StandardController controller) {
        
        String assessmentId = ApexPages.CurrentPage().getparameters().get('id');
        assessment = new NM_CYFD_AssessmentWrapper();
        List<Assessment__c> assessmentList = new List<Assessment__c>();
        
        
        // get all fields from  fieldset
		List<String>apiNames =  new list<String>();
        
        for ( Schema.FieldSetMember f :  SObjectType.Assessment__c.FieldSets.Questions.getFields() ) {   
            system.debug( f.getFieldPath() );  
            apiNames.add('toLabel('+f.getFieldPath()+ ')');
        } 
        String fieldList = String.join(apiNames, ',');
        System.debug(apiNames + '  ' + fieldList);
        String query = 'SELECT id, Name, Completion_Date__c, Assessment_Type__c , ' + fieldList + ', Contract__r.Name__c, Contract_Role__r.Youth_Id__c, Contract_Role__r.Name__c FROM Assessment__c  WHERE Id = : assessmentId';
        
        assessmentList = Database.query(query);
        //assessment.getPermanancy(assessmentList[0], true);
        assessment.getDailyLiving(assessmentList[0], true);
        assessment.getSelfCare(assessmentList[0], true);
        assessment.getHousing(assessmentList[0], true);
        assessment.getRelations(assessmentList[0], true);
        assessment.getWorkAndStudy(assessmentList[0], true);
        assessment.getCareerAndEducation(assessmentList[0], true);
        assessment.getLookingForward(assessmentList[0], true);
        
        //permanencyAvg = (assessment.permanencyAvg/20).setScale(2);
        
        dailyLivingAvg = (assessment.dailyLivingAvg/17).setScale(2);
    	selfCareAvg = (assessment.selfCareAvg/17).setScale(2);
        relationships_communicationsAvg = (assessment.relationships_communicationsAvg/18).setScale(2);
     	housing_moneyAvg = (assessment.housing_moneyAvg/23).setScale(2);
       
     	work_studyLifeAvg = (assessment.work_studyLifeAvg/20).setScale(2);
        
     	career_educationPlanningAvg = (assessment.career_educationPlanningAvg/9).setScale(2);
        lookingForwardAvg = (assessment.lookingForwardAvg/8).setScale(2);
        overallAvg = ( dailyLivingAvg + selfCareAvg + relationships_communicationsAvg 
                      + housing_moneyAvg + work_studyLifeAvg + career_educationPlanningAvg + lookingForwardAvg)/7;
        overallAvg = overallAvg.setScale(2);
        completionDate = formatDate(assessmentList[0].Completion_Date__c);
        contractName = assessmentList[0].Contract__r.Name__c ;
        clientName = assessmentList[0].Contract_Role__r.Name__c ;
        youthId = assessmentList[0].Contract_Role__r.Youth_Id__c ;
        assessmentType = assessmentList[0].Assessment_Type__c ;
        
    }
    
    public static String formatDate(Date d) {
        if(d != null)
            return  d.month() + '/' + d.day() + '/' + d.year() ;
        return null;
    }
    
    public NM_CYFD_AssessmentWrapper assessment{get;set;}
    public String completionDate{get;set;}
    public String assessmentType{get;set;}
    public String clientName{get;set;}
    public String youthId{get;set;}
    public String contractName{get;set;}
    public Decimal overallAvg{get;set;}
    // public Decimal permanencyAvg{get;set;}
    public Decimal dailyLivingAvg{get;set;}
    public Decimal selfCareAvg{get;set;}
    public Decimal relationships_communicationsAvg{get;set;}
    public Decimal housing_moneyAvg{get;set;}
    public Decimal work_studyLifeAvg{get;set;}
    public Decimal career_educationPlanningAvg{get;set;}
    public Decimal lookingForwardAvg{get;set;}
  
}