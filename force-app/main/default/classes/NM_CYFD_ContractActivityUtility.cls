public without sharing class NM_CYFD_ContractActivityUtility implements Queueable {

	String subContractor;
    Date activityDate;
    String contractId;
    List<Contract_Activity__c> contractActivities;
    
    Boolean isUpdate = false;

    public NM_CYFD_ContractActivityUtility(String subContractor, Date activityDate, String contractId) {
        this.subContractor = subContractor;
        this.activityDate = activityDate;
        this.contractId = contractId;
        
        Integer month = activityDate.month();
        Integer year = activityDate.year();
        
         List<Contract_Activity__c> contractActivities = [SELECT Id, Invoice_Amount__c, Sub_Contract_Expenditure_Amount__c, Sub_Contractor__c, Date__c, 
            Activity_Expenditure_Amount__c, Contract__c, (SELECT Id, Minimum_Unit__c , Units__c , Activity_Amount__c , Contract_Role__c, 
            Contract_activity__c FROM Activity_Roles__r WHERE RecordType.Name = 'Clients' 
            AND CALENDAR_MONTH(Contract_Activity__r.Date__c) =: month
            AND CALENDAR_YEAR(Contract_Activity__r.Date__c) =: year ) 
            FROM Contract_Activity__c WHERE Contract__c =: contractId];
        this.contractActivities = contractActivities;
    }
    
    
    public void execute(QueueableContext context) {
        if(!isUpdate)
	        updateMentoringActivityAmounts(this.subContractor, this.activityDate, this.contractId, this.contractActivities);
    } 
    
    public static void updateMentoringActivityAmounts(String subContractor, Date activityDate, String contractId, List<Contract_Activity__c> contractActivities){

        Map<Id, Decimal> contractRoleToUnitsMap = new Map<Id, Decimal>();
        Map<Id, List<Activity_Role__c>> contractRoleIdToActivityRolesMap = new Map<Id, List<Activity_Role__c>>();
        Map<Id, Decimal> contractRoleToMinimumUnitsMap = new Map<Id, Decimal>();
        Map<Id, Contract_activity__c> caMap = new Map<Id, Contract_Activity__c>();
        Integer month = activityDate.month();
        Integer year = activityDate.year();
        List<Activity_Role__c> activityRolesNew = new List<Activity_Role__c>();
        Set<Id> contractActivityIds = new Set<Id>();
        Set<Id> contractActivityIdSet = new Set<Id>();
        List<Activity_Role__c> activityRoles = new  List<Activity_Role__c>();
        
        for(Contract_Activity__c ca : contractActivities){
            if(!ca.Activity_Roles__r.isEmpty() || Test.isRunningTest()){
                 activityRoles.addAll(ca.Activity_Roles__r);  
                 contractActivityIdSet.add(ca.Id);     
            }        
        }
        
        for(Activity_Role__c ar : activityRoles){
            contractActivityIds.add(ar.Contract_Activity__c);
            
            if(!contractRoleIdToActivityRolesMap.containsKey(ar.Contract_Role__c))
                    contractRoleIdToActivityRolesMap.put(ar.Contract_Role__c, new List<Activity_Role__c>());
                contractRoleIdToActivityRolesMap.get(ar.Contract_Role__c).add(ar);
                
                if(!contractRoleToUnitsMap.containsKey(ar.Contract_Role__c))
                  contractRoleToUnitsMap.put(ar.Contract_Role__c, 0.0);
                contractRoleToUnitsMap.put(ar.Contract_Role__c, contractRoleToUnitsMap.get(ar.Contract_Role__c) + ar.Units__c);
              
               contractRoleToMinimumUnitsMap.put(ar.Contract_Role__c,ar.Minimum_Unit__c);
        }

        for(Id crId : contractRoleToUnitsMap.keySet()){
            if(contractRoleToUnitsMap.get(crId) >= contractRoleToMinimumUnitsMap.get(crId)){
               activityRolesNew.addAll(contractRoleIdToActivityRolesMap.get(crId)); 
            }
        }
        
        
        Decimal activityExpAmt = 0.0;
        Decimal subContractorExpAmt = 0.0;
        
        for(Activity_Role__c ar : activityRolesNew ){
        
            contractActivityIds.add(ar.Contract_Activity__c);
            if(!caMap.containsKey(ar.Contract_Activity__c)){
                caMap.put(ar.Contract_Activity__c, new Contract_Activity__c(Id  = ar.Contract_Activity__c, 
                                                    Invoice_Amount__c = ar.Activity_Amount__c, Mentoring_Units__c = ar.Units__c));

            }else{
                Contract_Activity__c ca = caMap.get(ar.Contract_Activity__c);
                ca.Invoice_Amount__c += ar.Activity_Amount__c;
                ca.Mentoring_Units__c += ar.Units__c;
                caMap.put(ar.Contract_Activity__c, ca);
            }
        }
        
        for(Id i : contractActivityIdSet){
            Contract_Activity__c ca = new Contract_Activity__c(Id = i);
                ca.Invoice_Amount__c = 0 ;
                ca.Mentoring_Units__c = 0 ;
            if(!caMap.containsKey(i)){
                caMap.put(i, ca);
            }
        }
        
        for(Contract_Activity__c ca : contractActivities){
            Decimal invAmt = caMap.containskey(ca.Id) ? caMap.get(ca.Id).Invoice_Amount__c : ca.Invoice_Amount__c;
            
            activityExpAmt += invAmt;
            if(ca.Sub_Contractor__c != null && ca.Sub_Contractor__c == subContractor){
                subContractorExpAmt += invAmt;
            }
        }

        for(Contract_Activity__c ca : contractActivities){
            if(caMap.containskey(ca.Id)){
                ca.Invoice_Amount__c = caMap.get(ca.Id).Invoice_Amount__c;
                ca.Mentoring_Units__c = caMap.get(ca.Id).Mentoring_Units__c;
            }
            
            ca.Activity_Expenditure_Amount__c = activityExpAmt;
            if(ca.Sub_Contractor__c != null && ca.Sub_Contractor__c == subContractor){
                ca.Sub_Contract_Expenditure_Amount__c = subContractorExpAmt;
            }
        }
        
        NM_CYFD_ContractActivityTriggerHandler.stopDeletion = true;
        //update contractActivities;
        updateContractActivity(contractActivities);
    }
    
    public static void updateContractActivity(List<Contract_Activity__c> contractActivityList) {
        List<Contract_Activity__c> updateList = new List<Contract_Activity__c>();
        
        //size is default to 8000.
		Integer sizeToBeUpdated = Integer.valueOf(Label.NM_CYFD_UpdateListLimit); 
        
        if(!contractActivityList.isEmpty()) {
            //size less than 8000.
            if(contractActivityList.size() < sizeToBeUpdated) {
            	update contractActivityList;
            }
            //size greater than 8000.
       		else {
                for(Integer index=0; index<sizeToBeUpdated; index++) {
                	updateList.add(contractActivityList[index]); 
                }
                update updateList;
                
                //1. convert list to set.
                Set<Contract_Activity__c> updateCASet = new Set<Contract_Activity__c>(contractActivityList);
                
                //2. remove updatedList from set.
                Boolean isUpdatedListRemoved = updateCASet.removeAll(updateList);
                
                //3. convert set back to list.
                contractActivityList = new List<Contract_Activity__c>(updateCASet);
                
                //4. Recurssion.
                if(isUpdatedListRemoved)
	                updateContractActivity(contractActivityList);
            }
        }
    }
    
    
    public static void updateExpenditureAmounts(String label, String program, String subContractor, Date activityDate, String contractId){
    
        List<Contract_Activity__c> contractActivities = [SELECT Id, Activity_Label__c, Invoice_Amount__c, Sub_Contract_Expenditure_Amount__c, Sub_Contractor__c, Date__c, 
            Activity_Expenditure_Amount__c, Contract__c , Program_Expenditure_Amount__c , PRogram__c FROM Contract_Activity__c WHERE Contract__c =: contractId 
            AND RecordType.DeveloperName = 'Billable_Activity' AND Invoice_Amount__C != null];
           
            Decimal activityExpAmt = 0.0;
            Decimal subContractorExpAmt = 0.0;
            Decimal programExpAmt = 0.0;
            system.debug('program *** ' + program + ' label ** ' + label);
            for(Contract_Activity__c ca : contractActivities ){
                if(String.isNotBlank(label) && ca.Activity_Label__c == label )
                    activityExpAmt += ca.Invoice_Amount__C;
                    system.debug('ca.PRogram__c  ' + ca.PRogram__c );
                if(String.isNotBlank(program) && ca.PRogram__c != null && ca.PRogram__c == program)
                    programExpAmt += ca.Invoice_Amount__C;
                    
                if(String.isNotBlank(subContractor) && ca.Sub_Contractor__c != null && ca.Sub_Contractor__c == subContractor)
                    subContractorExpAmt += ca.Invoice_Amount__C;
            }
            
            for(Contract_Activity__c ca : contractActivities){
                 if(String.isNotBlank(label) && ca.Activity_Label__c == label)
                    ca.Activity_Expenditure_Amount__c = activityExpAmt;
                    
                 if(String.isNotBlank(program) && ca.PRogram__c == program)
                    ca.Program_Expenditure_Amount__c = programExpAmt;
                    
                 if(String.isNotBlank(subContractor) && ca.Sub_Contractor__c == subContractor)
                    ca.Sub_Contract_Expenditure_Amount__c = subContractorExpAmt;
            }
            
            if(!contractActivities.isEmpty())
                update contractActivities;
    }

 
}