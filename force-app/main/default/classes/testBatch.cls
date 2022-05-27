public with sharing class testBatch implements Database.Batchable<sObject> {
    
    public List<Id> contractIdList = new List<Id>();
    
    public static Id ACTIVITY_EXPENDITURE_RECORDTYPE = NM_CYFD_Utility.ACTIVITY_EXPENDITURE_RECORDTYPE;
    public static Id PROGRAM_EXPENDITURE_RECORDTYPE = NM_CYFD_Utility.PROGRAM_EXPENDITURE_RECORDTYPE;
    public static Id SUBCONTRACTOR_EXPENDITURE_RECORDTYPE = NM_CYFD_Utility.SUBCONTRACTOR_EXPENDITURE_RECORDTYPE;
    public static String BILLABLE_ACTIVITY_RECORDTYPE = NM_CYFD_Utility.BILLABLE_ACTIVITY_RECORDTYPE;

    public testBatch() {}
    
    public testBatch(List<Id> contractIdList) {
        if( !contractIdList.isEmpty() ) {
            this.contractIdList = contractIdList;
        }
    }  
	
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = ' SELECT Id, Name '
            		 + ' FROM Contract__c ';
            		
        if( !contractIdList.isEmpty() ) {
            query += ' WHERE Id IN :contractIdList ';
        } 
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Contract__c> scope) {

        Map<String, Contract_Activity_Expenditure_Amount__c> insertContractActivityExpenditureMap = new Map<String, Contract_Activity_Expenditure_Amount__c>();
        Map<String, Decimal> mapOfContractIdAndActivityLabelBySum = new Map<String, Decimal>();
        Map<String, Decimal> mapOfContractIdAndProgramBySum = new Map<String, Decimal>();
        Map<String, Decimal> mapOfContractIdAndSubcontractorBySum = new Map<String, Decimal>();

        for ( AggregateResult aggregateResult :[
            SELECT sum(Invoice_Amount__c) expAmount, Hidden_Activity_Label__c, Contract__c 
            FROM Contract_Activity__c  
            GROUP BY Hidden_Activity_Label__c,Contract__c, RecordType.DeveloperName
            HAVING Contract__c IN :scope
            //AND Hidden_Activity_Label__c IN :activityLabelSet
            AND RecordType.DeveloperName = :BILLABLE_ACTIVITY_RECORDTYPE
        ]) {
            String contractId = (String)aggregateResult.get('Contract__c');
            String activityLabel = (String)aggregateResult.get('Hidden_Activity_Label__c');
            Decimal invoiceAmount = (Decimal)aggregateResult.get('expAmount');
            mapOfContractIdAndActivityLabelBySum.put( contractId + '#' + activityLabel, invoiceAmount );    
        }

        for ( AggregateResult aggregateResult : [
            SELECT sum(Invoice_Amount__c) expAmount, Program__c, Contract__c 
            FROM Contract_Activity__c  
            GROUP BY Program__c,Contract__c, RecordType.DeveloperName
            HAVING Contract__c IN :scope
            //AND Program__c IN :programSet
            AND RecordType.DeveloperName = :BILLABLE_ACTIVITY_RECORDTYPE
        ]) {
            
            String contractId = (String)aggregateResult.get('Contract__c');
            String program = (String)aggregateResult.get('Program__c');
            Decimal invoiceAmount = (Decimal)aggregateResult.get('expAmount');
            mapOfContractIdAndProgramBySum.put( contractId + '#' + program, invoiceAmount );    
        }

        for ( AggregateResult aggregateResult : [
            SELECT sum(Invoice_Amount__c) expAmount, Sub_Contractor_For_Script__c, Contract__c 
            FROM Contract_Activity__c  
            GROUP BY Sub_Contractor_For_Script__c,Contract__c, RecordType.DeveloperName
            HAVING Contract__c IN :scope
            //AND Sub_Contractor_For_Script__c IN :subcontractorSet
            AND RecordType.DeveloperName = :BILLABLE_ACTIVITY_RECORDTYPE
        ]) {
            
            String contractId = (String)aggregateResult.get('Contract__c');
            String subContractor = (String)aggregateResult.get('Sub_Contractor_For_Script__c');
            Decimal invoiceAmount = (Decimal)aggregateResult.get('expAmount');
            mapOfContractIdAndSubcontractorBySum.put( contractId + '#' + subContractor, invoiceAmount );    
        }
        for(Contract_Activity__c contractActivity : 
            [SELECT Id, Activity_Label__c, Sub_Contractor__c, Program__c, contract__c FROM Contract_Activity__c 
            WHERE contract__c IN :scope]) {
                
            if (String.isNotBlank(contractActivity.Activity_Label__c) 
                && 
                !insertContractActivityExpenditureMap.containsKey(contractActivity.contract__c + '#' + contractActivity.Activity_Label__c)
            ) {
    
                String key = contractActivity.contract__c + '#' + contractActivity.Activity_Label__c;
                Decimal amount = mapOfContractIdAndActivityLabelBySum.containsKey(key) ? mapOfContractIdAndActivityLabelBySum.get(key) : 0;
                insertContractActivityExpenditureMap.put(key, createCAE(contractActivity.Activity_Label__c, 'Activity', amount, contractActivity.contract__c));
            } 
            if (String.isNotBlank(contractActivity.Program__c) 
                && 
                !insertContractActivityExpenditureMap.containsKey(contractActivity.contract__c + '#' + contractActivity.Program__c)
            ) {
    
                String key = contractActivity.contract__c + '#' + contractActivity.Program__c;
                Decimal amount = mapOfContractIdAndProgramBySum.containsKey(key) ? mapOfContractIdAndProgramBySum.get(key) : 0;
                insertContractActivityExpenditureMap.put(key, createCAE(contractActivity.Program__c, 'Program', amount, contractActivity.contract__c));
            } 
            if (String.isNotBlank(contractActivity.Sub_Contractor__c) 
                && 
                !insertContractActivityExpenditureMap.containsKey(contractActivity.contract__c + '#' + contractActivity.Sub_Contractor__c)
            ) {
    
                String key = contractActivity.contract__c + '#' + contractActivity.Sub_Contractor__c;
                Decimal amount = mapOfContractIdAndSubcontractorBySum.containsKey(key) ? mapOfContractIdAndSubcontractorBySum.get(key) : 0;
                insertContractActivityExpenditureMap.put(key, createCAE(contractActivity.Sub_Contractor__c, 'Sub Contractor', amount, contractActivity.contract__c));
            } 
        }
        
        if (!insertContractActivityExpenditureMap.isEmpty()) 
            insert insertContractActivityExpenditureMap.values();
        
    }
    
    public void finish(Database.BatchableContext BC) {}

    public static Contract_Activity_Expenditure_Amount__c createCAE(String label, String RecordTypeName, Decimal amount, Id contract ) {

        Contract_Activity_Expenditure_Amount__c expenditureRecord = new Contract_Activity_Expenditure_Amount__c();
        if (RecordTypeName == 'ACTIVITY') {
            expenditureRecord.RecordTypeId = ACTIVITY_EXPENDITURE_RECORDTYPE;
            expenditureRecord.Activity_Expenditure_Amount__c = amount;
            expenditureRecord.Activity_Label__c = label;
        } else if (RecordTypeName == 'Sub Contractor') {
            expenditureRecord.RecordTypeId = SUBCONTRACTOR_EXPENDITURE_RECORDTYPE;
            expenditureRecord.Sub_Contractor__c = label;
            expenditureRecord.Sub_Contract_Expenditure_Amount__c = amount;
        } else if (RecordTypeName == 'Program') {
            expenditureRecord.RecordTypeId = PROGRAM_EXPENDITURE_RECORDTYPE;
            expenditureRecord.Program__c = label;
            expenditureRecord.Program_Expenditure_Amount__c = amount;
        }
        expenditureRecord.contract__c = contract;
        return expenditureRecord;

    }
}