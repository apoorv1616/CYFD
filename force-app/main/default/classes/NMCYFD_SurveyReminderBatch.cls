/*
	 * Author : Apoorv Anand
	 * Issue  : I-97886
	 * Desc   : set a reminder to send/complete surveys after 6 or 9 months 
*/ 
public without sharing class NMCYFD_SurveyReminderBatch implements Schedulable, Database.Batchable<sObject> {
	
    public String surveyName;
    public static String COMPLETED_STATUS = 'Completed';
    public static String SET_REMINDER_MONTH = '6';
    
    public void NMCYFD_SurveyReminderBatch( String surveyName ) {
        
        if ( String.isNotBlank( surveyName ) ) {
            
            this.surveyName = surveyName;
        } 
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = ' SELECT Id, Contract_Role__c, Contract_Role__r.Program_Completion_Date__c '
            		 + ' FROM Survey__c '
            		 + ' WHERE Status__c != :COMPLETED_STATUS '
            		 + ' AND Contract_Role__c != null '
        			 + ' AND Contract_Role__r.Program_Completion_Date__c <= LAST_N_MONTHS:' + SET_REMINDER_MONTH;
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Survey__c> scope) {
        
        for ( Survey__c surveyRecord : scope ) {
            
        }        
    }
    
    public void finish(Database.BatchableContext BC) {}
    
    public void execute(SchedulableContext scon) {
     	Database.executeBatch( new NMCYFD_SurveyReminderBatch() );
   	}
    
}