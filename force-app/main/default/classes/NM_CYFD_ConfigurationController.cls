public without sharing class NM_CYFD_ConfigurationController{


    @AuraEnabled
    public static Map<String, Object> getCYFDActivities(String contractConfigId){
         List<CYFDActivityWrapper> deliverables = new List<CYFDActivityWrapper>(); 
         List<CYFDActivityWrapper> billables = new List<CYFDActivityWrapper>();
         Map<String, Object> response = new Map<String, Object>();
         
        /* Set<Id> existingActivities = new Set<Id>();
         
         for(Contract_Configuration_Line_Item__c li : [SELECT CYFD_Activity__c FROM Contract_Configuration_Line_Item__c 
                                                         WHERE Contract_Configuration__c =: contractConfigId]){
                existingActivities.add(li.CYFD_Activity__c);                                         
         }*/
         
         for(CYFD_Activity__c activity : 
             	[SELECT Id, Activity_Label__c, Status__c, Activity_Rate__c, 
                 Activity_Type__c, RecordType.developerName,Active__c
                 FROM CYFD_Activity__c
                 WHERE Active__c = true
                 ORDER BY Activity_Label__c]){
                     
                CYFDActivityWrapper activityWrapper = new CYFDActivityWrapper();
                activityWrapper.id = activity.Id;
                activityWrapper.activityLabel = activity.Activity_Label__c;
                activityWrapper.rate = activity.Activity_Rate__c;
                activityWrapper.type = activity.Activity_Type__c;
                activityWrapper.contractConfigId = contractConfigId;
                activityWrapper.selected = false;
              if(activity.RecordType.developerName == 'Billable_Activity'){
                  billables.add(activityWrapper);
              }else{
                  activityWrapper.status = activity.Status__c;
                  deliverables.add(activityWrapper);
              }
         }
         response.put('billables',billables);        
         response.put('deliverables',deliverables);  
         return response;       
    }
    
    
    @AuraEnabled
    public static Boolean createContractCongifLineitems(String activitiesJSON){
        system.debug('line.activitiesactivitiesJSON ' + activitiesJSON);
        List<CYFDActivityWrapper> activities = (List<CYFDActivityWrapper>)JSON.deserialize(activitiesJSON, List<CYFDActivityWrapper>.class); 
        List< Contract_Configuration_Line_Item__c> lineItems = new List< Contract_Configuration_Line_Item__c>();
        for(CYFDActivityWrapper act : activities){
            Contract_Configuration_Line_Item__c lineItem = new Contract_Configuration_Line_Item__c();
            lineItem.Contract_Configuration__c = act.contractConfigId;
            lineItem.CYFD_Activity__c = act.id;
            lineItems.add(lineItem);
        }
        system.debug('line.activities ' + activities);
        system.debug('line. ' + lineItems);
        if(!lineItems.isEmpty()){
            insert lineItems;
            return true;
        }
        return false;
            
    }

    public class CYFDActivityWrapper{
        @AuraEnabled public String id;
        @AuraEnabled public String contractConfigId;
        @AuraEnabled public String activityLabel;
        @AuraEnabled public Decimal rate;
        @AuraEnabled public String type;
        @AuraEnabled public String status;
        @AuraEnabled public Date activityDate;
        @AuraEnabled public String recordTypeId;
        @AuraEnabled public Boolean selected;              
    }


}