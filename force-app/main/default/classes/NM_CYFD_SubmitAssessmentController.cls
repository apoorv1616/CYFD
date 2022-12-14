public without sharing class NM_CYFD_SubmitAssessmentController{

    @AuraEnabled
    public static Boolean  submitAssessment(String assessmentJSON, Integer stepNumber, String assessmentId,String saveAndExit){
        
        try{
            // Assessment__c assessment = new Assessment__c(Id = assessmentId);
            // NM_CYFD_AssessmentWrapper assessmentWrapper = (NM_CYFD_AssessmentWrapper)JSON.deserialize(assessmentJSON, NM_CYFD_AssessmentWrapper.class);
            // // if(stepNumber == '1'){
            // //     assessment = assessmentWrapper.savePermanancy(assessment);
            // //     assessment.Status__c = 'In Progress';
            // // }
            // if(stepNumber == '1'){
            //     assessment = assessmentWrapper.saveDailyLiving(assessment);
            // }
            // else if(stepNumber == '2'){
            //     assessment = assessmentWrapper.saveSelfCare(assessment);
            // }
            // else if(stepNumber == '3'){
            //     assessment = assessmentWrapper.saveRelations(assessment);
            // }
            // else if(stepNumber == '4'){
            //     assessment = assessmentWrapper.saveHousing(assessment);
            // }
            // else if(stepNumber == '5'){
            //     assessment = assessmentWrapper.saveWorkAndStudy(assessment);
            // }
            // else if(stepNumber == '6'){
            //     assessment = assessmentWrapper.saveCareerAndEducation(assessment);
            // }
            // else if(stepNumber == '7'){
            //     assessment = assessmentWrapper.saveLookingForward(assessment);
            //     if(saveAndExit == 'false'){
            //         assessment.Status__c = 'Completed';
            //         assessment.Completion_Date__c = System.today();
            //     }
                    
                    
            // }

            Assessment_2022__c assessment = (Assessment_2022__c)JSON.deserialize(assessmentJSON, Assessment_2022__c.class);
            assessment.Id = assessmentId;
            List<Assessment_2022__c> assessmnetList = 
                [ SELECT Id,Steps_Completed__c 
                FROM  Assessment_2022__c 
                WHERE Id =: assessmentId]; 

            assessment.Steps_Completed__c = assessmnetList[0].Steps_Completed__c > stepNumber ? assessmnetList[0].Steps_Completed__c : stepNumber;
            assessment.Status__c = 'In Progress';

            if ( assessment.Steps_Completed__c == 9 ) {
                assessment.Status__c = 'Completed';
                assessment.Completion_Date__c = System.today();
            }

            update assessment;
            return true;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage()  + '  ' + e.getStackTraceString());
            
        }
    }
    
    @AuraEnabled
    public static Assessment_2022__c getAssessment(String assessmentId, Integer stepNumber){
        NM_CYFD_AssessmentWrapper assessmentwrapper = new NM_CYFD_AssessmentWrapper();
        // List<Assessment__c> assessmentList = new List<Assessment__c>();
        
        // // Get all fields 
        // Schema.DescribeSObjectResult r = Assessment__c.sObjectType.getDescribe();
        //  List<String>apiNames =  new list<String>();
        //  for(string apiName : r.fields.getMap().keySet()){
        //     apiNames.add(apiName);
        //  }
        //  String fieldList = String.join(apiNames, ',');
        // System.debug(apiNames + '  ' + fieldList);
        // String query = 'SELECT ' + fieldList + ' FROM Assessment__c  WHERE Id = : assessmentId';
        // if(stepNumber == '2'){
        //    assessmentwrapper.getPermanancy(assessmentList[0], false);
        // }
        // if(stepNumber == '2'){
        //    assessmentwrapper.getDailyLiving(assessmentList[0], false);
        // }
        // else if(stepNumber == '3'){
        //    assessmentwrapper.getSelfCare(assessmentList[0], false);
        // }
        // else if(stepNumber == '4'){
        //    assessmentwrapper.getRelations(assessmentList[0], false);
        // }
        // else if(stepNumber == '5'){
        //    assessmentwrapper.getHousing(assessmentList[0], false);
        // }
        // else if(stepNumber == '6'){
        //    assessmentwrapper.getWorkAndStudy(assessmentList[0], false);
        // }
        // else if(stepNumber == '7'){
        //    assessmentwrapper.getCareerAndEducation(assessmentList[0], false);
        // }
        // else if(stepNumber == '8'){
        //    assessmentwrapper.getLookingForward(assessmentList[0], false);
        // }
        // system.debug('wrapper '+assessmentwrapper);
        //  return assessmentwrapper;

        List<Assessment_2022__c> assessmentList = new List<Assessment_2022__c>();
        
        // Get all fields 
        Schema.DescribeSObjectResult obj = Assessment_2022__c.sObjectType.getDescribe();
         List<String>apiNames =  new list<String>();
         for(string apiName : obj.fields.getMap().keySet()){
            apiNames.add(apiName);
         }
         String fieldList = String.join(apiNames, ',');
        String query = 'SELECT ' + fieldList + ' FROM Assessment_2022__c  WHERE Id = : assessmentId ';
        
        assessmentList = Database.query(query);

        if ( !assessmentList.isEmpty() ) {
            return assessmentList[0];
        }
        
        return null;
    }
    
    @AuraEnabled
    public static Map<String, Object> startAssessment(String contractId, String youthId, String assessmentType){
        Map<String, Object> response = new Map<String, Object>();
        // Assessment__c assessment = new Assessment__c(Contract__c = contractId, Contract_Role__c = youthId, Status__c='Not Started', Assessment_Type__c = assessmentType, Steps_Completed__c =0);
        // insert assessment;

        Assessment_2022__c assessment = new Assessment_2022__c(Contract__c = contractId, Contract_Role__c = youthId, Status__c='Not Started', Assessment_Type__c = assessmentType, Steps_Completed__c =0);
        insert assessment;

        response.put('assessmentId', assessment.Id);
        return response;
        
    }
    
    @AuraEnabled
    public static Map<String, Object>  getYouthDataForAssessment(String contractId, String searchKey, String assessmentType, String action){
        Map<String, Object> response = new Map<String, Object>();
        List<Contract__c> contracts =[SELECT Account__c, Grant__c FROM Contract__c WHERE Id =: contractId LIMIT 1];
        
        List<String> filters = new List<String>();
        if(String.isNotBlank(action))
            filters = action.split('-');
        
        String accountId = contracts[0].Account__c ;

        String query = ' SELECT Id, Name__c, '
                     + ' (SELECT Id, Steps_Completed__c, Status__c, Assessment_Type__c FROM Assessments_2022__r ORDER BY LastModifiedDate DESC LIMIT 1), '
                     + ' (SELECT Id, Steps_Completed__c, Status__c, Assessment_Type__c FROM Assessments__r WHERE Assessment_Type__c = \'Initial Assessment\' ORDER BY LastModifiedDate DESC LIMIT 1) '
                     + ' FROM Contract_Role__c ' 
                     + ' WHERE Account__c =: accountId '
                     + ' AND RecordType.Name != \'Provider\' ';

        if(String.isNotBlank(searchKey)){
            String searchInput ='\'%' + searchKey  + '%\'';
            query += ' AND Name__c LIKE ' + searchInput;
        }
        query += ' ORDER BY Name__c';
        
                                                
        List<Contract_Role__c> contractRoles = Database.query( query );  
        
        Set<Id> contractRoleWithDischargeAssessment = new Set<Id>();
        
        for ( Assessment__c assessmentRecord : 
             	[SELECT Id, Contract_Role__c 
                 FROM Assessment__c 
                 WHERE Assessment_Type__c = 'Discharge Assessment'
                 AND Status__c = 'Completed' ]) {
           
                  contractRoleWithDischargeAssessment.add( assessmentRecord.Contract_Role__c );
        }

        List<YouthSelectionWrapper> youths = new List<YouthSelectionWrapper>();
        
        for(Contract_Role__c cr : contractRoles){
            YouthSelectionWrapper youth = new YouthSelectionWrapper(); 
            youth.youthId = cr.Id;
            youth.name = cr.Name__c;
            
            if( cr.Assessments_2022__r.isEmpty() ){
               	if ( contractRoleWithDischargeAssessment.contains( cr.Id ) ) {
                    youth.action = 'None';
                    youth.status = 'Completed';
                    youth.assessmentType = 'Discharge Assessment';
                    youth.stepsCompleted = 9;
                    youth.lastCompletedStep = 9;
                }
                else {
                    youth.status = 'Not Started';
                    youth.assessmentType = !cr.Assessments__r.isEmpty() && cr.Assessments__r[0].Status__c == 'Completed' ? 'Initial Assessment': 'None';
                    youth.stepsCompleted = 0;
                    youth.lastCompletedStep = 0;
                    youth.action = !cr.Assessments__r.isEmpty() && cr.Assessments__r[0].Status__c == 'Completed' ? 'Start Discharge Assessment' : 'Start Initial Assessment';
                }
                
            }
            else {
                String status = cr.Assessments_2022__r[0].Status__c;
                String oldAssessmentStatus = !cr.Assessments__r.isEmpty() && cr.Assessments__r[0] != null  ? cr.Assessments__r[0].Status__c : null;
                String type = cr.Assessments_2022__r[0].Assessment_Type__c;
                String oldAssessmentType =  !cr.Assessments__r.isEmpty() && cr.Assessments__r[0] != null  ?  cr.Assessments__r[0].Assessment_Type__c : null;

                youth.status = status;
                youth.assessmentType = type;
                youth.stepsCompleted = Integer.valueOf( cr.Assessments_2022__r[0].Steps_Completed__c );
                youth.lastCompletedStep = Integer.valueOf( cr.Assessments_2022__r[0].Steps_Completed__c );
                youth.assessmentId = cr.Assessments_2022__r[0].Id;
                
                if(type == 'Initial Assessment'){
                    if(status == 'Completed'){
                        youth.assessmentId = '';
                        youth.action = 'Start Discharge Assessment';
                    }else if(status == 'Not Started'){
                        youth.action = oldAssessmentStatus == 'Completed' && oldAssessmentType == 'Initial Assessment' ? 'Start Discharge Assessment' : 'Start Initial Assessment';
                    }else if(status == 'In Progress'){
                        youth.action = 'Continue Initial Assessment';
                    }
                }
                else if(type == 'Discharge Assessment'){
                    if(status == 'Completed'){
                        youth.action = 'None';
                    }else if(status == 'Not Started'){
                        youth.action = 'Start Discharge Assessment';
                    }else if(status == 'In Progress'){
                        youth.action = 'Continue Discharge Assessment';
                    }
                }
            }
            
            if ( (String.isNotBlank( action ) && ( youth.action != action ))
               	|| String.isNotBlank( assessmentType ) && youth.assessmentType != assessmentType) {
                continue;
            }
                
            youths.add(youth);   
        }
        response.put('grant', contracts[0].Grant__c);
        response.put('youths', youths);
        return response;
        
    }
    
    @AuraEnabled public static String getStatus(String assessmentId){
        List<Assessment_2022__c> assessmentList = [SELECT Id,Status__c FROM Assessment_2022__c WHERE Id =:assessmentId LIMIT 1 ];
        if(!assessmentList.isEmpty()){
            return  assessmentList[0].Status__c;
        }
        return null;
    }
    
    public class YouthSelectionWrapper{
        
        @AuraEnabled public String youthId;
        @AuraEnabled public String assessmentId;
        @AuraEnabled public String name;
        @AuraEnabled public String assessmentType;
        @AuraEnabled public String status;
        @AuraEnabled public Integer stepsCompleted;
        @AuraEnabled public Integer lastCompletedStep;
        @AuraEnabled public String action;
            
    }

}