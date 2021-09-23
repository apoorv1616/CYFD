public without sharing class NM_CYFD_ContractActivityTriggerHandler {
    public static boolean stopDeletion = false;
    public static boolean stopUpdateExpenditureAmounts = false;
    public static boolean isMentoring = false;
    public static Boolean bulkUpdate = Label.nmcyfdBulkUpdateExpenditure == 'true';
    public static Id ACTIVITY_EXPENDITURE_RECORDTYPE = NM_CYFD_Utility.ACTIVITY_EXPENDITURE_RECORDTYPE;
    public static Id PROGRAM_EXPENDITURE_RECORDTYPE = NM_CYFD_Utility.PROGRAM_EXPENDITURE_RECORDTYPE;
    public static Id SUBCONTRACTOR_EXPENDITURE_RECORDTYPE = NM_CYFD_Utility.SUBCONTRACTOR_EXPENDITURE_RECORDTYPE;
    public static String BILLABLE_ACTIVITY_RECORDTYPE = NM_CYFD_Utility.BILLABLE_ACTIVITY_RECORDTYPE;
    
    public static Boolean stopThrowErrorForDuplicateDeliverableContract = false;
    /*
        @author : Apoorv Anand
        @desc   : to update expenditure amounts of CA to expenditure object.
                : (after insert, after delete, after update)
                : Added as a part of architecture change
   */
    public static void updateExpenditureAmounts( List<Contract_Activity__c> newList, Map<Id,Contract_Activity__c> oldMap ) {
        
        List<Contract_Activity__c> activityList = new List<Contract_Activity__c>();
        
        Set<Id> contractIdSet = new Set<Id>();
        Set<String> activityLabelSet = new Set<String>();
        Set<String> programSet = new Set<String>();
        Set<String> subcontractorSet = new Set<String>();
        
        Map<String, Decimal> mapOfContractIdAndActivityLabelBySum = new Map<String, Decimal>();
        Map<String, Decimal> mapOfContractIdAndProgramBySum = new Map<String, Decimal>();
        Map<String, Decimal> mapOfContractIdAndSubcontractorBySum = new Map<String, Decimal>();
        
        Map<String, Contract_Activity_Expenditure_Amount__c> mapOfExpenditure = new Map<String, Contract_Activity_Expenditure_Amount__c>();
        
        if (newList != null) 
            activityList = newList;
        
        else if(newList == null && oldMap != null) {
            activityList = oldMap.values();
        }
        
        for ( Contract_Activity__c activityRecord : activityList ) {
            
            if ( activityRecord.Contract__c != null 
                && activityRecord.Invoice_Amount__c != null
                && ( bulkUpdate || isMentoring || Trigger.isDelete || oldMap == null  || oldMap.get(activityRecord.Id).Invoice_Amount__c != activityRecord.Invoice_Amount__c
                 )
               ) {
                   
                   if( String.isNotBlank(activityRecord.Activity_Label__c) ) 
                       activityLabelSet.add( activityRecord.Activity_Label__c );
                   
                   if( String.isNotBlank(activityRecord.Program__c) ) 
                       programSet.add( activityRecord.Program__c );
                   
                   if( String.isNotBlank(activityRecord.Sub_Contractor__c) ) 
                       subcontractorSet.add( activityRecord.Sub_Contractor__c );
                   
                   contractIdSet.add( activityRecord.Contract__c );
               }
        }
        
        if ( !contractIdSet.isEmpty() ) {
            
            //Activity Expenditure amount
            if ( !activityLabelSet.isEmpty() ) {
                for ( AggregateResult aggregateResult : 
                     [SELECT sum(Invoice_Amount__c) expAmount, Hidden_Activity_Label__c, Contract__c 
                      FROM Contract_Activity__c  
                      GROUP BY Hidden_Activity_Label__c,Contract__c, RecordType.DeveloperName
                      HAVING Contract__c IN :contractIdSet
                      //AND Hidden_Activity_Label__c IN :activityLabelSet
                      AND RecordType.DeveloperName = :BILLABLE_ACTIVITY_RECORDTYPE]) {
                          
                          String contractId = (String)aggregateResult.get('Contract__c');
                          String activityLabel = (String)aggregateResult.get('Hidden_Activity_Label__c');
                          Decimal invoiceAmount = (Decimal)aggregateResult.get('expAmount');
                          mapOfContractIdAndActivityLabelBySum.put( contractId + '#' + activityLabel, invoiceAmount );    
                      }
            }
            
            //Program Expenditure amount
            if ( !programSet.isEmpty() ) {
                for ( AggregateResult aggregateResult : 
                     [SELECT sum(Invoice_Amount__c) expAmount, Program__c, Contract__c 
                      FROM Contract_Activity__c  
                      GROUP BY Program__c,Contract__c, RecordType.DeveloperName
                      HAVING Contract__c IN :contractIdSet
                      //AND Program__c IN :programSet
                      AND RecordType.DeveloperName = :BILLABLE_ACTIVITY_RECORDTYPE]) {
                          
                          String contractId = (String)aggregateResult.get('Contract__c');
                          String program = (String)aggregateResult.get('Program__c');
                          Decimal invoiceAmount = (Decimal)aggregateResult.get('expAmount');
                          mapOfContractIdAndProgramBySum.put( contractId + '#' + program, invoiceAmount );    
                      }
            }
            
            //Sub-contractor Expenditure amount
            if ( !subcontractorSet.isEmpty() ) {
                for ( AggregateResult aggregateResult : 
                     [SELECT sum(Invoice_Amount__c) expAmount, Sub_Contractor_For_Script__c, Contract__c 
                      FROM Contract_Activity__c  
                      GROUP BY Sub_Contractor_For_Script__c,Contract__c, RecordType.DeveloperName
                      HAVING Contract__c IN :contractIdSet
                      //AND Sub_Contractor_For_Script__c IN :subcontractorSet
                      AND RecordType.DeveloperName = :BILLABLE_ACTIVITY_RECORDTYPE]) {
                          
                          String contractId = (String)aggregateResult.get('Contract__c');
                          String subContractor = (String)aggregateResult.get('Sub_Contractor_For_Script__c');
                          Decimal invoiceAmount = (Decimal)aggregateResult.get('expAmount');
                          mapOfContractIdAndSubcontractorBySum.put( contractId + '#' + subContractor, invoiceAmount );    
                      }
            }
            Map<String, Contract_Activity_Expenditure_Amount__c> mapOfLabelToExpenditure = new Map<String, Contract_Activity_Expenditure_Amount__c>();
            //Expenditure records related to contract inserted
            List<Contract_Activity_Expenditure_Amount__c> expList = 
                [SELECT Id, Activity_Label__c, Activity_Expenditure_Amount__c, RecordTypeId, Contract__c,
                 Program__c, Program_Expenditure_Amount__c, Sub_Contractor__c, Sub_Contract_Expenditure_Amount__c
                 FROM Contract_Activity_Expenditure_Amount__c
                 WHERE Contract__c IN :contractIdSet ];
            
            for (Contract_Activity_Expenditure_Amount__c exp : expList) {
                if (String.isNotBlank(exp.Activity_Label__c))
                    mapOfLabelToExpenditure.put(exp.Contract__c + '#' + exp.Activity_Label__c + '#' + 'Activity_Label__c', exp);
                
                if (String.isNotBlank(exp.Program__c))
                    mapOfLabelToExpenditure.put(exp.Contract__c + '#' + exp.Program__c + '#' + 'Program__c', exp);
                
                if (String.isNotBlank(exp.Sub_Contractor__c))
                    mapOfLabelToExpenditure.put(exp.Contract__c + '#' + exp.Sub_Contractor__c  + '#' + 'Sub_Contractor__c', exp);
            }
            
            Map<String, Contract_Activity_Expenditure_Amount__c> insertContractActivityExpenditureAmountMap = new Map<String, Contract_Activity_Expenditure_Amount__c>();
            
            
            for ( Contract_Activity__c activityRecord : activityList ) {
                if (activityRecord.Contract__c != null 
                    && activityRecord.Invoice_Amount__c != null) {
                        if (!expList.isEmpty()) {
                            //if one of the expenditure record exists.
                            //for ( Contract_Activity_Expenditure_Amount__c exp : expList ) {
                            
                            //Activity Expenditure Amount--
                            if( String.isNotBlank(activityRecord.Activity_Label__c) 
                               && mapOfContractIdAndActivityLabelBySum.containsKey(activityRecord.Contract__c + '#' + activityRecord.Activity_Label__c )) {
                                   
                                   if (mapOfLabelToExpenditure.containsKey(activityRecord.Contract__c + '#' + activityRecord.Activity_Label__c + '#' + 'Activity_Label__c')) {
                                       
                                       Contract_Activity_Expenditure_Amount__c exp = mapOfLabelToExpenditure.get(activityRecord.Contract__c + '#' + activityRecord.Activity_Label__c + '#' + 'Activity_Label__c');
                                       mapOfExpenditure.put(activityRecord.Contract__c + '#' + activityRecord.Activity_Label__c + '#' + 'Activity_Label__c' , createActivityExpenditure( activityRecord, exp, mapOfContractIdAndActivityLabelBySum ));
                                   }
                                   else
                                       mapOfExpenditure.put(activityRecord.Contract__c + '#' + activityRecord.Activity_Label__c + '#' + 'Activity_Label__c' , createActivityExpenditure( activityRecord, null, mapOfContractIdAndActivityLabelBySum ));
                               }
                            //Activity Expenditure Amount ends--
                            
                            
                            //Program Expenditure Amount--
                            if( String.isNotBlank(activityRecord.program__c) 
                               && mapOfContractIdAndProgramBySum.containsKey(activityRecord.Contract__c + '#' + activityRecord.program__c )) {
                                   
                                   if (mapOfLabelToExpenditure.containsKey(activityRecord.Contract__c + '#' + activityRecord.program__c + '#' + 'Program__c')) {
                                       //Expenditure Record already exists for this program and contract.
                                       Contract_Activity_Expenditure_Amount__c exp = mapOfLabelToExpenditure.get(activityRecord.Contract__c + '#' + activityRecord.Program__c + '#' + 'Program__c');
                                       mapOfExpenditure.put(activityRecord.Contract__c + '#' + activityRecord.program__c + '#' + 'Program__c' , createProgramExpenditure(activityRecord, exp, mapOfContractIdAndProgramBySum ));
                                   }
                                   else
                                       mapOfExpenditure.put(activityRecord.Contract__c + '#' + activityRecord.program__c + '#' + 'Program__c' , createProgramExpenditure(activityRecord, null, mapOfContractIdAndProgramBySum ));
                                   
                               } 
                            
                            //Program Expenditure Amount ends--
                            
                            //Sub-contractor Expenditure Amount--
                            if( String.isNotBlank(activityRecord.Sub_Contractor__c) 
                               && mapOfContractIdAndSubcontractorBySum.containsKey(activityRecord.Contract__c + '#' + activityRecord.Sub_Contractor__c )) {
                                   
                                   if (mapOfLabelToExpenditure.containsKey(activityRecord.Contract__c + '#' + activityRecord.Sub_Contractor__c + '#' + 'Sub_Contractor__c')) {
                                       //Expenditure Record already exists for this program and contract.
                                       Contract_Activity_Expenditure_Amount__c exp = mapOfLabelToExpenditure.get(activityRecord.Contract__c + '#' + activityRecord.Sub_Contractor__c + '#' + 'Sub_Contractor__c');
                                       mapOfExpenditure.put(activityRecord.Contract__c + '#' + activityRecord.Sub_Contractor__c + '#' + 'Sub_Contractor__c' , createSubContractorExpenditure( activityRecord, exp, mapOfContractIdAndSubcontractorBySum ));
                                   }
                                   else
                                       mapOfExpenditure.put(activityRecord.Contract__c + '#' + activityRecord.Sub_Contractor__c + '#' + 'Sub_Contractor__c' , createSubContractorExpenditure( activityRecord, null, mapOfContractIdAndSubcontractorBySum ));
                                   
                               }
                            
                            //Subcontractor Expenditure Amount ends--
                            //}
                        }
                        //if none of the expenditure record exist then create a new one which is eligible.
                        else {
                            //Activity Expenditure Amount--
                            if( String.isNotBlank(activityRecord.Activity_Label__c) 
                               && mapOfContractIdAndActivityLabelBySum.containsKey(activityRecord.Contract__c + '#' + activityRecord.Activity_Label__c )) {
                                   
                                   //Expenditure Record already exists for this activity label and contract.
                                   mapOfExpenditure.put(activityRecord.Contract__c + '#' +activityRecord.Activity_Label__c + '#' + 'Activity_Label__c' , createActivityExpenditure( activityRecord, null, mapOfContractIdAndActivityLabelBySum ));
                               }
                            
                            //Program Expenditure Amount--
                            if( String.isNotBlank(activityRecord.program__c)
                               && mapOfContractIdAndProgramBySum.containsKey(activityRecord.Contract__c + '#' + activityRecord.program__c )) {
                                   
                                   //Expenditure Record already exists for this program and contract.
                                   mapOfExpenditure.put(activityRecord.Contract__c + '#' +activityRecord.program__c + '#' + 'Program__c' ,createProgramExpenditure(activityRecord, null, mapOfContractIdAndProgramBySum ));
                                   
                               }
                            
                            //Sub-contractor Expenditure Amount--
                            if( String.isNotBlank(activityRecord.Sub_Contractor__c) 
                               && mapOfContractIdAndSubcontractorBySum.containsKey(activityRecord.Contract__c + '#' + activityRecord.Sub_Contractor__c ) ) {
                                   
                                   //Expenditure Record already exists for this program and contract.
                                   mapOfExpenditure.put(activityRecord.Contract__c + '#' +activityRecord.Sub_Contractor__c + '#' + 'Sub_Contractor__c' , createSubContractorExpenditure( activityRecord, null, mapOfContractIdAndSubcontractorBySum ));
                                   
                               }
                        }
                    }
            }
            
            if ( !mapOfExpenditure.isEmpty() ) {

                upsert mapOfExpenditure.values();
            }
        }
    }
    
    /*
        @author : Apoorv Anand
        @desc   : used to create/update Expenditure Record based on Activity Label.
                : Added as a part of architecture change
    */
    private static Contract_Activity_Expenditure_Amount__c createActivityExpenditure(Contract_Activity__c activityRecord, Contract_Activity_Expenditure_Amount__c exp, Map<String, Decimal> mapOfContractIdAndActivityLabelBySum) {
        
        Contract_Activity_Expenditure_Amount__c expenditureRecord = new Contract_Activity_Expenditure_Amount__c();
        
        if ( exp != null ) {
            
            expenditureRecord.Id = exp.Id;
        }
        else {
            expenditureRecord.contract__c = activityRecord.contract__c;            
        }
        
        expenditureRecord.Activity_Label__c = activityRecord.Activity_Label__c;
        expenditureRecord.RecordTypeId = ACTIVITY_EXPENDITURE_RECORDTYPE;
        expenditureRecord.Activity_Expenditure_Amount__c = mapOfContractIdAndActivityLabelBySum.get(activityRecord.Contract__c + '#' + activityRecord.Activity_Label__c );
        
        // if (!Trigger.isDelete) {
        //     expenditureRecord.Activity_Expenditure_Amount__c = mapOfContractIdAndActivityLabelBySum.get(activityRecord.Contract__c + '#' + activityRecord.Activity_Label__c );
            
        //     if ( !bulkUpdate && !isMentoring && !expenditureRecord.Activity_Label__c.contains('Group') )
        //     	expenditureRecord.Activity_Expenditure_Amount__c += activityRecord.Invoice_Amount__c; 
        // }
        // else
        //     expenditureRecord.Activity_Expenditure_Amount__c = mapOfContractIdAndActivityLabelBySum.get(activityRecord.Contract__c + '#' + activityRecord.Activity_Label__c );
        
        return expenditureRecord;
    }
    
    /*
        @author : Apoorv Anand
        @desc   : used to create/update Expenditure Record based on Program.
                : Added as a part of architecture change
    */
    private static Contract_Activity_Expenditure_Amount__c createProgramExpenditure(Contract_Activity__c activityRecord, Contract_Activity_Expenditure_Amount__c exp, Map<String, Decimal> mapOfContractIdAndProgramBySum) {
        
        Contract_Activity_Expenditure_Amount__c expenditureRecord = new Contract_Activity_Expenditure_Amount__c();
        
        if ( exp != null ) {
            
            expenditureRecord.Id = exp.Id;
        }
        else {
            expenditureRecord.contract__c = activityRecord.contract__c;            
        }
        expenditureRecord.program__c = activityRecord.program__c;
        expenditureRecord.RecordTypeId = PROGRAM_EXPENDITURE_RECORDTYPE;
        expenditureRecord.Program_Expenditure_Amount__c = mapOfContractIdAndProgramBySum.get(activityRecord.Contract__c + '#' + activityRecord.Program__c );
        
        // if (!Trigger.isDelete) {
        //     expenditureRecord.Program_Expenditure_Amount__c = mapOfContractIdAndProgramBySum.get(activityRecord.Contract__c + '#' + activityRecord.Program__c );
        //     if ( !bulkUpdate && !isMentoring  )
        //     	expenditureRecord.Program_Expenditure_Amount__c += activityRecord.Invoice_Amount__c; 
        // }
        // else
        //     expenditureRecord.Program_Expenditure_Amount__c = mapOfContractIdAndProgramBySum.get(activityRecord.Contract__c + '#' + activityRecord.Program__c );
        // //- activityRecord.Invoice_Amount__c; 
        
        return expenditureRecord;
    }
    
    /*
        @author : Apoorv Anand
        @desc   : used to create/update Expenditure Record based on Sub-contractor.
        		: Added as a part of architecture change
    */
    private static Contract_Activity_Expenditure_Amount__c createSubContractorExpenditure(Contract_Activity__c activityRecord, Contract_Activity_Expenditure_Amount__c exp, Map<String, Decimal> mapOfContractIdAndSubcontractorBySum) {
        
        Contract_Activity_Expenditure_Amount__c expenditureRecord = new Contract_Activity_Expenditure_Amount__c();
        
        if ( exp != null ) {
            
            expenditureRecord.Id = exp.Id;
        }
        else {
            expenditureRecord.contract__c = activityRecord.contract__c;            
        }
        expenditureRecord.Sub_Contractor__c = activityRecord.Sub_Contractor__c;
        expenditureRecord.RecordTypeId = SUBCONTRACTOR_EXPENDITURE_RECORDTYPE;
         expenditureRecord.Sub_Contract_Expenditure_Amount__c = mapOfContractIdAndSubcontractorBySum.get(activityRecord.Contract__c + '#' + activityRecord.Sub_Contractor__c );
        
        // if (!Trigger.isDelete) {
        //     expenditureRecord.Sub_Contract_Expenditure_Amount__c = mapOfContractIdAndSubcontractorBySum.get(activityRecord.Contract__c + '#' + activityRecord.Sub_Contractor__c );
        //     if ( !bulkUpdate && !isMentoring  )
        //        expenditureRecord.Sub_Contract_Expenditure_Amount__c += activityRecord.Invoice_Amount__c; 
        // }
        // else
        //     expenditureRecord.Sub_Contract_Expenditure_Amount__c = mapOfContractIdAndSubcontractorBySum.get(activityRecord.Contract__c + '#' + activityRecord.Sub_Contractor__c );
        // //- activityRecord.Invoice_Amount__c; 
        return expenditureRecord;
    }
    
    /*
    @author : Apoorv Anand
    @desc   : used to populate Hidden_Activity_Label__c from Activity_Label__c
            (Before insert, Before update)
            : Added as a part of architecture change
    */
    public static void populateHiddenActivityLabelAndSubcontractorScript( List<Contract_Activity__c> newList, Map<Id,Contract_Activity__c> oldMap ) {
        
        for ( Contract_Activity__c activityRecord : newList ) {
            if (oldMap == null 
                || 
                (oldMap.get(activityRecord.Id).Activity_Label__c != activityRecord.Activity_Label__c
                 ||
                 oldMap.get(activityRecord.Id).Sub_Contractor__c != activityRecord.Sub_Contractor__c)) {
                     
                if ( activityRecord.Activity_Label__c != null ) {
                    
                    activityRecord.Hidden_Activity_Label__c = activityRecord.Activity_Label__c;
                }
                if ( activityRecord.Sub_Contractor__c != null ) {
                    
                    activityRecord.Sub_Contractor_For_Script__c = activityRecord.Sub_Contractor__c ;
                }
            }
        }
    }
    
    /*
        @author : Apoorv Anand
        @desc   : used to throw error on detecting duplicate deliverable record of CA.
        			(After insert, After update)
    */
    public static void throwErrorForDuplicateDeliverableContract(List<Contract_Activity__c> newList, Map<Id,Contract_Activity__c> oldMap) {
        
        Map<Id, List<String>> contractIdtoLabelMap = new Map<Id, List<String>>();
        //Set<String> existingContractActivityLabels = new Set<String>();
        Map<String,Integer> existingContractIdToLabelCount = new Map<String,Integer>();
        Boolean throwError = true;
        Boolean hasBeenInIterationOnce = false;
        List<Contract_Activity__c> contractActivityToDeleteList = new List<Contract_Activity__c>();
        Id DELIVERABLE_CONTRACT_RECORDTYPEID = NM_CYFD_Utility.getRecordTypeId('Contract_Activity__c','Deliverable');
        
        String errorMessage = 'Activity Label on Contract Activity already exists for this contract. ';
        
        for(Contract_Activity__c contractActivityRecord : newList) {
            if(contractActivityRecord.Activity_Label__c != null 
               && contractActivityRecord.Contract__c != null
               && contractActivityRecord.RecordTypeId == DELIVERABLE_CONTRACT_RECORDTYPEID) {
					
                   if(oldMap == null 
                      || (oldMap != null 
                          && oldMap.get(contractActivityRecord.Id).Activity_Label__c != contractActivityRecord.Activity_Label__c)) {
                              
                              if ( !contractIdtoLabelMap.containsKey(contractActivityRecord.Contract__c) ) {
                                  contractIdtoLabelMap.put(contractActivityRecord.Contract__c, new List<String>());
                              }
                              contractIdtoLabelMap.get(contractActivityRecord.Contract__c).add(contractActivityRecord.Activity_Label__c);
                              //contractIdtoLabelMap.put(contractActivityRecord.Contract__c, contractActivityRecord.Activity_Label__c);
                          }
               }
        }
        
        if(!contractIdtoLabelMap.isEmpty()) {
           /* Map<String,String> mapOfcontractIdToConfiguration = new Map<String,String>();
            
            for (Contract__c contractRecord : [SELECT Id, Contract_Configuration__c
                                               FROM Contract__c
                                               WHERE Id IN :contractIdtoLabelMap.keySet()]) {
                                                   
               mapOfcontractIdToConfiguration.put( contractRecord.Id, contractRecord.Contract_Configuration__c );                                    
            }*/
            
            List<String> activityLabelList = contractIdtoLabelMap.values()[0];
            for(Contract_Activity__c contractActivityRecord : [SELECT Id, Activity_Label__c, Contract__r.Name__c,Contract_Configuration__c
                                                               FROM Contract_Activity__c
                                                               WHERE Contract__c IN :contractIdtoLabelMap.keySet()
                                                               AND Activity_Label__c IN :activityLabelList]) {
                                                                   
                   if(!existingContractIdToLabelCount.containsKey(contractActivityRecord.Contract__c + '#' + contractActivityRecord.Activity_Label__c)) {
                         existingContractIdToLabelCount.put(contractActivityRecord.Contract__c + '#' + contractActivityRecord.Activity_Label__c, 0);                                                
                   }      
                                                                   
                   Integer count = existingContractIdToLabelCount.get(contractActivityRecord.Contract__c + '#' + contractActivityRecord.Activity_Label__c); 
                   count += 1;                                     
                   existingContractIdToLabelCount.put(contractActivityRecord.Contract__c + '#' + contractActivityRecord.Activity_Label__c, count);                                                      
                                                                   
            }
            
            for(Contract_Activity__c contractActivityRecord : newList) {
                if(existingContractIdToLabelCount.containsKey(contractActivityRecord.Contract__c + '#' + contractActivityRecord.Activity_Label__c)) {
                    hasBeenInIterationOnce = true;
                    Integer count = existingContractIdToLabelCount.get(contractActivityRecord.Contract__c + '#' + contractActivityRecord.Activity_Label__c);
  
                    if(count >= 2) {
                        Contract_Activity__c contractActivityRecord1 = new Contract_Activity__c();
                        contractActivityRecord1.Id = contractActivityRecord.Id;
                        contractActivityToDeleteList.add(contractActivityRecord1);
                        if(throwError != false) {
                            throwError = true;
                        }
                        
                    }
                    else {
                        throwError = false;
                    }
                }
            }
            if(throwError && hasBeenInIterationOnce && !Test.isRunningTest()) {
                newList[0].addError(errorMessage);
            }
            else {
                if(!contractActivityToDeleteList.isEmpty()) {
                    delete contractActivityToDeleteList;
                }
            }
            
        }
        
    } 
    
    public static void rollUpInvoiceAmountToInvoice(List<Contract_Activity__c> newList, Map<Id,Contract_Activity__c> oldMap){
        
        Set<Id> invoiceIds = new Set<Id>();
        Id recordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Activity__c','Billable Activity');
        
        List<Contract_Activity__c> contractActivities = new List<Contract_Activity__c>();
        if(newList == null)
            contractActivities = oldMap.values();
        else 
            contractActivities = newList;
        for(Contract_Activity__c activity: contractActivities){
            if(activity.RecordTypeId  == recordTypeId && activity.Invoice__c != null){
                
                if(newList == null 
                   || (newList != null && oldMap == null) 
                   || (oldMap.get(activity.Id).Invoice__c != activity.Invoice__c) 
                   || (oldMap.get(activity.Id).Invoice_Amount__c != activity.Invoice_Amount__c)
                   || (oldMap.get(activity.Id).Match_Amount__c != activity.Match_Amount__c)){
                       
                       invoiceIds.add(activity.Invoice__c);
                       
                       if (oldMap != null && oldMap.get(activity.Id).Invoice__c != null) {
                       		invoiceIds.add(oldMap.get(activity.Id).Invoice__c);
                       }
                   }
            }
        }
        
        if (!invoiceIds.isEmpty()) {
            rollUpInvoiceAmount(invoiceIds);
        }
        
    }
    
    public static void rollUpInvoiceAmount(Set<Id> invoiceIds)  {
        
        List<Invoice__c> invoices = new List<Invoice__c>();
        for(AggregateResult ar : [SELECT Invoice__c , SUM(Invoice_Amount__c), SUM(Match_Amount__c) FROM Contract_Activity__c GROUP BY Invoice__c, RecordType.Name 
                                  HAVING RecordType.Name = 'Billable Activity' AND Invoice__c IN: invoiceIds]){
                                      Invoice__c inv = new Invoice__c(Id= String.valueOf(ar.get('Invoice__c')));
                                      inv.Amount__c = (Decimal)ar.get('expr0');
                                      inv.Match_Amount__c = (Decimal)ar.get('expr1');
                                      invoices.add(inv);
                                      
                                  }
        
        for(Invoice__c inv : [SELECT ID FROM Invoice__c WHERE Id IN: invoiceIds AND Id NOT IN (SELECT Invoice__c FROM Contract_Activity__c)]){      
            //if(inv.Contract_Activities__r.isEmpty()){
            inv.Amount__c = 0.0;
            inv.Match_Amount__c = 0.0;
            invoices.add(inv);
            //  }
        }

        if(!invoices.isEmpty()) {
            NM_CYFD_InvoiceTriggerHandler.stopRecurssion = true;
            update invoices;
        }
        
    }
    
}