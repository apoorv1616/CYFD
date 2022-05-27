public class NM_CYFD_ConfigurationItemTriggerHandler {
    
    public static void divideActivities(List<Contract_Configuration_Line_Item__c> newList){
        List<Contract_Configuration_Line_Item__c> itemList = new List<Contract_Configuration_Line_Item__c>();
        Map<Id,Contract_Configuration_Line_Item__c> itemMap = new Map<Id,Contract_Configuration_Line_Item__c>();
        Id recordTypeId = NM_CYFD_Utility.getRecordTypeId('CYFD_Activity__c','Deliverable');
        Map<Id,Id> mapItemToActivity = new Map<Id,Id>();
        Map<Id,Id> mapActivityToType = new Map<Id,Id>();
        for(Contract_Configuration_Line_Item__c item : newList)
        {
            mapItemToActivity.put(item.Id,item.CYFD_Activity__c);
        }
        for(CYFD_Activity__c activity : [SELECT Id,RecordTypeId, Active__c 
                                         FROM CYFD_Activity__c 
                                         WHERE Id IN : mapItemToActivity.values()]){
            mapActivityToType.put(activity.Id, activity.RecordTypeId);
        }
        for(Contract_Configuration_Line_Item__c item :newList)
        {
            if(mapActivityToType.get(mapItemToActivity.get(item.Id)) == recordTypeId)
             {
                system.debug('id'+recordTypeId);
                itemList.add(item);
                itemMap.put(item.Id,item);
             }
        }
        createContractActivities(itemList,itemMap);
    }
    public static void createContractActivities(List<Contract_Configuration_Line_Item__c> newList,Map<Id,Contract_Configuration_Line_Item__c> newMap)
    {
        List<Contract_Activity__c> activityList = new List<Contract_Activity__c>();
        Map<Id,Contract_Configuration__c> itemIdToConfiguration = new Map<Id,Contract_Configuration__c>();
        Map<Id,List<Contract__c>> configurationIdToContracts = new Map<Id,List<Contract__c>>();
        Set<Id> configurationId = new Set<Id>(); //Use set instead of List
        for(Contract_Configuration_Line_Item__c item:newList){
            if(item.Contract_Configuration__c != null)
                configurationId.add(item.Contract_Configuration__c);
        }
       
        if(!configurationId.isEmpty()){  
            for(Contract__c contract:[SELECT Id,Contract_Configuration__c FROM Contract__c WHERE Contract_Configuration__c IN : configurationId]){
            if(!configurationIdToContracts.containsKey(contract.Contract_Configuration__c)){
                configurationIdToContracts.put(contract.Contract_Configuration__c,new List<Contract__c>());
            }
            configurationIdToContracts.get(contract.Contract_Configuration__c).add(contract);
        }
        for(Contract_Configuration_Line_Item__c item:newList){
            
            if(configurationIdToContracts.containsKey(item.Contract_Configuration__c)){
                for(Contract__c contract : configurationIdToContracts.get(item.Contract_Configuration__c) ){
                    Contract_Activity__c activity = new Contract_Activity__c();
                    activity.Contract_Configuration__c = item.Contract_Configuration__c;
                    activity.CYFD_Activity__c = item.CYFD_Activity__c;
                    activity.Contract_Configuration_Line_Item__c = item.Id;
                   
                    activity.Contract__c = contract.Id;
                    activity.Status__c = 'Pending';
                    activity.RecordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Activity__c','Deliverable');
                    activityList.add(activity);
               }
            }
        }
        if(activityList.size()>0){
            try {
	            insert activityList;
            }
            catch(Exception e) {
                String message = e.getMessage();
                String validationMessage = throwValidationErrors(message);
                String err = validationMessage != null ? validationMessage : message;
                newList[0].addError(err);
            }
        }
        }
        
    }
    
    public static String throwValidationErrors(String message) {
        if(message.containsIgnoreCase('FIELD_CUSTOM_VALIDATION_EXCEPTION,')) {
           message = message.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1];
           if(message.contains(':')) {
              message = message.split(':')[0];
           }
        }
        
        return message;
    }

}