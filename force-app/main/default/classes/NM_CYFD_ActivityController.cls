public without sharing class NM_CYFD_ActivityController {
    /*public static Id ACTIVITY_EXPENDITURE_RECORDTYPE = NM_CYFD_Utility.ACTIVITY_EXPENDITURE_RECORDTYPE;
    public static Id PROGRAM_EXPENDITURE_RECORDTYPE = NM_CYFD_Utility.PROGRAM_EXPENDITURE_RECORDTYPE;
    public static Id SUBCONTRACTOR_EXPENDITURE_RECORDTYPE = NM_CYFD_Utility.SUBCONTRACTOR_EXPENDITURE_RECORDTYPE;*/
    
    @AuraEnabled
    public static Map<String, Object> getInitialDetails(String contractId){
        Map<String, Object> response = new Map<String, Object>();
        //response.put('subContractor', false);
        List<NM_CYFD_Utility.SelectOptionWrapper> activityDetailValues = NM_CYFD_Utility.fetchPicklist('Contract_Activity__c', 'Activity_Detail__c');
        
        List<Contract__c> contracts = [SELECT Account__c,Account__r.Name,Contract_Configuration__c,Contract_Configuration__r.Name, Address__c, Amount__c, Total_Invoice_Amount__c,
         City__c, Name__c, Contract_Number__c, Start_Date__c,End_Date__c, Grant__c, PO_Number__c FROM Contract__c WHERE Id =: contractId ];
        List<Period> fiscalYears = [SELECT FiscalYearSettings.Name, StartDate, EndDate FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY LIMIT 1];
        
        // System.assert(false, contracts);
        response = getUserDetails();
        if(!contracts.isEmpty()){
            response.put('contract', contracts[0]);
            response.put('activityDetailValues', activityDetailValues);
        }
        if(!fiscalYears.isEmpty()){
            response.put('fiscalStartDate', fiscalYears[0].StartDate);
        }
            
        return response;
    }
    
    private static Map<String, Object> getUserDetails(){
        Map<String, Object> response = new Map<String, Object>();
        //String myProflieName = '';
        List<PermissionSetAssignment> psa = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, 
            Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Sub_Contractor_Permission_Set' AND AssigneeId =: userinfo.getUserId() ];
        
      /*  List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        if(profiles[0].Name == 'JCC Community User')
             myProflieName= 'JCC';
        else if(profiles[0].Name == 'JJAC Community User')
             myProflieName= 'JJAC';
        else if(profiles[0].Name == 'Mentoring Community User')
             myProflieName= 'Mentoring';
      
        response.put('profile', myProflieName);*/
        response.put('subContractor', false);
        if(!psa.isEmpty()){
            response.put('subContractor', true);
        }
        return response;
    }
    
    @AuraEnabled 
    public static List<ContractRoleWrapper> getExistingMembers(String type, String contractId, String activityLabel, String searchKey, List<String> selectedIds){ 
         
         List<ContractRoleWrapper> members = new List<ContractRoleWrapper>();
         List<String> types = new List<String>{'JCC Client', 'JJAC Client', 'Mentoring Client'};
             
         List<Contract__c> contracts = [SELECT Account__c FROM Contract__c WHERE Id =: contractId LIMIT 1];
        
         //Get all fields of Contract Role Object
         Schema.DescribeSObjectResult r = Contract_Role__c.sObjectType.getDescribe();
         List<String>apiNames =  new list<String>();
         for(string apiName : r.fields.getMap().keySet()){
            apiNames.add(apiName);
         }
         String fieldList = String.join(apiNames, ',');
       // String query = 'SELECT ' + fieldList + ' FROM Contract_Role__c ORDER BY FIRST_name__c NULLS LAST, Last_Name__c ASC NULLS LAST';
         String query = 'SELECT ' + fieldList + ' FROM Contract_Role__c WHERE Account__c = \''+ contracts[0].Account__c + '\'';
         
         if(String.isNotBlank(type))
             query += ' AND Contract_Role__c =: type ';
         if(type == 'JCC Client')
             query += ' AND Age__c >= 10 AND Age__c <= 21 ';
         else if(type == 'JJAC Client')
             query += ' AND Age__c >= 9 AND Age__c <= 19 ';
         else if(type == 'Mentoring Client')
             query += ' AND Age__c >= 5 AND Age__c <= 18 ';
       
        if(String.isNotBlank(searchKey)){
            String tempInput ='\'%' + searchKey  + '%\'';
            query += ' AND Name__c LIKE '+tempInput;
        }
        
        
        if(String.isNotBlank(activityLabel)){
            Set<Id> contractRoleIdsToExclude = new Set<Id>();
            Set<Id> contractRoleIdsToInclude = new Set<Id>();
            List<Activity_Role__c> activityRoles = [SELECT Contract_Role__c FROM Activity_Role__c WHERE Contract_Activity__r.Activity_Label__c =: activityLabel ];
            for(Activity_Role__c ar : activityRoles){
                contractRoleIdsToExclude.add(ar.Contract_Role__c);
            }
                        
            if(activityLabel == 'JCC - Initial Casey Life Skills Assessment and Service Plan'){
                for(Assessment__c a : [SELECT Contract_Role__c FROM Assessment__c WHERE Contract_Role__r.Account__c =:contracts[0].Account__c 
                                       AND Status__c = 'Completed' AND Assessment_Type__c  = 'Initial Assessment' ]){
                 contractRoleIdsToInclude.add(a.Contract_Role__c);                          
               }
                    
                
            }else if(activityLabel == 'JCC - Closing Casey Life Skills Assessment and Discharge Plan'){
                for(Assessment__c a : [SELECT Contract_Role__c FROM Assessment__c WHERE Contract_Role__r.Account__c =:contracts[0].Account__c 
                                       AND Status__c = 'Completed' AND Assessment_Type__c  = 'Discharge Assessment']){
                 contractRoleIdsToInclude.add(a.Contract_Role__c);                          
               }
            }
            query += ' AND Id IN:contractRoleIdsToInclude AND Id NOT IN: contractRoleIdsToExclude ';
        }
        
        
         query += ' ORDER BY Name__c ASC';
        //System.assert(false,type);
         for(Contract_Role__c role : Database.query(query)){
             
             ContractRoleWrapper staffWrapper = new ContractRoleWrapper();
             ContractRoleWrapper member = new ContractRoleWrapper();
             if(type == 'staff'){
                  member = staffWrapper.getStaffDetails(role);
             }else if(type.contains('client')){
                  member = staffWrapper.getClientDetails(role);
             }
             member.selected = selectedIds.contains(role.Id) ? true : false;
             members.add(member);
         }
         return members;
    }
   
    
    @AuraEnabled(cacheable = true)
    public static List<ActivityWrapper> findActivityRecords( String searchKey, String contractId, String contractConfigId ){
        
        Id activityRecordTypeId = NM_CYFD_Utility.getRecordTypeId('CYFD_Activity__c', 'Billable Activity');
        List<ActivityWrapper> activityWrapper = new List<ActivityWrapper>();
        
        // String query = 'SELECT Id, CYFD_Activity__c, Sub_Contractor__c, CYFD_Activity__r.Name, CYFD_Activity__r.Activity_Label__c FROM Contract_Configuration_Line_Item__c';
        // query += ' WHERE Contract_Configuration__c = \'' + contractConfigId + '\'';
        // query += ' AND CYFD_Activity__r.RecordTypeId =\'' + activityRecordTypeId + '\'';

        for ( Contract_Configuration_Line_Item__c lineItem : NM_CYFD_WithoutSharingCtrl.getConfigurationLineItemRecords( contractConfigId, activityRecordTypeId ) ) {

            ActivityWrapper activity = new ActivityWrapper();
            activity.activityId = lineItem.CYFD_Activity__c;
            activity.activityLabel = lineItem.CYFD_Activity__r.Activity_Label__c;
            activity.lineItemId = lineItem.Id;
            activity.subContractor = lineItem.Sub_Contractor__c;
            activityWrapper.add(activity);        
            
        }

        return activityWrapper;
    }
    
    
    @AuraEnabled
    public static ActivityWrapper getSelectedActivityDetails(String lineItemId, String contractId){
        
        // String query = 'SELECT Id, CYFD_Activity__c,Program__c, Match_Contribution_Enabled__c , Contract_Configuration__c, CYFD_Activity__r.Activity_Type__c, Activity_Allocated_Amount__c , Sub_Contract_Allocated_Amount__c , Sub_Contractor__c , Program_Allocated_Amount__c, CYFD_Activity__r.Activity_Rate__c, CYFD_Activity__r.Name, CYFD_Activity__r.Activity_Label__c, CYFD_Activity__r.Unit_Type__c, CYFD_Activity__r.Program__c FROM Contract_Configuration_Line_Item__c';
        // query += ' WHERE Id = \'' + lineItemId + '\' LIMIT 1';
        ActivityWrapper activity = new ActivityWrapper();
        List<Contract__c> contractList = new List<Contract__c>();
        
        String BILLABLE_ACTIVITY_RECORDTYPE = NM_CYFD_Utility.BILLABLE_ACTIVITY_RECORDTYPE;
        
        List<Contract_Configuration_Line_Item__c> lineItems = NM_CYFD_WithoutSharingCtrl.getConfigurationLineItemRecordsById( lineItemId );

        if ( !lineItems.isEmpty() ) {
            Contract_Configuration_Line_Item__c lineItem = lineItems[0];
            
            //Get Total Activity Expenditure, Program Expenditure, Sub Contractor Expenditure.
            Decimal totalActivityExpenditure = 0;
            List<AggregateResult> aggSubContractAmt;
            List<AggregateResult> aggProgramAmt;
            List<AggregateResult> aggActivityLabelAmt;
            List< Activity_Unit_Validation__mdt > validations;

            if ( String.isNotBlank(lineItem.Sub_Contractor__c) ) {

                aggSubContractAmt = [SELECT Sum(Amount__c) ,Contract__c,Contract_Configuration_Line_Item__r.Sub_COntractor__c 
                                    FROM Contract_activity__c group By Contract_Configuration_Line_Item__r.Sub_COntractor__c, Contract__c, RecordType.DeveloperName 
                                    HAVING Contract__c =:contractId 
                                    AND Contract_Configuration_Line_Item__r.Sub_COntractor__c =: lineItem.Sub_Contractor__c
                                    AND RecordType.DeveloperName = :BILLABLE_ACTIVITY_RECORDTYPE ];
            }
        
            if ( String.isNotBlank( lineItem.Program__c ) ) {

                aggProgramAmt = [SELECT Sum(Amount__c) ,Contract__c, Program__c 
                                FROM Contract_activity__c group By Program__c, Contract__c, RecordType.DeveloperName
                                HAVING Contract__c =:contractId 
                                AND Program__c =: lineItem.Program__c
                                AND RecordType.DeveloperName = :BILLABLE_ACTIVITY_RECORDTYPE];  
            }
            
            if (String.isNotBlank(lineItem.CYFD_Activity__r.Activity_Label__c )) {

                aggActivityLabelAmt = [SELECT sum(Invoice_Amount__c), Hidden_Activity_Label__c, Contract__c 
                                         FROM Contract_Activity__c  
                                         GROUP BY Hidden_Activity_Label__c,Contract__c, RecordType.DeveloperName
                                         HAVING Contract__c = :contractId
                                         AND Hidden_Activity_Label__c = :lineItem.CYFD_Activity__r.Activity_Label__c 
                                         AND RecordType.DeveloperName = :BILLABLE_ACTIVITY_RECORDTYPE];
            }
            
            if(String.isNotBlank(contractId)) {
                contractList = [SELECT Id, Amount__c, Total_Invoice_Amount__c, Start_Date__c, End_Date__c 
                                FROM Contract__c
                                WHERE Id = :contractId];
            }
            
            activity.activityId = lineItem.CYFD_Activity__c;
            activity.contractId = contractId;
            activity.contractConfigId = lineItem.Contract_Configuration__c;
            activity.matchEnabled = lineItem.Match_Contribution_Enabled__c ;
            activity.name = lineItem.CYFD_Activity__r.Name;
            activity.activityLabel = lineItem.CYFD_Activity__r.Activity_Label__c;
            activity.activityRate = lineItem.CYFD_Activity__r.Activity_Rate__c;
            activity.lineItemId = lineItem.Id;
            activity.activityAllocatedAmt = lineItem.Activity_Allocated_Amount__c;
            activity.programAllocatedAmt = lineItem.Program_Allocated_Amount__c;
            activity.subContractAllocatedAmt = lineItem.Sub_Contract_Allocated_Amount__c;
            activity.program = lineItem.Program__c;
            activity.unitType = lineItem.CYFD_Activity__r.Unit_Type__c;
            activity.activityType = lineItem.CYFD_Activity__r.Activity_Type__c;
            activity.subContractor = lineItem.Sub_Contractor__c;
            //activity.activityExpenditure = totalActivityExpenditure;
            activity.activityExpenditure =  (String.isNotBlank(lineItem.CYFD_Activity__r.Activity_Label__c ) && !aggActivityLabelAmt.isEmpty())? (Double)aggActivityLabelAmt[0].get('expr0') : 0.00;
            activity.programExpenditure = (String.isNotBlank(lineItem.Program__c) && !aggProgramAmt.isEmpty())? (Double)aggProgramAmt[0].get('expr0') : 0.00;
            activity.subContractExpenditure = (String.isNotBlank(lineItem.Sub_Contractor__c) && !aggSubContractAmt.isEmpty()) ? (Double)aggSubContractAmt[0].get('expr0') : 0.00;
            
            activity.awardAmount = contractList.isEmpty() == true ? 0 : contractList[0].Amount__c;
            activity.startDate = contractList.isEmpty() == true ? null : contractList[0].Start_date__c;
            activity.endDate = contractList.isEmpty() == true ? null : contractList[0].End_date__c;
        	activity.totalInvoiceAmount = contractList.isEmpty() == true ? 0 : contractList[0].Total_Invoice_Amount__c;
            System.debug(lineItem.CYFD_Activity__r.Activity_Label__c );

            // System.assert(false, lineItem.CYFD_Activity__r.Activity_Label__c + ' *** ' + lineItem.CYFD_Activity__r.Unit_Type__c);
            if ( String.isNotBlank( lineItem.CYFD_Activity__r.Activity_Label__c ) 
                /*&& String.isNotBlank( lineItem.CYFD_Activity__r.Unit_Type__c )*/ ) {

                    String activityLabel = lineItem.CYFD_Activity__r.Activity_Label__c;
                    String query = 'SELECT Unit_Type__c, Minimum_Youth__c, Youth_Required__c, Amount_Limit__c , Youth_Limit__c , '
                                + ' Multiplied_by_Youth__c, Skip_Staff__c , Limit__c  '
                                + ' FROM Activity_Unit_Validation__mdt '
                                + ' WHERE Activity_Label__c = :activityLabel ' ;
                                // ' AND Unit_Type__c =: lineItem.CYFD_Activity__r.Unit_Type__c '
                                // ' LIMIT 1 ';
                    
                    if ( String.isNotBlank( lineItem.CYFD_Activity__r.Unit_Type__c ) ) {

                        String activityUnitType = lineItem.CYFD_Activity__r.Unit_Type__c;

                        query += ' AND Unit_Type__c =: activityUnitType ';
                    }

                    query += ' LIMIT 1 ';
                    validations = Database.query( query );
            }

            
            // System.assert(false, JSON.serialize(validations));
            
            if( !validations.isEmpty() ){
                activity.validation = true;
                activity.unitsLimit = validations[0].Limit__c;
                activity.amountLimit = validations[0].Amount_Limit__c;
                activity.youthRequired = validations[0].Youth_Required__c;
                activity.youthLimit = validations[0].Youth_Limit__c;
                activity.multipliedByYouth = validations[0].Multiplied_by_Youth__c;
                activity.minimumYouth = validations[0].Minimum_Youth__c;
                activity.skipStaff = validations[0].Skip_Staff__c;
            }
            else
                activity.validation = false;
        }

        return activity;   
    }    
    
    
    @AuraEnabled
    public static Map<String, Object> createContractActivity(String jsonData, Boolean insertAllData){
        Map<String, Object> response = new Map<String, Object>();
        try {
        
            Map<String, Object> userDets = getUserDetails();
            Id activityRecordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Activity__c', 'Billable Activity');
            ContractActivityWrapper contractActivity = (ContractActivityWrapper)JSON.deserialize(jsonData, ContractActivityWrapper.class);
            List<Contract__c> contracts = [
                SELECT Id, Grant__c, Account__c FROM Contract__c WHERE ID =: contractActivity.contractId 
                LIMIT 1
            ];
            // System.assert(false, JSON.serialize(contractActivity ));
            if(!contracts.isEmpty()){
                
                Decimal programExpenditure = contractActivity.programExpenditure;
                Decimal activityExpenditure = contractActivity.activityExpenditure; 
                Decimal subContractExpenditure = contractActivity.subContractExpenditure;
                String contractId = contractActivity.contractId;
                String providerId = contracts[0].Account__c;
                String grant = contracts[0].Grant__c;
                String program = contractActivity.program;
                String configLineItem = contractActivity.lineItemId;
                String subContractor = contractActivity.subContractor;
                
                            //logic for not allowing the user to have total amount more than 500 for a client for Financial Assisstance Activities
                if(contractActivity.activityLabel == 'JCC - Financial Assistance'){
                    List<Id> roleIds = new List<Id>();
                    Map<Id, Decimal> roleToAmountMap = new Map<id, Decimal>();
                    Boolean flag = false;
                    
                    for(ContractRoleWrapper ar : contractActivity.clients){
                        if(ar.roleId != null)
                            roleIds.add(ar.roleId);
                    }
                    
                    for(Activity_role__c ar : [SELECT Id, Contract_Role__c, Contract_Activity__r.Amount__c FROM Activity_role__c WHERE Contract_Activity__r.Contract__c=: contractId 
                    AND Contract_Activity__r.Activity_Label__c = 'JCC - Financial Assistance' AND Contract_Role__c IN: roleIds ]){
                        if(!roleToAmountMap.containsKey(ar.Contract_Role__c)){
                            roleToAmountMap.put(ar.Contract_Role__c, 0.00);
                        }
                        Decimal amount = roleToAmountMap.get(ar.Contract_Role__c) + ar.Contract_Activity__r.Amount__c;
                        roleToAmountMap.put(ar.Contract_Role__c, amount);
                        if((amount + contractActivity.amount)  > 500){
                            flag = true;
                            break;
                        }                         
                    }               
                
                    if(flag){
                    //Database.rollback(sp);
                        response.put('success', false);
                        response.put('msg','One client cannot have more than $500 on one contract');
                        return response; 
                    }               
                }
                
                
                Contract_Activity__c ca = new Contract_Activity__c();
                if(contractActivity.contractActivityId != null){
                    ca.Id = contractActivity.contractActivityId;            
                }else{
                    ca.Contract__c = contractActivity.contractId;
                }
                
                ca.Contract_Configuration__c = contractActivity.contractConfigId;
                ca.Contract_Configuration_Line_Item__c = contractActivity.lineItemId;
                ca.CYFD_Activity__c = contractActivity.activityId;
                ca.Unit__c = contractActivity.units;
                ca.Activity_Expenditure_Amount__c = contractActivity.activityExpenditure;
                ca.Program_Expenditure_Amount__c = contractActivity.programExpenditure ;
                ca.Sub_Contract_Expenditure_Amount__c = contractActivity.subContractExpenditure;
                ca.Program__c = contractActivity.program;
                ca.Status__c = insertAllData? 'Submitted' : 'Pending';
                ca.Date__c = contractActivity.activityDate;
                ca.RecordTypeId = activityRecordTypeId;
                ca.Activity_Detail__c = contractActivity.activityDetail;
                ca.Number_of_Youth__c = contractActivity.numberOfYouth;
                ca.Mulitplied_by_Number_of_Youth__c = contractActivity.multipliedByYouth != null ? contractActivity.multipliedByYouth : false;
                if(grant != 'Mentoring'){
                    ca.Invoice_Amount__c = contractActivity.amount;
                }else{
                    ca.Invoice_Amount__c = 0.0;
                }
                //ca.Invoice_Amount__c = contractActivity.amount;
                if(contractActivity.matchEnabled){
                    ca.Match_Amount__c = contractActivity.matchAmount;
                    ca.Match__c = true;
                }
                
                if ( grant == 'Mentoring' ) {
                    NM_CYFD_ContractActivityTriggerHandler.stopUpdateExpenditureAmounts = true;
                }
                
                //upsert ca;
                if (insertAllData)
                    NM_CYFD_ContractActivityTriggerHandler.stopUpdateExpenditureAmounts = true;
                ca = (Contract_Activity__c)NM_CYFD_WithoutSharingCtrl.upsertObject(ca);
                
                Savepoint sp = Database.setSavepoint();                                     
                
                if(insertAllData){
                    
                    List<Activity_Role__c> activityRoles = new List< Activity_Role__c>();
                    List<Contract_Role__c> contractRoles = new List< Contract_Role__c>();
                    List<Contract_Role__c> contractRolesForActivityRoles = new List< Contract_Role__c>();
                    
                    for(ContractRoleWrapper ar : contractActivity.staffs){
                        Contract_Role__c cr = ar.createStaff(ar);
                        if(cr.Id == null)
                            cr.Account__c = providerId;
                        
                        if(ar.isNewActivityRole == null || !ar.isNewActivityRole)
                            contractRolesForActivityRoles.add(cr);
                        contractRoles.add(cr);
                    }
                        
                    for(ContractRoleWrapper ar : contractActivity.clients){
                        Contract_Role__c cr = ar.createClient(ar, contracts[0].Grant__c);
                        if(cr.Id == null)
                        cr.Account__c = providerId;
                        contractRoles.add(cr);
                        if(ar.isNewActivityRole == null || !ar.isNewActivityRole)
                            contractRolesForActivityRoles.add(cr);
                    }
                
                    if(!contractRoles.isEmpty()) {
                        //upsert contractRoles;  
                        NM_CYFD_WithoutSharingCtrl.upsertSObjectList(contractRoles);
                    }
                
                    for(Contract_Role__c cr : contractRolesForActivityRoles){
                        Activity_Role__c role = new Activity_Role__c();
                        role.Contract_Activity__c = ca.Id;
                        role.Contract_Role__c = cr.Id; 
                        role.recordTypeId = cr.Contract_Role__c.contains('Client') ? NM_CYFD_Utility.getRecordTypeId('Activity_Role__c','Clients') : NM_CYFD_Utility.getRecordTypeId('Activity_Role__c','Provider');
                        activityRoles.add(role);   
                    }
                    
                    if(!activityRoles.isEmpty()) {
                        //NM_CYFD_ContractActivityTriggerHandler.stopUpdateExpenditureAmounts = false;
                        //insert activityRoles;
                        NM_CYFD_WithoutSharingCtrl.insertSObjectList(activityRoles);
                    }
            
                }
                response.put('contractActivityId', ca.Id);
                contractActivity.contractActivityId = ca.Id;
                response.put('contractActivity', contractActivity);
                response.put('success', true);
                return response;
                
            }

            return null;
        }
        catch(Exception e) {
            response.put('success', false);
            response.put('msg', e.getMessage());
            return response; 
        }
    }
    
    
    @AuraEnabled 
    public static Boolean checkDuplicateContractRole(String type, String contractId, String name, Date dob, String roleId){
        List<Contract__c> contracts = [SELECT Account__c FROM Contract__c WHERE Id =: contractId LIMIT 1];
        String newSearchText = '%'+type+'%';
        Integer count = 0;
        for(Contract_Role__c cr : [SELECT Id, Name__c, Date_of_Birth__c FROM Contract_Role__c WHERE Contract_Role__c LIKE : newSearchText AND Account__c = : contracts[0].Account__c]){
            if(((String.isNotBlank(roleId)&& roleId != cr.Id) || String.isBlank(roleId)) && cr.Name__c == name && cr.Date_of_Birth__c == dob){
                return true;
            } 
            
        }
       return false;
    }
    
    @AuraEnabled
    public static void deleteDocument(Id documentId){
        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id =: documentId];
        delete cd;
    }
    
    
    @AuraEnabled 
    public static Map<String, Object> getStaffPicklistFields(){
        Map<String, Object> response = new Map<String, Object>();
        List<NM_CYFD_Utility.SelectOptionWrapper> genderValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Gender__c');
        //List<NM_CYFD_Utility.SelectOptionWrapper> educationValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Education__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> backgroundCheckValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'CYFD_Background_Check__c');
        
        List<SelectOptionWrapper> educationOptions = new List<SelectOptionWrapper>();
        List<String> education = new List<String>{'High School', 'Some College', '1st Year of College/University (Freshman)', 
            '2nd Year of College/University (Sophmore)', 'AA','BA','MA', 'PhD', 'MBA'};
        
        for( String s : education){
            educationOptions.add( new SelectOptionWrapper(s,s));
        }  
        response.put('gender', genderValues);
        response.put('education', educationOptions);
        response.put('backgroundCheck', backgroundCheckValues);
        return response;
        
    }

    @AuraEnabled 
    public static Map<String, Object> getClientPicklistFields(String grant){
        Map<String, Object> response = new Map<String, Object>();
        List<NM_CYFD_Utility.SelectOptionWrapper> suffixValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Suffix__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> livingArrangementsValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Living_Arrangements__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> schoolValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'School__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> employmentStatusValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Employment_Status__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> notInLaborForceValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Not_in_Labor_Force__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> sourceOfIncomeValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Source_Of_Income__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> cyfdInvolvedValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'CYFD_Involved__c');
        //List<NM_CYFD_Utility.SelectOptionWrapper> referralSourceValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Referral_Source__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> criminalJusticeReferralValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Criminal_Justice_Referral__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> arrestInPast30DaysValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Arrest_in_Past_30_Days__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> healthInsuranceValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Health_Insurance__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> genderValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Gender__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> mcoValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'MCO__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> primaryLanguageValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Primary_Language__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> ethnicityValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Ethnicity__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> tribalAffiliationValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Tribal_Affiliation__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> otherTribalAffiliationValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Other_Tribal_Affiliation__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> dischargeReasonValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Discharge_Reason__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> reasonValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Reason__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> statusOfClientValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Status_of_Client__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> messageValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Message__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> raceValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Race__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> otherPhoneMessageValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Message__c');      
        List<NM_CYFD_Utility.SelectOptionWrapper> lgbtqValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'LGBTQ__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> populationServedValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Population_Served__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> atRiskFactorsValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'At_Risk_Factors__c');
        
        //newly added for JJAC
        List<NM_CYFD_Utility.SelectOptionWrapper> geographicLocationValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Geographic_Location__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> otherPopulationValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Other_Population_Information__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> gangActivityValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Gang_Activity__c');
        List<NM_CYFD_Utility.SelectOptionWrapper> currentlyInDetentionValues = NM_CYFD_Utility.fetchPicklist('Contract_Role__c', 'Youth_Currently_in_Detention__c');
        
        List<SelectOptionWrapper> educationOptions = new List<SelectOptionWrapper>();
        List<String> education = new List<String>{'No School','Grade 1','Grade 2','Grade 3','Grade 4','Grade 5','Grade 6',
            'Grade 7','Grade 8','Grade 9','Grade 10','Grade 11','Grade 12','GED','Some College','1st Year College/University (Freshman)',
            '2nd Year College/University (Sophmore)','Associate Degree'};
        
        for( String s : education){
            educationOptions.add( new SelectOptionWrapper(s,s));
        }       
        
        List<SelectOptionWrapper> referralSourceValues = new List<SelectOptionWrapper>();
        List<String> referralSources = new List<String>();       
        Map<String, Object> userDets = getUserDetails();
        if(grant == 'JCC')
                 referralSources = new List<String>{'Juvenile Probation','District Court Judge', 'District Attorney', 'Public Defender','Private Attorney', 'Juvenile Correctional Facility',
                     'Supervised Released Board'};
        else if(grant == 'Mentoring')
             referralSources = new List<String>{'Individual (includes Self Referral)','School (Educational)','Community Referral','Unknown','Family','State Agency','Tribal Social Services'};
        
        for( String s : referralSources){
            referralSourceValues.add( new SelectOptionWrapper(s,s));
        }  
        response.put('suffixValues', suffixValues);
        response.put('livingArrangementsValues', livingArrangementsValues);
        response.put('schoolValues', schoolValues);
        response.put('employmentStatusValues', employmentStatusValues);
        response.put('notInLaborForceValues', notInLaborForceValues);
        response.put('sourceOfIncomeValues', sourceOfIncomeValues);
        response.put('cyfdInvolvedValues', cyfdInvolvedValues);
        response.put('referralSourceValues', referralSourceValues);
        response.put('criminalJusticeReferralValues', criminalJusticeReferralValues);
        response.put('arrestInPast30DaysValues', arrestInPast30DaysValues);
        response.put('healthInsuranceValues', healthInsuranceValues);
        response.put('genderValues', genderValues);
        response.put('educationValues', educationOptions);
        response.put('mcoValues', mcoValues);
        response.put('primaryLanguageValues', primaryLanguageValues);
        response.put('ethnicityValues', ethnicityValues);
        response.put('tribalAffiliationValues', tribalAffiliationValues);
        response.put('otherTribalAffiliationValues', otherTribalAffiliationValues);
        response.put('dischargeReasonValues', dischargeReasonValues);
        response.put('reasonValues', reasonValues);
        response.put('statusOfClientValues', statusOfClientValues);
        response.put('messageValues', messageValues);
        response.put('raceValues', raceValues);
        response.put('otherPhoneMessageValues', otherPhoneMessageValues);
        response.put('lgbtqValues', lgbtqValues);
        response.put('populationServedValues', populationServedValues);
        response.put('atRiskFactorsValues', atRiskFactorsValues);
        
        response.put('geographicLocationValues', geographicLocationValues);
        response.put('otherPopulationValues', otherPopulationValues);
        response.put('gangActivityValues', gangActivityValues);
        response.put('currentlyInDetentionValues', currentlyInDetentionValues);
        
        return response;
        
    }
    
    public class ActivityWrapper{
        @AuraEnabled public String activityId;
        @AuraEnabled public String contractId;
        @AuraEnabled public String contractConfigId;
        @AuraEnabled public String activityLabel;
        @AuraEnabled public String name;
        @AuraEnabled public String lineItemId;  
        @AuraEnabled public Decimal activityRate; 
        @AuraEnabled public Decimal activityAllocatedAmt; 
        @AuraEnabled public Decimal programAllocatedAmt;
        @AuraEnabled public Decimal subContractAllocatedAmt; 
        @AuraEnabled public Decimal activityExpenditure; 
        @AuraEnabled public Decimal programExpenditure;
        @AuraEnabled public Decimal subContractExpenditure;  
        @AuraEnabled public String subContractor;
        @AuraEnabled public String unitType;
        @AuraEnabled public String activityType;
        @AuraEnabled public String program;
        @AuraEnabled public String validationField;
        @AuraEnabled public Boolean validation;
        @AuraEnabled public Boolean matchEnabled;
        @AuraEnabled public Decimal unitsLimit;
        @AuraEnabled public Decimal amountLimit;
        @AuraEnabled public Decimal youthLimit;
        @AuraEnabled public Boolean youthRequired;
        @AuraEnabled public Decimal minimumYouth;
        @AuraEnabled public Boolean multipliedByYouth;
        @AuraEnabled public Boolean skipStaff;
        
        @AuraEnabled public Decimal awardAmount; 
        @AuraEnabled public Date startDate; 
        @AuraEnabled public Date endDate; 
        @AuraEnabled public Decimal totalInvoiceAmount; 
      
    }
    
    public class ContractActivityWrapper{
        @AuraEnabled public String contractActivityId;
        @AuraEnabled public String activityId;
        @AuraEnabled public String activityLabel;
        @AuraEnabled public String unitType;
        @AuraEnabled public String accountId;
        @AuraEnabled public String contractId;
        @AuraEnabled public String contractConfigId;
        @AuraEnabled public String lineItemId;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public Decimal units;
        @AuraEnabled public Decimal rate;
        @AuraEnabled public Decimal programExpenditure;
        @AuraEnabled public Decimal activityExpenditure;
        @AuraEnabled public Decimal subContractExpenditure;
        @AuraEnabled public String program;
        @AuraEnabled public String activityDetail;
        @AuraEnabled public Date activityDate;
        @AuraEnabled public String subContractor;
        @AuraEnabled public Decimal numberOfYouth;
        @AuraEnabled public Boolean matchEnabled;
        @AuraEnabled public Decimal matchAmount;
        @AuraEnabled public Boolean multipliedByYouth;
        
        @AuraEnabled public List<ContractRoleWrapper> staffs;
        @AuraEnabled public List<ContractRoleWrapper> clients;
               
    }
 
    public class SelectOptionWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public SelectOptionWrapper(string value, string label){
            this.value = value;
            this.label = label;
        }
    }
   
}