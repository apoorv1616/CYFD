public without sharing class NmcyfdCloneCCController {
    
    @AuraEnabled
    public static Contract_Configuration__c getPreviousConfiguration( String recordId ) {

        if ( String.isNotBlank(recordId) ) {
            
            List<Contract_Configuration__c> configList = 
                [SELECT Id, OwnerId, Name__c, External_ID__c  
                 FROM Contract_Configuration__c
                 WHERE Id = :recordId ];
            
            if (!configList.isEmpty()) {
                return configList[0];
            }
        }
        return null;
    }
    
    private static Contract_Configuration__c createNewConfiguration( Contract_Configuration__c configRecord,Boolean isInsert ) {
        
        Contract_Configuration__c newConfigRecord = new Contract_Configuration__c();
        newConfigRecord.Name__c = configRecord.Name__c;
        newConfigRecord.External_ID__c = configRecord.External_ID__c;
        
        if (isInsert) {
        	insert newConfigRecord;
        }
        
        return newConfigRecord;
    }
    
    private static List<Contract_Configuration_Line_Item__c> cloneConfigurationLineItem( Contract_Configuration__c newConfigRecord, String recordId,  Boolean isInsert ) {
        
        List<Contract_Configuration_Line_Item__c> configLLList = new List<Contract_Configuration_Line_Item__c>();
        List<String>apiNames =  new list<String>();
        Schema.DescribeSObjectResult r = Contract_Configuration_Line_Item__c.sObjectType.getDescribe();

        for(string apiName : r.fields.getMap().keySet()){
            apiNames.add(apiName);
        }
        
        String fieldList = String.join(apiNames, ',');
        
        String query = ' SELECT ' + fieldList + ' FROM Contract_Configuration_Line_Item__c WHERE Contract_Configuration__c = :recordId '; 
        
        for (Contract_Configuration_Line_Item__c config : Database.query(query) ) {
            
            Contract_Configuration_Line_Item__c clonedConfig  = config.clone(false, false, false, false);  
            clonedConfig.Contract_Configuration__c = newConfigRecord.Id;
            clonedConfig.External_ID__c = null;
            configLLList.add( clonedConfig );
        }
        
        if ( !configLLList.isEmpty() && isInsert ) {
            insert configLLList;
        }
        return configLLList;
    }
	
    @AuraEnabled
    public static String saveContractConfiguration( String recordId, String wrapperData ) {
        //try {
            
            if ( String.isNotBlank(recordId) && String.isNotBlank(wrapperData) ) {
                
                Contract_Configuration__c configRecord = (Contract_Configuration__c) JSON.deserialize(wrapperData, Contract_Configuration__c.class);
                
                if (String.isNotBlank(configRecord.External_Id__c)) {
                    List<Contract_Configuration__c> existingConfigWithSameExternalIdList = 
                        [SELECT Id, External_Id__c, Name
                         FROM Contract_Configuration__c
                         WHERE External_Id__c = :configRecord.External_Id__c];
                    
                    if (!existingConfigWithSameExternalIdList.isEmpty()) {
                        throw new duplicateExternalIdException( 'External Id already exists on contract '+ existingConfigWithSameExternalIdList[0].Name);
                    }
                }
                
                
                Contract_Configuration__c newConfigRecord = createNewConfiguration( configRecord, false );
                insert newConfigRecord;
               
                List<Contract_Configuration_Line_Item__c> configLLList = cloneConfigurationLineItem( newConfigRecord, recordId, false );
                
                if ( !configLLList.isEmpty() ) {
                    
                    insert configLLList;
                }
                return newConfigRecord.Id;
            }
        //}
        /*catch( Exception err ) {

            throw new AuraHandledException( err.getMessage() );
        } */
        return null;
    }
    
    public class duplicateExternalIdException extends Exception {}
}