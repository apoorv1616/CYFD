public with sharing class NM_CYFD_Constants {
    
    //Record Types
    Public static ID NM_CYFD_CONTRACT_ROLE_RECORDTYPEID = Schema.SObjectType.Contract_Role__c.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
    Public static ID NM_CYFD_DELIVERABLE_ACTIVITY_RECORDTYPEID = Schema.SObjectType.CYFD_Activity__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId();
    Public static ID NM_CYFD_DELIVERABLE_CONTRACTACTIVITY_RECORDTYPEID = Schema.SObjectType.Contract_Activity__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId();
    public static final String NM_BILLABLE_CONTRACT_ACTIVITY = 'Billable Activity';

    //Constant Picklist Values
    
    Public static final String NM_CYFD_CONTRACT_ROLE_STAFF = 'Staff';
    

    //Community Profile
    public static final String JCC_COMMUNITY_USER_PROFILE = 'JCC Community User';
    public static final String JJAC_COMMUNITY_USER_PROFILE = 'JJAC Community User';
    public static final String MENTORING_COMMUNITY_USER_PROFILE = 'Mentoring Community User';
    
}