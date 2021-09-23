public with sharing class NM_CYFD_ContractTriggerHandler {
     /*
    *   Method is used to track all method calls on after Insert
    *  This method takes input of List of Cases
    */
    public static void afterInsert(List<Contract__c> newList){
        createContractActivities(newList,null);
     }
    public static void afterUpdate(List<Contract__c> newList, Map<Id, Contract__c> oldMap){
        createContractActivities(newList,oldMap);
     }
     
    public static void createContractActivities(List<Contract__c> newList, Map<Id,Contract__c> oldMap){
        Set<Id> contractConfigIdSet = new Set<Id>();
        Map<Id,List<Contract_Configuration_Line_Item__c>> contractConfigToLineItemMap = new Map<Id,List<Contract_Configuration_Line_Item__c>>();
        List<Contract_Activity__c> contractActivityList = new List<Contract_Activity__c>();
        
        for(Contract__c c: newList) {
            /*
             * Author : Apoorv Anand 
             * Desc   : Added oldMap == null for insert criteria
             * Issue  : I-53802
            */
            if((oldMap == null && c.Contract_Configuration__c != null) 
               || (oldMap != null && c.Contract_Configuration__c != oldMap.get(c.Id).Contract_Configuration__c)){
                contractConfigIdSet.add(c.Contract_Configuration__c);
            }
        }
        for(Contract_Configuration_Line_Item__c contractConfigLIRec: [SELECT Id, Name, CYFD_Activity__c,CYFD_Activity__r.RecordTypeId, Contract_Configuration__c 
                                                                      FROM Contract_Configuration_Line_Item__c
                                                                      WHERE Contract_Configuration__c IN: contractConfigIdSet]){
                                                                          if(contractConfigLIRec.CYFD_Activity__c != null && contractConfigLIRec.CYFD_Activity__r.RecordTypeId != null 
                                                                          && contractConfigLIRec.CYFD_Activity__r.RecordTypeId == NM_CYFD_Utility.getRecordTypeId('CYFD_Activity__c', 'Deliverable') 
                                                                          && contractConfigLIRec.Contract_Configuration__c != null){
                                                                              if(!contractConfigToLineItemMap.containsKey(contractConfigLIRec.Contract_Configuration__c)){
                                                                                  contractConfigToLineItemMap.put(contractConfigLIRec.Contract_Configuration__c, new List<Contract_Configuration_Line_Item__c>());                                                                            
                                                                                }
                                                                                    System.debug('contractConfigToLineItemMap--> '+ contractConfigToLineItemMap);
                                                                              contractConfigToLineItemMap.get(contractConfigLIRec.Contract_Configuration__c).add(contractConfigLIRec);
                                                                          
                                                                        }
                                                                      }
        
        System.debug('contractConfigToLineItemMap--> '+ contractConfigToLineItemMap);
        for(Contract__c contractRecord: newList){
            if(contractConfigToLineItemMap != null && contractConfigToLineItemMap.containsKey(contractRecord.Contract_Configuration__c)){
                
                for(Contract_Configuration_Line_Item__c configItemListRec : contractConfigToLineItemMap.get(contractRecord.Contract_Configuration__c)){
                Contract_Activity__c contractActivityRec = new Contract_Activity__c();
                contractActivityRec.Contract__c = contractRecord.Id;
                contractActivityRec.Contract_Configuration__c = contractRecord.Contract_Configuration__c;
                contractActivityRec.Contract_Configuration_Line_Item__c = configItemListRec.Id;
                contractActivityRec.CYFD_Activity__c  = configItemListRec.CYFD_Activity__c;
                contractActivityRec.Status__c = 'Pending';
                contractActivityRec.RecordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Activity__c', 'Deliverable');
                contractActivityList.add(contractActivityRec);
            }
            
            }
            
        }
        if(contractActivityList != null && !contractActivityList.isEmpty()){
            try {
                //System.assert(false, contractActivityList);
                insert contractActivityList;
            }
            catch(exception e) {
                /*
                 * Author : Apoorv Anand 
                 * Desc   : If error comes then show on screen
                 * Issue  : I-53802
                */
                String message = e.getMessage();
                String validationMessage = NM_CYFD_ConfigurationItemTriggerHandler.throwValidationErrors(message);
                String err = validationMessage != null ? validationMessage : message;

                //Don't allow insert of the duplicate record but then don't throw error on update.
                if ( !Trigger.isUpdate )
                    newList[0].addError(err);
            }
            
        }
        
    }
}