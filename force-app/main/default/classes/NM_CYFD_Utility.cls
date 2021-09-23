public with sharing class NM_CYFD_Utility {
    
    //Record Types
    public static ID NM_CYFD_CONTRACT_ROLE_RECORDTYPEID = Schema.SObjectType.Contract_Role__c.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
    public static List<String> CLIENT_CONTRACT_ROLES = new List<String>{'JCC', 'JJAC', 'Mentoring'};
    
    //Constant Picklist Values
    public static final String NM_CYFD_PORTALPROFILENAME = 'Provider';
    public static final String NM_CYFD_CONTRACT_ROLE_STAFF = 'Staff';

    //Added as a part of architecture change
    public static final String CLIENT_RECORDTYPE = 'Clients';
    public static final String CLIENT_RECORDTYPEId = getRecordTypeId('Activity_Role__c','Clients');

    public static final String MENTORING_GRANT = 'Mentoring';
    public static final String JCC_GRANT = 'JCC';
    public static final String JJAC_GRANT = 'JJAC';

    public static final String NEW_STATUS = 'New';
    public static final String REJECTED_STATUS = 'Rejected';
    public static final String  SUBMITTED_STATUS = 'Submitted';

    public static final String  BILLABLE_ACTIVITY_RECORDTYPE = 'Billable_Activity';
    
    public static final String EXPENDITURE_AMOUNT_OBJECT = 'Contract_Activity_Expenditure_Amount__c';

    public static final Id ACTIVITY_EXPENDITURE_RECORDTYPE = getRecordTypeId('Contract_Activity_Expenditure_Amount__c','Activity Expenditure');
    public static final Id PROGRAM_EXPENDITURE_RECORDTYPE = getRecordTypeId('Contract_Activity_Expenditure_Amount__c','Program Expenditure');
    public static final Id SUBCONTRACTOR_EXPENDITURE_RECORDTYPE = getRecordTypeId('Contract_Activity_Expenditure_Amount__c','Sub-Contractor Expenditure');
  
    public static Id getRecordTypeId(String objAPIName, String type){
        return Schema.getGlobalDescribe().get(objAPIName).getDescribe().getRecordTypeInfosByName().get(type).getRecordTypeId();
        
    }
    
    
    @AuraEnabled
    public static List<SelectOptionWrapper> fetchPicklist(String objectName, String fieldName){
        List<SelectOptionWrapper> opts = new List<SelectOptionWrapper>();
        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            opts.add( new SelectOptionWrapper( pickListVal.getValue(), pickListVal.getLabel())  );
        }    
        
        return opts;
    }
    public class SelectOptionWrapper{
        @AuraEnabled public string value;
        @AuraEnabled public string label;
        @AuraEnabled public Boolean selected;
        
        public SelectOptionWrapper(string value, string label){
            this.value = value;
            this.label = label;
            this.selected = false;
        }
    }
  /*  
    @AuraEnabled(cacheable=true)
    public static List<Steps_Configuration__mdt > getNavigationNodes(String flowType) {
        List< Steps_Configuration__mdt > resultRecords = [SELECT MasterLabel, DeveloperName, Step_Number__c FROM Steps_Configuration__mdt 
          WHERE Active__c = true AND Flow_Type__c =: flowType ORDER BY Step_Number__c ASC];
        return resultRecords;
    }*/
    
    @AuraEnabled(cacheable=true)
    public static List<StepsWrapper> getNavigationNodes(String flowType) {
    List< Steps_Configuration__mdt > resultRecords = [SELECT MasterLabel, Instructions__c, DeveloperName, Step_Number__c FROM Steps_Configuration__mdt 
          WHERE Active__c = true AND Flow_Type__c =: flowType ORDER BY Step_Number__c ASC];
        List<StepsWrapper> steps = new List<StepsWrapper>();
        for(Steps_Configuration__mdt  sc : resultRecords){
            StepsWrapper step = new StepsWrapper();
            step.name = sc.MasterLabel;
            step.instructions = sc.Instructions__c;
            step.stepNumber = Integer.valueOf(sc.Step_Number__c);
            steps.add(step);
        }
        return steps;
    }
    
    public class StepsWrapper{
        @AuraEnabled public String name;
        @AuraEnabled public String instructions;
        @AuraEnabled public Integer stepNumber;       
    }
}