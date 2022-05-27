public without sharing class NM_CYFD_ActivityRoleTriggerHandler {

    public static Boolean bulkUpdate = Label.nmcyfdBulkUpdateExpenditure == 'true';
    
    /*
        @author : Apoorv Anand
        @desc   : Create a way to count number of unique youths
                : (after insert, after update, after delete)
        @Issue  : I-96306
    */
    public static void countNumberOfYouthsOnContract( List<Activity_Role__c> newList, Map<Id, Activity_Role__c> oldMap ) {
        
        List<Activity_Role__c> activityRoleNewList = new List<Activity_Role__c>();
        Set<Id> alreadyProcessedContractRole = new Set<Id>();
        
        if( newList != null && (oldMap == null || bulkUpdate)) 
            activityRoleNewList = newList;
        
        else if(newList == null && oldMap != null ) 
            activityRoleNewList = oldMap.values(); 
        
        Set<Id> contractIdSet = new Set<Id>();
        Map<String, Integer> mapOfContractIdToCountOfYouths = new Map<String, Integer>();
        Map<Id, Contract__c> mapOfContractIdToContract = new Map<Id, Contract__c>();
        
        for ( Activity_Role__c activityRoleRecord : activityRoleNewList ) {
            if ( activityRoleRecord.Contract__c != null 
                && activityRoleRecord.Contract_Role__c != null) {
                	
                  contractIdSet.add( activityRoleRecord.Contract__c );  
             }
        }
        
        if ( !contractIdSet.isEmpty() ) {

            for ( Activity_Role__c activityRoleRecord : [SELECT Id, Contract_Role__c,Contract_Role__r.Name__c, Contract__c 
                                                         FROM Activity_Role__c 
                                                         WHERE RecordTypeId = :NM_CYFD_Constants.NM_CLIENTS_ACTIVITY_ROLE_RECORDTYPEID 
                                                         AND Contract__c IN :contractIdSet ]) {
                                                             
                 if ( !alreadyProcessedContractRole.contains( activityRoleRecord.Contract_Role__c )) {                                            
                     if ( !mapOfContractIdToCountOfYouths.containsKey(activityRoleRecord.Contract__c )) {
                         
                         mapOfContractIdToCountOfYouths.put( activityRoleRecord.Contract__c, 0 );
                     }
                     Integer count = mapOfContractIdToCountOfYouths.get( activityRoleRecord.Contract__c ) + 1;                                      
                     mapOfContractIdToCountOfYouths.put( activityRoleRecord.Contract__c, count);
                     
                     alreadyProcessedContractRole.add( activityRoleRecord.Contract_Role__c );
                 }
            }
            //System.assert(false, new List<String>(mapOfContractIdToCountOfYouths.keySet())[ + ' ' + mapOfContractIdToCountOfYouths.values()[0]);
            for ( Activity_Role__c activityRoleRecord : activityRoleNewList ) {
      
                if ( mapOfContractIdToCountOfYouths.containsKey( activityRoleRecord.Contract__c ) ) {
                    Contract__c contractRecord = new Contract__c();
                    contractRecord.Id = activityRoleRecord.Contract__c;
                    contractRecord.Number_of_Youths__c = mapOfContractIdToCountOfYouths.get( activityRoleRecord.Contract__c );
                    mapOfContractIdToContract.put( contractRecord.Id, contractRecord );
                }
            }
            
            if ( !mapOfContractIdToContract.isEmpty() ) {
                NM_CYFD_WithoutSharingCtrl.updateSObjectList( mapOfContractIdToContract.values() );
            } 
        }
    }
    
    /*
        @author : Apoorv Anand
        @desc   : to update invoice amount on mentoring grant and check minimum 2 units criteria.
                : (after insert, after delete)
                : Added as a part of architecture change
    */
    public static void updateContractActivityAmountForMentoring ( List<Activity_Role__c> newList, Map<Id, Activity_Role__c> oldMap ) {
        
        List<Activity_Role__c> activityRoleNewList = new List<Activity_Role__c>();
        Map<String, Date> contractIdToActivityDateMap = new Map<String, Date>();
        Set<Id> contractIdSet = new Set<Id>();
        Map<String, Decimal> contractRoleToUnitsMap = new Map<String, Decimal>();
        Map<Id, Contract_Activity__c> contractActivityIdToCAMap = new Map<Id, Contract_Activity__c>();
        Set<Integer> monthList = new Set<Integer>();
        Set<Integer> yearList = new Set<Integer>();
        Map<String, Integer> mapOfCAtoContractRoleCount = new Map<String, Integer>();
        Map<String, List<String>> mapOfContractRoleToListOfCAId = new Map<String, List<String>>();
		Map<String, Decimal> mapOfActivityIdToUnit = new Map<String, Decimal>();
		
        if( newList != null && (oldMap == null || bulkUpdate)) 
            activityRoleNewList = newList;
        
        else if(newList == null && oldMap != null ) 
            activityRoleNewList = oldMap.values();    

        
        if (!activityRoleNewList.isEmpty()) {
            for ( Activity_Role__c activityRoleRecord : activityRoleNewList ) {
                if ( activityRoleRecord.Activity_Date__c != null ) {
                    
                    contractIdToActivityDateMap.put( activityRoleRecord.Contract__c, activityRoleRecord.Activity_Date__c );
                    monthList.add( activityRoleRecord.Activity_Date__c.month() );
                    yearList.add( activityRoleRecord.Activity_Date__c.year() );

                }
            }
           
            if ( !contractIdToActivityDateMap.isEmpty() && !monthList.isEmpty() && !yearList.isEmpty() ) {
				//System.assert(false, contractIdToActivityDateMap);
                List<Activity_Role__c> activityRoleList = new List<Activity_Role__c>();
                
                for ( Activity_Role__c activityRoleRecord : 
                    [SELECT Id, Minimum_Unit__c, Units__c, Activity_Amount__c, Contract_Role__c, Activity_Date__c, Contract__c,
                     Contract_activity__c, Contract_activity__r.Id, Contract_activity__r.Invoice_Amount__c, Contract_activity__r.Date__c, 
                     Contract_activity__r.Contract__c, Contract_activity__r.Mentoring_Units__c, Contract_activity__r.Unit__c, Contract_activity__r.Rate__c,
                     Contract_Activity__r.Activity_Label__c, Contract_Activity__r.CYFD_Activity__r.Activity_type__c,Contract_Activity__r.CYFD_Activity__c,
                     Contract_activity__r.Contract__r.Grant__c
                     FROM Activity_Role__c 
                     WHERE Contract__c IN :contractIdToActivityDateMap.keySet()
                     AND RecordTypeId = :NM_CYFD_Utility.CLIENT_RECORDTYPEId
                     //AND Contract_activity__r.Mentoring_Units__c != null
                     	/*AND Contract__c != null
                    	AND Contract_Activity__c != null
                        AND Contract_Activity__r.Contract__r.Grant__c = :NM_CYFD_Utility.MENTORING_GRANT
                     	AND Contract_Activity__r.Contract__r.Grant__c != null
                     	AND RecordTypeId = :NM_CYFD_Utility.CLIENT_RECORDTYPEId
                     	AND Activity_Date__c != null
                        AND CALENDAR_MONTH(Activity_Date__c) IN :monthList
                        AND CALENDAR_YEAR(Activity_Date__c) IN :yearList  
                        ORDER BY Contract_activity__r.Mentoring_Units__c DESC */
                     LIMIT 50000]) {
                         
                      if (activityRoleRecord.Contract_Activity__c != null
                          && activityRoleRecord.Contract_Activity__r.Contract__c != null
                          && activityRoleRecord.Contract_Activity__r.Contract__r.Grant__c == NM_CYFD_Utility.MENTORING_GRANT
                          && activityRoleRecord.Activity_Date__c != null
                          && monthList.contains(activityRoleRecord.Activity_Date__c.month())
                          && yearList.contains(activityRoleRecord.Activity_Date__c.year()) )   {
                             
                              activityRoleList.add( activityRoleRecord );
                              
                              if (activityRoleRecord.Contract_Activity__c != null)
                              	mapOfActivityIdToUnit.put( activityRoleRecord.Contract_Activity__c, activityRoleRecord.Contract_Activity__r.Unit__c);
                              
                       }
                         
                }

                for ( Activity_Role__c activityRoleRecord : activityRoleList) {

                    if ( !mapOfContractRoleToListOfCAId.containsKey( activityRoleRecord.Contract__c + '#' + activityRoleRecord.Contract_Role__c ) ) {
                        mapOfContractRoleToListOfCAId.put( activityRoleRecord.Contract__c + '#' + activityRoleRecord.Contract_Role__c, new List<String>() );
                    }
                    mapOfContractRoleToListOfCAId.get(activityRoleRecord.Contract__c + '#' + activityRoleRecord.Contract_Role__c).add(activityRoleRecord.Contract_Activity__c);
                    
                    if(!contractRoleToUnitsMap.containsKey( activityRoleRecord.Contract__c + '#' + activityRoleRecord.Contract_Role__c ) ) {
                        
                        contractRoleToUnitsMap.put( activityRoleRecord.Contract__c + '#' + activityRoleRecord.Contract_Role__c, 0.0 );
                    }
                    contractRoleToUnitsMap.put( activityRoleRecord.Contract__c + '#' + activityRoleRecord.Contract_Role__c, contractRoleToUnitsMap.get(activityRoleRecord.Contract__c + '#' + activityRoleRecord.Contract_Role__c) + activityRoleRecord.Units__c );

                }

                for ( Activity_Role__c activityRoleRecord : activityRoleList) {

                    if (contractRoleToUnitsMap.get(activityRoleRecord.Contract__c + '#' + activityRoleRecord.Contract_Role__c)  >= activityRoleRecord.Minimum_Unit__c) {

                        if ( !mapOfCAtoContractRoleCount.containsKey( activityRoleRecord.Contract_activity__c ) ) {
                            mapOfCAtoContractRoleCount.put( activityRoleRecord.Contract_activity__c, 0 );
                        }
                        Integer count = mapOfCAtoContractRoleCount.get(activityRoleRecord.Contract_activity__c);
                        count++;
                        mapOfCAtoContractRoleCount.put( activityRoleRecord.Contract_activity__c, count );

                    }
                }
				
                for ( Activity_Role__c activityRoleRecord : activityRoleList ) {
					
                    if ( contractRoleToUnitsMap.containsKey( activityRoleRecord.Contract__c + '#' + activityRoleRecord.Contract_Role__c )
                       && !contractActivityIdToCAMap.containsKey(activityRoleRecord.Contract_Activity__c )) {
                        
                        if ( contractRoleToUnitsMap.get(activityRoleRecord.Contract__c + '#' + activityRoleRecord.Contract_Role__c ) >= activityRoleRecord.Minimum_Unit__c ) {
								
                            if ( mapOfContractRoleToListOfCAId.containsKey(activityRoleRecord.Contract__c + '#' + activityRoleRecord.Contract_Role__c) ) {
                                
                                List<String> activityIdList = mapOfContractRoleToListOfCAId.get(activityRoleRecord.Contract__c + '#' + activityRoleRecord.Contract_Role__c);

                                for (String activityId : activityIdList) {
                                    
                                    Contract_Activity__c contractActivityRecord = new Contract_Activity__c();
                                   
                                    contractActivityRecord.Id = activityId;
                                    contractActivityRecord.Mentoring_Units__c = 0;
                                    
                                    if (activityRoleRecord.Contract_Activity__r.Activity_Label__c != null
                                        && (activityRoleRecord.Contract_Activity__r.Activity_Label__c.contains('Group'))
                                       ) { 
                                           
                                           contractActivityRecord.Mentoring_Units__c =  mapOfCAtoContractRoleCount.get(activityId) * mapOfActivityIdToUnit.get(activityId);
                                    }
                                    else {
                                        contractActivityRecord.Mentoring_Units__c = /*activityRoleRecord.Contract_Activity__r.Unit__c*/ mapOfActivityIdToUnit.get(activityId);
                                    }
                
                                    contractActivityRecord.Invoice_Amount__c = contractActivityRecord.Mentoring_Units__c * activityRoleRecord.Contract_activity__r.Rate__c;
        
                                    contractActivityIdToCAMap.put( contractActivityRecord.Id, contractActivityRecord );
                                }
                            }
                        }
                        else if (!contractActivityIdToCAMap.containsKey(activityRoleRecord.Contract_Activity__c ) ) {
                            
                            Contract_Activity__c contractActivityRecord = new Contract_Activity__c();
                            contractActivityRecord.Id = activityRoleRecord.Contract_Activity__c;
                            contractActivityRecord.Invoice_Amount__c = 0.0;
                            
                            contractActivityRecord.Mentoring_Units__c = contractRoleToUnitsMap.containsKey( activityRoleRecord.Contract__c + '#' + activityRoleRecord.Contract_Role__c ) ?
                                contractRoleToUnitsMap.get( activityRoleRecord.Contract__c + '#' + activityRoleRecord.Contract_Role__c ) : activityRoleRecord.Units__c;
                            
                            contractActivityIdToCAMap.put( contractActivityRecord.Id, contractActivityRecord );
                        }
                    }
                }
            }

            if ( !contractActivityIdToCAMap.isEmpty() )  {
                NM_CYFD_ContractActivityTriggerHandler.stopUpdateExpenditureAmounts = false;
                NM_CYFD_ContractActivityTriggerHandler.isMentoring = true;
               
                update contractActivityIdToCAMap.values();
            }
        }
    } 
    
    /*
        @author : Apoorv Anand
        @desc   : update contract field on activity role.
                : (before insert, before delete)
                : Added as a part of architecture change
    */
    public static void populateContractOnActivityRole( List<Activity_Role__c> newList, Map<Id, Activity_Role__c> oldMap ) {
        
        Set<Id> activityIdSet = new Set<Id>();
        
        for ( Activity_Role__c roleRecord : newList ) {
            
            if ( roleRecord.Contract_Activity__c != null 
                && 
                	(oldMap == null) 
                	|| 
                	(oldMap.get(roleRecord.Id).Contract_Activity__c != roleRecord.Contract_Activity__c)) {
                    
                activityIdSet.add(roleRecord.Contract_Activity__c);   
            }
        }
        
        if ( !activityIdSet.isEmpty() ) {
            
            Map<Id, Contract_Activity__c> mapOfActivityIdToCA = new Map<Id, Contract_Activity__c>([SELECT Id, Contract__c
                                                                                                  FROM Contract_Activity__c
                                                                                                  WHERE Id IN :activityIdSet]);
            if (!mapOfActivityIdToCA.isEmpty()) {
                
                for ( Activity_Role__c roleRecord : newList ) {
                    
                    if (mapOfActivityIdToCA.containsKey(roleRecord.Contract_Activity__c)) {
                        
                        Contract_Activity__c activityRecord = mapOfActivityIdToCA.get(roleRecord.Contract_Activity__c);
                        roleRecord.Contract__c = activityRecord.Contract__c;
                    }
                }
            }
        }
    }

    /*
        Purpose : To update the staff member names from Activity Roles on Contract Activity records.
    */
    public static void updateYouthNamesOnStaffRecords(List<Activity_Role__c> newList, Map<Id, Activity_Role__c> oldMap){    
        Map<Id, String> contractActivityIdToStaffNamesMap = new Map<Id, String>();
        Id staffRecordTypeId = NM_CYFD_Utility.getRecordTypeId('Activity_Role__c','Provider');
        List<Contract_Activity__c> contractActivitiesToUpdate = new List<Contract_Activity__c>();
        List<Id> contractActivityIds = new List<Id>();
        
        for(Activity_Role__c ar : newList){
            if(ar.RecordTypeId  == staffRecordTypeId){               
                contractActivityIds.add(ar.Contract_Activity__c);
            }
        }       
        
        for(Activity_Role__c ar : [SELECT Id, Contract_Activity__c, Contract_Role_Name__c FROM Activity_Role__c WHERE Contract_Activity__c IN: contractActivityIds AND RecordTypeId =: staffRecordTypeId]){
            if(!contractActivityIdToStaffNamesMap.containsKey(ar.Contract_Activity__c))
                contractActivityIdToStaffNamesMap.put(ar.Contract_Activity__c, '');
            contractActivityIdToStaffNamesMap.put(ar.Contract_Activity__c, contractActivityIdToStaffNamesMap.get(ar.Contract_Activity__c) +  ar.Contract_Role_Name__c +  ', ');
        }  
        
        system.debug('contractActivityIdToStaffNamesMap ' + contractActivityIdToStaffNamesMap);
        
        for(String contractId : contractActivityIdToStaffNamesMap.keySet()){
            String staffNames = contractActivityIdToStaffNamesMap.get(contractId);
            staffNames = staffNames.removeEnd(', ');
            Contract_Activity__c ca = new Contract_Activity__c();
            ca.Id = contractId;
            ca.Staff_Name__c = staffNames;
            contractActivitiesToUpdate.add(ca);
                
        }
        
        if(!contractActivitiesToUpdate.isEmpty())
           update contractActivitiesToUpdate; 
       
    }
}