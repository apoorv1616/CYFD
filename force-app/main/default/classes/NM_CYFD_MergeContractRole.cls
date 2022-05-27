public without sharing class NM_CYFD_MergeContractRole {
    
    private static String keyToIdentifyDuplicateContractRole( Contract_Role__c roleRecord ) {
        
        return roleRecord.First_Name__c + '#' + roleRecord.Last_Name__c + '#' + roleRecord.Contract_Role__c + '#' + roleRecord.Date_of_Birth__c;
    }
    
    private static String getAllFieldsOfContractRole() {
        
        List<String>apiNames =  new list<String>();
        Schema.DescribeSObjectResult r = Contract_Role__c.sObjectType.getDescribe();

        for(string apiName : r.fields.getMap().keySet()){
            apiNames.add(apiName);
        }
        
        return String.join(apiNames, ',');
    }
	
    public static void mergeContractRole() {
        
        Set<String> firstNameSet = new Set<String>();
        Set<String> lastNameSet = new Set<String>();
        Set<String> roleTypeSet = new Set<String>();
        Set<Date> dateOfBirthSet = new Set<Date>();
        
        Map<String, List<Contract_Role__c>> mapOfKeyToListOfContractRoles = new Map<String, List<Contract_Role__c>>();
		List<Database.MergeResult> mergeContractRoleList = new List<Database.MergeResult>();
        
       	for ( AggregateResult aggr : 
                [SELECT count(id) duplicateCount,First_Name__c,Last_Name__c,Contract_Role__c,Date_of_Birth__c 
                 FROM Contract_Role__c GROUP BY First_Name__c, Last_Name__c,Contract_Role__c, Date_of_Birth__c 
                 HAVING COUNT(id) > 1 and contract_role__c = 'Staff']) {
                     
                String firstName = (String)aggr.get('First_Name__c');
                String lastName = (String)aggr.get('Last_Name__c');
                String roleType = (String)aggr.get('Contract_Role__c');
                Date dateOfBirth = (Date)aggr.get('Date_of_Birth__c');
                     
                if ( firstName != null ) {
                     firstNameSet.add( firstName );    
                }
                if ( lastName != null ) {
                     lastNameSet.add( lastName );    
                }
                if ( roleType != null ) {
                     roleTypeSet.add( roleType );    
                }
                if ( dateOfBirth != null ) {
                     dateOfBirthSet.add( dateOfBirth );    
                }          
        }
        
        if ( !firstNameSet.isEmpty() || !lastNameSet.isEmpty() || !roleTypeSet.isEmpty() || !dateOfBirthSet.isEmpty() ) {
            
            String contractRoleFields = getAllFieldsOfContractRole();
            
            String query = ' SELECT ' 
                		 + contractRoleFields 
                		 + ' FROM Contract_Role__c '
                		 + ' WHERE contract_role__c = \'Staff\' '
                		 + ' AND (First_Name__c IN :firstNameSet '
                		 + ' OR Last_Name__c IN :lastNameSet '
                		 + ' OR Contract_Role__c IN :roleTypeSet '
                		 + ' OR Date_of_Birth__c IN :dateOfBirthSet) '
            			 + ' ORDER By CreatedDate ';
            
            for ( Contract_Role__c roleRecord : Database.query(query) ) {
                
                String key = keyToIdentifyDuplicateContractRole( roleRecord );
                
                if ( !mapOfKeyToListOfContractRoles.containsKey( key ) ) {
                    
                    mapOfKeyToListOfContractRoles.put( key, new List<Contract_Role__c>() );
                }
                mapOfKeyToListOfContractRoles.get( key ).add( roleRecord );
            }
            
            for ( String key : mapOfKeyToListOfContractRoles.keySet() ) {
                
                List<Contract_Role__c> contractRoleList = mapOfKeyToListOfContractRoles.get( key );
                
                if ( !contractRoleList.isEmpty() && contractRoleList.size() > 1 ) {
                    
                    Contract_Role__c masterContractRole = contractRoleList[0];
                    contractRoleList.remove(0);
					
                    // No Bulk method exist for merge.
					Database.merge(masterContractRole, contractRoleList);
                }
            }

        }
    }
}