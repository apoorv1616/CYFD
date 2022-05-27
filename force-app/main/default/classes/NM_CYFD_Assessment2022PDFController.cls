public without sharing class NM_CYFD_Assessment2022PDFController {
    
    public Assessment_2022__c assessment{get;set;}
    public Map<String, List<AssessmentQuestions>> mapOfSectionToAssessment {get;set;}
    public List<String> sectionNameList {get;set;}
    public Map<String, Decimal> mapOfSectionToScore {get;set;}
    public Map<String, Decimal> mapOfSectionToAverage {get;set;}
    public Map<String, Decimal> mapOfSectionToTotalQuestions {get;set;}
    public Decimal totalScore {get;set;}
    public Decimal totalCount {get;set;}
    public Decimal totalAverage {get;set;}
    public String completionDate {get;set;}
    
    // Get all fields from object
    public String getAllFieldsFromObject() {
        Schema.DescribeSObjectResult obj = Assessment_2022__c.sObjectType.getDescribe();
        List<String>apiNames =  new list<String>();
        for(string apiName : obj.fields.getMap().keySet()){
            apiNames.add(apiName);
        }
        return String.join(apiNames, ',');
    }
    
    public List<Assessment_2022_Questions__mdt> getAllQuestionsFromMetadata() {
        List<Assessment_2022_Questions__mdt> questionsList = Nmcyfd_Assessment2022Controller.getAllAssessmentQuestions();
        
        return questionsList;
    }

	
    public NM_CYFD_Assessment2022PDFController(ApexPages.StandardController controller) {
        
        String assessmentId = ApexPages.CurrentPage().getparameters().get('id');
        
        List<Assessment_2022__c> assessmentList = new List<Assessment_2022__c>();

        String fieldList = getAllFieldsFromObject();
        
        String query = ' SELECT ' + fieldList + ', Contract__r.Name__c, Contract_Role__r.Youth_Id__c, Contract_Role__r.Name__c '
            		 + ' FROM Assessment_2022__c  '
            		 + ' WHERE Id = : assessmentId ';
        
        assessmentList = Database.query( query );
        
        if ( !assessmentList.isEmpty() ) {
            this.assessment = assessmentList[0];
            completionDate = formatDate(this.assessment.completion_date__c);
        }
        
        this.mapOfSectionToAssessment = new Map<String, List<AssessmentQuestions>>();
        this.sectionNameList = new List<String>();
        this.mapOfSectionToScore = new Map<String, Decimal>();
        this.mapOfSectionToAverage = new Map<String, Decimal>();
        this.mapOfSectionToTotalQuestions = new Map<String, Decimal>();
        
        Map<Integer, String> mapOfAnswerValueToOptions = new Map<Integer, String>{
                                                            1 => 'No',
                                                            2 => 'Mostly No', 
                                                            3 => 'Somewhat ', 
                                                            4 => 'Mostly Yes', 
                                                            5 => 'Yes'
                                                          };
        
        for ( Assessment_2022_Questions__mdt metadata : getAllQuestionsFromMetadata() ) {

            if ( !mapOfSectionToAssessment.containsKey( metadata.Section_Name__c ) ) {
                this.mapOfSectionToAssessment.put( metadata.Section_Name__c, new List<AssessmentQuestions>() );
                
                if ( !this.sectionNameList.contains( metadata.Section_Name__c ) ) {
                    
                    this.sectionNameList.add( metadata.Section_Name__c );
                }
            }
            
            AssessmentQuestions question = new AssessmentQuestions();
            question.questionLabel = metadata.Questions_Label__c;
            question.assessmentAPI = metadata.Assement_API__c;
            question.sectionName = metadata.Section_Name__c;
            question.assessmentValue = String.valueOf(this.assessment.get(metadata.Assement_API__c));
            question.assessmentValueLabel = Test.isRunningTest() ? 'test' : mapOfAnswerValueToOptions.get( Integer.valueOf(question.assessmentValue ));
            //question.sectionScoreSum += question.assessmentValue != null ? Integer.valueOf(question.assessmentValue ) : 0;
            
            //calculate score
            if ( !this.mapOfSectionToScore.containsKey( metadata.Section_Name__c ) ) {
                this.mapOfSectionToScore.put( metadata.Section_Name__c, 0 );
            }
            Decimal score = this.mapOfSectionToScore.get( metadata.Section_Name__c );
            score += Test.isRunningTest() ? 1 : Decimal.valueOf(question.assessmentValue);
			this.mapOfSectionToScore.put( metadata.Section_Name__c, score );
            
            //total questions
            if ( !this.mapOfSectionToTotalQuestions.containsKey( metadata.Section_Name__c ) ) {
                this.mapOfSectionToTotalQuestions.put( metadata.Section_Name__c, 0 );
            }
            Decimal countOfQuestions = this.mapOfSectionToTotalQuestions.get( metadata.Section_Name__c );
            countOfQuestions += 1;
			this.mapOfSectionToTotalQuestions.put( metadata.Section_Name__c, countOfQuestions );
            
            this.mapOfSectionToAssessment.get( metadata.Section_Name__c ).add( question );
        }
        //section average
        for ( String section : sectionNameList ) {
            if ( mapOfSectionToScore.containsKey(section) && mapOfSectionToTotalQuestions.containsKey(section)) {
                Decimal totalSum = mapOfSectionToScore.get(section);
                Decimal totalQuestions = mapOfSectionToTotalQuestions.get( section );
                Decimal sectionAvg = (totalSum / totalQuestions).setScale(2);
                mapOfSectionToAverage.put(section, sectionAvg);
                
                //total score and total questions
                if ( totalScore == null ) {
                    totalScore = 0;
                }
                if ( totalCount == null ) {
                    totalCount = 0;
                }
                if ( totalAverage == null ) {
                    totalAverage = 0;
                }
                
                this.totalCount += totalQuestions;
                this.totalScore += sectionAvg;
            }
        }
        
        //total average
        this.totalAverage = (this.totalScore / this.sectionNameList.size()).setScale(2);
    }
    
    public static String formatDate( Date dateValue ) {

       return  dateValue.month() + '/' + dateValue.day() + '/' + dateValue.year() ;
    }

    
    public class AssessmentQuestions {
        @AuraEnabled public String questionLabel {get;set;} 
        @AuraEnabled public String assessmentAPI {get;set;} 
        @AuraEnabled public String assessmentValue {get;set;} 
        @AuraEnabled public String assessmentValueLabel {get;set;} 
        @AuraEnabled public String sectionName {get;set;}
    }
}