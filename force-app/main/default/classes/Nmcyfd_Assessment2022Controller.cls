public with sharing class Nmcyfd_Assessment2022Controller {
	
    @AuraEnabled
    public static List<Assessment_2022_Questions__mdt> getAllAssessmentQuestions() {
        
        List<Assessment_2022_Questions__mdt> questionsList = getQuestions();

        return questionsList;
    }
    
    private static List<Assessment_2022_Questions__mdt> getQuestions() {
        
		return [SELECT Id,Label, Question_Sequence__c, Section_Name__c, Questions_Label__c, Assement_API__c, 
                Active__c 
                FROM Assessment_2022_Questions__mdt
                WHERE Active__c = TRUE
                ORDER BY Question_Sequence__c 
               ];
    }
}