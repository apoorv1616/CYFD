public class NM_CYFD_SubmitAssessmentController{

    @AuraEnabled
    public static Boolean  submitAssessment(String assessmentJSON, String stepNumber, String assessmentId,String saveAndExit){
        
        try{
            Assessment__c assessment = new Assessment__c(Id = assessmentId);
            NM_CYFD_AssessmentWrapper assessmentWrapper = (NM_CYFD_AssessmentWrapper)JSON.deserialize(assessmentJSON, NM_CYFD_AssessmentWrapper.class);
            // if(stepNumber == '1'){
            //     assessment = assessmentWrapper.savePermanancy(assessment);
            //     assessment.Status__c = 'In Progress';
            // }
            if(stepNumber == '1'){
                assessment = assessmentWrapper.saveDailyLiving(assessment);
            }
            else if(stepNumber == '2'){
                assessment = assessmentWrapper.saveSelfCare(assessment);
            }
            else if(stepNumber == '3'){
                assessment = assessmentWrapper.saveRelations(assessment);
            }
            else if(stepNumber == '4'){
                assessment = assessmentWrapper.saveHousing(assessment);
            }
            else if(stepNumber == '5'){
                assessment = assessmentWrapper.saveWorkAndStudy(assessment);
            }
            else if(stepNumber == '6'){
                assessment = assessmentWrapper.saveCareerAndEducation(assessment);
            }
            else if(stepNumber == '7'){
                assessment = assessmentWrapper.saveLookingForward(assessment);
                if(saveAndExit == 'false'){
                    assessment.Status__c = 'Completed';
                    assessment.Completion_Date__c = System.today();
                }
                    
                    
            }
            // if(saveAndExit == 'false'){
                List<Assessment__c> assessmnetList =[ SELECT Id,Steps_Completed__c FROM  Assessment__c WHERE Id =: assessmentId]; 
                if(assessmnetList[0].Steps_Completed__c < Integer.valueOf(stepNumber)){
                    assessment.Steps_Completed__c = Integer.valueOf(stepNumber);
                }
                if(assessmnetList[0].Steps_Completed__c == NULL){
                    assessment.Steps_Completed__c = Integer.valueOf(stepNumber);
                }
            // }
            update assessment;
            return true;
        }
        catch(Exception e){
            return false;
            
        }
    }
    
    @AuraEnabled
    public static NM_CYFD_AssessmentWrapper getAssessment(String assessmentId, String stepNumber){
        NM_CYFD_AssessmentWrapper assessmentwrapper = new NM_CYFD_AssessmentWrapper();
        List<Assessment__c> assessmentList = new List<Assessment__c>();
        
        // Get all fields 
        Schema.DescribeSObjectResult r = Assessment__c.sObjectType.getDescribe();
         List<String>apiNames =  new list<String>();
         for(string apiName : r.fields.getMap().keySet()){
            apiNames.add(apiName);
         }
         String fieldList = String.join(apiNames, ',');
        System.debug(apiNames + '  ' + fieldList);
        String query = 'SELECT ' + fieldList + ' FROM Assessment__c  WHERE Id = : assessmentId';
        
        assessmentList = Database.query(query);
        System.debug('assessment '+ assessmentList[0]);
        // if(stepNumber == '2'){
        //    assessmentwrapper.getPermanancy(assessmentList[0], false);
        // }
        if(stepNumber == '2'){
           assessmentwrapper.getDailyLiving(assessmentList[0], false);
        }
        else if(stepNumber == '3'){
           assessmentwrapper.getSelfCare(assessmentList[0], false);
        }
        else if(stepNumber == '4'){
           assessmentwrapper.getRelations(assessmentList[0], false);
        }
        else if(stepNumber == '5'){
           assessmentwrapper.getHousing(assessmentList[0], false);
        }
        else if(stepNumber == '6'){
           assessmentwrapper.getWorkAndStudy(assessmentList[0], false);
        }
        else if(stepNumber == '7'){
           assessmentwrapper.getCareerAndEducation(assessmentList[0], false);
        }
        else if(stepNumber == '8'){
           assessmentwrapper.getLookingForward(assessmentList[0], false);
        }
        system.debug('wrapper '+assessmentwrapper);
         return assessmentwrapper;
        
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
    public static Map<String, Object>  getYouthDataForAssessment(String contractId, String searchKey, String assessmentType, String action){
        Map<String, Object> response = new Map<String, Object>();
        List<Contract__c> contracts =[SELECT Account__c, Grant__c FROM Contract__c WHERE Id =: contractId LIMIT 1];
        
        List<String> filters = new List<String>();
        if(String.isNotBlank(action))
            filters = action.split('-');
         system.debug('action *** ' + action);
        
        String accountId = contracts[0].Account__c ;
        String query = 'SELECT Id, Name__c, (SELECT Id, Steps_Completed__c, Status__c, Assessment_Type__c FROM Assessments__r ORDER BY LastModifiedDate DESC LIMIT 1) ';
        query += 'FROM Contract_Role__c WHERE Account__c =: accountId AND RecordType.Name != \'Provider\'' ;
        if(String.isNotBlank(searchKey)){
            String searchInput ='\'%' + searchKey  + '%\'';
            query += ' AND Name__c LIKE ' + searchInput;
        }
        query += ' ORDER BY Name__c';
        
                                                
        List<Contract_Role__c> contractRoles = Database.query(query);                                   
        List<YouthSelectionWrapper> youths = new List<YouthSelectionWrapper>();
        
        for(Contract_Role__c cr : contractRoles){
           YouthSelectionWrapper youth = new YouthSelectionWrapper(); 
            youth.youthId = cr.Id;
            youth.name = cr.Name__c;
            
            if(cr.Assessments__r.isEmpty()){
               
                youth.status = 'Not Started';
                youth.assessmentType = 'None';
                youth.stepsCompleted = '0 of 7';
                youth.lastCompletedStep = 0;
                youth.action = 'Start Initial Assessment';
            }
            else{
                String status = cr.Assessments__r[0].Status__c;
                String type = cr.Assessments__r[0].Assessment_Type__c;
                youth.status = status;
                youth.assessmentType = type;
                youth.stepsCompleted = cr.Assessments__r[0].Steps_Completed__c + ' of 7';
                youth.lastCompletedStep = Integer.valueOf(cr.Assessments__r[0].Steps_Completed__c);
                youth.assessmentId = cr.Assessments__r[0].Id;
                
                if(type == 'Initial Assessment'){
                    if(status == 'Completed'){
                        youth.assessmentId = '';
                        youth.action = 'Start Discharge Assessment';
                    }else if(status == 'Not Started'){
                        youth.action = 'Start Initial Assessment';
                    }else if(status == 'In Progress'){
                        youth.action = 'Continue Initial Assessment';
                    }
                }
                if(type == 'Discharge Assessment'){
                    if(status == 'Completed'){
                        youth.action = 'None';
                    }else if(status == 'Not Started'){
                        youth.action = 'Start Discharge Assessment';
                    }else if(status == 'In Progress'){
                        youth.action = 'Continue Discharge Assessment';
                    }
                }
            }
            
            
           // if(String.isNotBlank(action) && (youth.status != filters[0] || youth.assessmentType != filters[1]))
             //       continue;
                    
            if(String.isNotBlank(action) && (youth.action != action))
                    continue;
            
            if(String.isNotBlank(assessmentType) && youth.assessmentType != assessmentType)
                continue;
                
            youths.add(youth);   
        }
        response.put('grant', contracts[0].Grant__c);
        response.put('youths', youths);
        return response;
        
    }
    
    @AuraEnabled public static String getStatus(String assessmentId){
        List<Assessment__c> assessmentList = [SELECT Id,Status__c FROM Assessment__c WHERE Id =:assessmentId LIMIT 1 ];
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
        @AuraEnabled public String stepsCompleted;
        @AuraEnabled public Integer lastCompletedStep;
        @AuraEnabled public String action;
            
    }

}