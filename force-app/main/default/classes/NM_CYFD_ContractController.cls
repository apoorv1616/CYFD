public without sharing class NM_CYFD_ContractController {
      
    
    @AuraEnabled
    public static Contract__c getContractRecord(String contractId){
        List<Contract__c> contracts = [SELECT Account__c,Account__r.Name,Contract_Configuration__c,Contract_Configuration__r.Name, Address__c, Amount__c, 
       City__c, Contract_Name__c, Name__c, Contract_Number__c, End_Date__c, Grant__c, PO_Number__c FROM Contract__c WHERE Id =: contractId];
        if(!contracts.isEmpty())
            return contracts[0];
        return null;
    }
   
    //Method used to update the contract activity status to Submitted once the document is uploaded from Manage Deliverables page.
    @AuraEnabled 
    public static Contract_Activity__c updateContractActivityStatus(String activityId,String status){
        Contract_Activity__c activity = new Contract_Activity__c();
        activity.Id = activityId;
        activity.Status__c = status;
        try{
            upsert activity;
            return activity;
        }
        catch(Exception e){  System.debug('error '+e);return activity;}
    }
    
    @AuraEnabled 
    public static Map<String,List<Object>> getContractActivities(String contractId)
    {
        Map<String,List<Object>> response = new Map<String,List<Object>> ();
        response.put('Activities',new List<Object>());
        Id recordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Activity__c','Deliverable');

        List<Contract_Activity__c> contractActivities = 
            [SELECT Id,CYFD_Activity__r.Name__c,Status__c,RecordTypeId,
                (SELECT Id,ContentDocument.Title,ContentDocument.LastModifiedDate,ContentDocument.FileExtension 
                FROM ContentDocumentLinks ORDER BY ContentDocument.LastModifiedDate 
                DESC 
                LIMIT 1)  
            FROM Contract_Activity__c
            WHERE Contract__c =: ContractId
            ORDER BY CYFD_Activity__r.Name__c ];

        System.debug('contract Activities '+ contractActivities);
        if(!contractActivities.isEmpty()){
            for(Contract_Activity__c activity : contractActivities)
            {
                if(activity.RecordTypeId == recordTypeId)
                {
                    ContractActivityWrapper activityWrapper = new ContractActivityWrapper();
                    activityWrapper.activityName = activity.CYFD_Activity__r.Name__c;
                    activityWrapper.activityId = activity.Id;
                    activityWrapper.Status = activity.Status__c;
                    if(!activity.ContentDocumentLinks.isEmpty())
                        activityWrapper.docName = activity.ContentDocumentLinks[0].ContentDocument.Title + '.' + activity.ContentDocumentLinks[0].ContentDocument.FileExtension;
                    response.get('Activities').add(activityWrapper);
                }
            }
        }
        return response;
    }
    
       public class ContractActivityWrapper{
        @AuraEnabled public String activityName;
        @AuraEnabled public String docName;
        @AuraEnabled public String Status;
        @AuraEnabled public String activityId;
        @AuraEnabled public String activityLabel;
        @AuraEnabled public Decimal rate;
        
    }
}