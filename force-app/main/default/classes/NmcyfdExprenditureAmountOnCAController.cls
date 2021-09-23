public without sharing class NmcyfdExprenditureAmountOnCAController {
    
    public static String BILLABLE_ACTIVITY_RECORDTYPE = NM_CYFD_Utility.BILLABLE_ACTIVITY_RECORDTYPE;

    @AuraEnabled
    public static Decimal getTotalMatchAmount ( Id recordId ) {

        Decimal totalMatchAmount = 0;

        String sObjName = recordId.getSObjectType().getDescribe().getName();

        if ( sObjName != 'Contract__c' ) {
            return 0;
        }

        for (AggregateResult aggr : 
                [SELECT count(id), sum(Match_Amount__c),Status__c 
                FROM Invoice__c 
                GROUP BY Contract__c, Status__c 
                HAVING Status__c in ('Approved', 'Paid') and Contract__c = :recordId]) {

                totalMatchAmount += (Decimal)aggr.get('expr1');
                
        }

        return totalMatchAmount;
    }

    @AuraEnabled
    public static List<Contract_Activity__c> getMatchExpenditure( String recordId, String fieldName, Boolean columnSort ) {

        List<Contract_Activity__c> activityList = new List<Contract_Activity__c>();
        
        if ( String.isNotBlank( recordId ) ) {

            String sortDirection = '';
            
           if(columnSort != null && columnSort) {
               sortDirection = ' ASC ';
           }
           else if(columnSort != null && !columnSort) {   
               sortDirection = ' DESC ';    
           }

           if ( fieldName == 'Name' ) {
                fieldName = ' Hidden_Name__c ';
            }

          

           String query = 'SELECT Id, Activity_Label__c, Name, Match_Amount__c, Date__c, Invoice__r.Name, Invoice__c '
                        + ' FROM Contract_Activity__c '
                        + ' WHERE Contract__c = :recordId '
                        + ' AND Match_Amount__c != null ';

            if(String.isNotBlank(fieldName)) {
                
                query += ' ORDER BY ' + fieldName  + ' ' + sortDirection + '  NULLS LAST ';
            }
            else {
                query += ' ORDER BY Date__c DESC NULLS LAST ';
            }

            activityList = Database.query( query );
        }

        return activityList;
    }

    @AuraEnabled
    public static Decimal getProgramSupportFee ( Id recordId ) {

        Decimal totalProgramSupportFee = 0;

        String sObjName = recordId.getSObjectType().getDescribe().getName();

        if ( sObjName != 'Contract__c' ) {
            return 0;
        }

        for (AggregateResult aggr : 
                [SELECT count(id), sum(Program_Support_Fee__c),Status__c 
                FROM Invoice__c 
                GROUP BY Contract__c, Status__c 
                HAVING Status__c in ('Approved', 'Paid') and Contract__c = :recordId]) {

                // if ( !mapOfContractIdToSumOfProgramSupportFee.containsKey( recordId ) )
                //     mapOfContractIdToSumOfProgramSupportFee.put( recordId, 0);    
                
                // Decimal sum = mapOfContractIdToSumOfProgramSupportFee.get( recordId );    
                // mapOfContractIdToSumOfProgramSupportFee.put( recordId, (Decimal)aggr.get('expr1') + sum );    

                totalProgramSupportFee += (Decimal)aggr.get('expr1');
                
        }

        return totalProgramSupportFee;
    }

    @AuraEnabled
    public static List<ActivityAndExpenditure> getExpenditureAmount (Id recordId) {

        List<ActivityAndExpenditure> expList = new List<ActivityAndExpenditure>();

        if ( String.isNotBlank( recordId ) )  {

            String sObjName = recordId.getSObjectType().getDescribe().getName();
        
            if ( sObjName == 'Contract_Activity__c' ) {

                List<Contract_Activity__c> contractActivityList = 
                    [SELECT Id, Activity_Label__c, Program__c, Sub_Contractor__c, Contract__c, Name, Contract__r.Name__c,Contract__r.grant__c, 
                    Contract_Configuration_Line_Item__c, Contract_Configuration_Line_Item__r.Activity_Allocated_Amount__c, Invoice__r.Status__c,
                    Contract_Configuration_Line_Item__r.Program_Allocated_Amount__c,
                    Contract_Configuration_Line_Item__r.Sub_Contract_Allocated_Amount__c          
                    FROM Contract_Activity__c
                    WHERE Id = :recordId];

                if ( !contractActivityList.isEmpty() 
                    && contractActivityList[0].contract__c != null 
                    && (contractActivityList[0].Activity_Label__c != null 
                        ||
                        contractActivityList[0].Program__c != null
                        ||
                        contractActivityList[0].Sub_Contractor__c != null)
                    ) {
                        

                    String contractId = contractActivityList[0].contract__c;
                    String query = ' SELECT Id, Activity_Label__c, Program__c, Sub_Contractor__c, '
                                + ' Activity_Expenditure_Amount__c, Program_Expenditure_Amount__c, Sub_Contract_Expenditure_Amount__c, Contract__c '
                                + ' FROM Contract_Activity_Expenditure_Amount__c '
                                + ' WHERE Contract__c = :contractId '
                                + ' AND ( ';

                    if ( contractActivityList[0].Activity_Label__c != null ) {

                        String activityLabel = contractActivityList[0].Activity_Label__c;
                        query += ' Activity_Label__c = :activityLabel ';
                    }

                    if ( contractActivityList[0].Program__c != null ) {

                        String program = contractActivityList[0].Program__c;
                        
                        if (contractActivityList[0].Activity_Label__c != null ) {
    
                            query += ' OR Program__c = :program ';
                        }
                        else {
                            query += ' Program__c = :program';
                        }
                    }

                    if ( contractActivityList[0].Sub_Contractor__c != null ) {

                        String subcontractor = contractActivityList[0].Sub_Contractor__c;

                        if (contractActivityList[0].Activity_Label__c != null 
                            ||
                            contractActivityList[0].Program__c != null) {
                            
                                query += ' OR Sub_Contractor__c = :subcontractor ';
                        }
                        else {
                            query += ' Sub_Contractor__c = :subcontractor ';

                        }
                    }

                    query += ' ) ';

                    for (Contract_Activity_Expenditure_Amount__c exp : Database.query(query) ) {

                        expList.add( new ActivityAndExpenditure( exp, contractActivityList[0] ) );
                    }
                }
            }

            else if ( sObjName == 'Contract__c' ) {

                Map<String, Contract_Activity__c> mapOfContractAndLabelToLineItem = new Map<String, Contract_Activity__c>();

                Map<String, Decimal> mapOfContractIdToSumOfProgramSupportFee = new Map<String, Decimal>();

                // for (AggregateResult aggr : 
                //     [SELECT count(id), sum(Program_Support_Fee__c),Status__c 
                //     FROM Invoice__c 
                //     GROUP BY Contract__c, Status__c 
                //     HAVING Status__c in ('Approved', 'Paid') and Contract__c = :recordId]) {

                //         if ( !mapOfContractIdToSumOfProgramSupportFee.containsKey( recordId ) )
                //             mapOfContractIdToSumOfProgramSupportFee.put( recordId, 0);    
                        
                //         Decimal sum = mapOfContractIdToSumOfProgramSupportFee.get( recordId );    
                //         mapOfContractIdToSumOfProgramSupportFee.put( recordId, (Decimal)aggr.get('expr1') + sum );    
                        
                // }

                for (Contract_Activity__c activityRecord : 
                        [SELECT Id, Contract__c, Activity_Label__c, Program__c, Sub_Contractor__c, Name, Contract__r.Name__c,
                        Contract_Configuration_Line_Item__c, Contract_Configuration_Line_Item__r.Activity_Allocated_Amount__c,
                        Contract_Configuration_Line_Item__r.Program_Allocated_Amount__c, Contract__r.grant__c, Invoice__r.Program_Support_Fee__c,
                        Contract_Configuration_Line_Item__r.Sub_Contract_Allocated_Amount__c, Invoice__r.Status__c
                        FROM Contract_Activity__c
                        WHERE Contract__c = :recordId
                        AND Match__c = false
                        ]) {

                        if ( activityRecord.Activity_Label__c != null ) {
                            
                            mapOfContractAndLabelToLineItem.put( activityRecord.Contract__c + '#' + activityRecord.Activity_Label__c, activityRecord );
                        }

                        if ( activityRecord.Program__c != null ) {
                            
                            mapOfContractAndLabelToLineItem.put( activityRecord.Contract__c + '#' + activityRecord.Program__c, activityRecord );
                        }

                        if ( activityRecord.Sub_Contractor__c != null ) {
                            
                            mapOfContractAndLabelToLineItem.put( activityRecord.Contract__c + '#' + activityRecord.Sub_Contractor__c, activityRecord );
                        }

                        // if ( activityRecord.Match_Amount__c != null ) {
                            
                        //     mapOfContractAndLabelToLineItem.put( activityRecord.Name + '#' + activityRecord.Match_Amount__c, activityRecord );
                        //     expList.add( new ActivityAndExpenditure( null, activityRecord ));
                        // }

                }

                for (Contract_Activity_Expenditure_Amount__c exp : 
                    [SELECT Id, Contract__c, Activity_Label__c, Program__c, Sub_Contractor__c, Contract__r.grant__c, Contract__r.Name__c,
                    Activity_Expenditure_Amount__c, Program_Expenditure_Amount__c, Sub_Contract_Expenditure_Amount__c
                    FROM Contract_Activity_Expenditure_Amount__c
                    WHERE Contract__c = :recordId ]) {

                    if ( exp.Activity_Label__c != null && mapOfContractAndLabelToLineItem.containsKey( exp.Contract__c + '#' + exp.Activity_Label__c ) ) {
                        // ActivityAndExpenditure acc = new ActivityAndExpenditure( exp, mapOfContractAndLabelToLineItem.get( exp.Contract__c + '#' + exp.Activity_Label__c ) );
                        // acc.Program_Support_Fee = mapOfContractIdToSumOfProgramSupportFee.containsKey( exp.Contract__c ) 
                        //                             ? mapOfContractIdToSumOfProgramSupportFee.get( exp.Contract__c ) : 0;

                        // expList.add( acc );
                        expList.add( new ActivityAndExpenditure( exp, mapOfContractAndLabelToLineItem.get( exp.Contract__c + '#' + exp.Activity_Label__c ) ) );

                    }

                    if ( exp.Program__c != null && mapOfContractAndLabelToLineItem.containsKey( exp.Contract__c + '#' + exp.Program__c ) ) {

                        expList.add( new ActivityAndExpenditure( exp, mapOfContractAndLabelToLineItem.get( exp.Contract__c + '#' + exp.Program__c ) ) );

                    }

                    if ( exp.Sub_Contractor__c != null && mapOfContractAndLabelToLineItem.containsKey( exp.Contract__c + '#' + exp.Sub_Contractor__c ) ) {

                        expList.add( new ActivityAndExpenditure( exp, mapOfContractAndLabelToLineItem.get( exp.Contract__c + '#' + exp.Sub_Contractor__c ) ) );

                    }
                }

            }
        }

        return expList;
    }

    @AuraEnabled
    public static List<ActivityAndInvoice> getContractActivityRelatedToGrant ( String contractId, String label, String grant, String searchKey ) {

        List<ActivityAndInvoice> activityAndInvoiceList = new List<ActivityAndInvoice>();
        String query = '';
        
        if  ( String.isNotBlank(contractId) ) {

            if (grant == 'Activity Expenditure') {

                query = ' SELECT Id, Name, Invoice_Amount__c, Invoice__r.Name, Date__c, Invoice__c, Activity_Label__c, Contract__c, Contract__r.grant__c, Invoice__r.Program_Support_Fee__c, Invoice__r.Status__c  '
                        + ' FROM Contract_Activity__c '
                        + ' WHERE contract__c = :contractId '
                        + ' AND Activity_Label__c = :label '
                        + ' AND RecordType.DeveloperName = :BILLABLE_ACTIVITY_RECORDTYPE ';
            }
            else if (grant == 'Program Expenditure') {

                query = ' SELECT Id, Name, Invoice_Amount__c, Invoice__r.Name, Date__c, Invoice__c, Activity_Label__c, Contract__c, Contract__r.grant__c, Invoice__r.Status__c, Invoice__r.Program_Support_Fee__c  '
                    + ' FROM Contract_Activity__c '
                    + ' WHERE contract__c = :contractId '
                    + ' AND program__c = :label '
                    + ' AND RecordType.DeveloperName = :BILLABLE_ACTIVITY_RECORDTYPE ';
            }

            else if (grant == 'Sub-Contractor Expenditure') {

                query = ' SELECT Id, Name, Invoice_Amount__c, Invoice__r.Name, Date__c, Invoice__c, Activity_Label__c, Contract__c, Contract__r.grant__c, Invoice__r.Status__c, Invoice__r.Program_Support_Fee__c '
                + ' FROM Contract_Activity__c '
                + ' WHERE contract__c = :contractId '
                + ' AND Sub_Contractor__c = :label '
                + ' AND RecordType.DeveloperName = :BILLABLE_ACTIVITY_RECORDTYPE ';
            }

            if ( String.isNotBlank(searchKey) ) {
                String key = '%'+searchKey+'%';
                query += ' AND Name LIKE :key ';
            }

            query += ' AND Match__c = false ';

            if ( String.isNotBlank( query) )
                // activityList = Database.query( query );
                for ( Contract_Activity__c activityRecord : Database.query( query ) ) {

                    activityAndInvoiceList.add( new ActivityAndInvoice( activityRecord ) );
                }
        }
        
        return activityAndInvoiceList;
    }

    public class ActivityAndInvoice {
        @AuraEnabled public String Id;
        @AuraEnabled public String name;
        @AuraEnabled public Decimal invoiceAmount;
        @AuraEnabled public String invoiceName;
        @AuraEnabled public Date activityDate;
        @AuraEnabled public String invoiceId;
        @AuraEnabled public Boolean hasInvoiceAmount;
        // @AuraEnabled public String activityLabel;
        

        public ActivityAndInvoice ( Contract_Activity__c activityRecord ) {

            this.Id = activityRecord.Id;
            this.name = activityRecord.Name;
            this.invoiceAmount = activityRecord.Invoice_Amount__c;

            if (activityRecord.Invoice__c != null) {
                this.invoiceName = activityRecord.Invoice__r.Name;
            }

            this.activityDate = activityRecord.Date__c;
            this.invoiceId = activityRecord.Invoice__c;

            if (this.invoiceAmount != null) {
                this.hasInvoiceAmount = true;
            }
            else {
                this.hasInvoiceAmount = false;
                
            }

        }

    }

    public class ActivityAndExpenditure {

        @AuraEnabled public String Id;
        @AuraEnabled public String Activity_Label;
        @AuraEnabled public String Program;
        @AuraEnabled public String Sub_Contractor;
        @AuraEnabled public Decimal Activity_Expenditure_Amount;
        @AuraEnabled public Decimal Program_Expenditure_Amount;
        @AuraEnabled public Decimal Sub_Contract_Expenditure_Amount;
        @AuraEnabled public String Contract;
        @AuraEnabled public String contractName;
        @AuraEnabled public Boolean hasLineItem; 
        @AuraEnabled public Decimal Activity_Allocated_Amount;
        @AuraEnabled public Decimal Program_Allocated_Amount;
        @AuraEnabled public Decimal Sub_Contract_Allocated_Amount;
        @AuraEnabled public String contractActivityName;
        @AuraEnabled public String contractActivityId;
        @AuraEnabled public Decimal Program_Support_Fee;
        @AuraEnabled public String contractGrant;
        @AuraEnabled public Boolean showActivityAllocatedAmount; 



        public ActivityAndExpenditure( Contract_Activity_Expenditure_Amount__c exp, Contract_Activity__c activityRecord ) {


            this.Id = exp.Id;
            this.Activity_Label = exp.Activity_Label__c;
            this.Program = exp.Program__c;
            this.Sub_Contractor = exp.Sub_Contractor__c;
            this.Activity_Expenditure_Amount = exp.Activity_Expenditure_Amount__c;
            this.Program_Expenditure_Amount = exp.Program_Expenditure_Amount__c;
            this.Sub_Contract_Expenditure_Amount = exp.Sub_Contract_Expenditure_Amount__c;
            this.Contract = exp.Contract__c;
            this.hasLineItem = false;
            
            if ( activityRecord != null ) {
                this.contractName = activityRecord.Contract__r.Name__c;

                this.contractActivityName = activityRecord.Name;
                this.contractActivityId = activityRecord.Id;
                this.contractGrant = activityRecord.Contract__r.grant__c;

                if (activityRecord.Contract_Configuration_Line_Item__c != null ) {
                    this.hasLineItem = true;
                    if ( activityRecord.Contract__r.grant__c == 'JJAC' ) {
                        this.showActivityAllocatedAmount = true;
                    }
                    else {
                        this.showActivityAllocatedAmount = false;

                    }
                    this.Activity_Allocated_Amount = activityRecord.Contract_Configuration_Line_Item__r.Activity_Allocated_Amount__c;
                    this.Program_Allocated_Amount = activityRecord.Contract_Configuration_Line_Item__r.Program_Allocated_Amount__c;
                    this.Sub_Contract_Allocated_Amount = activityRecord.Contract_Configuration_Line_Item__r.Sub_Contract_Allocated_Amount__c;   
                }      
            }
        }
    }
}