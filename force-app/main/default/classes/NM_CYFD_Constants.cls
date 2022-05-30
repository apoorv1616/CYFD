public with sharing class NM_CYFD_Constants {
    
    //Record Types
    Public static ID NM_CLIENTS_ACTIVITY_ROLE_RECORDTYPEID = Schema.SObjectType.Activity_Role__c.getRecordTypeInfosByName().get('Clients').getRecordTypeId();
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

    //invoice
    public static final String SUBMITTED_STATUS = 'Submitted';

    /*
        * Issue  : I-97887
        * Desc   : send notification when invoices are submitted
        * Author : Apoorv Anand
    */
    public static List<EmailTemplate> getEmailTemplateName( String templateName ) {

        return [SELECT Id 
                FROM EmailTemplate 
                WHERE DeveloperName = 'NM_CYFD_InvoiceSubmitted'];
    }
    
    /*
        * Issue  : I-97887
        * Desc   : send notification when invoices are submitted
        * Author : Apoorv Anand
    */
    public static Messaging.SingleEmailMessage createMailRecord( String contactId, String templateId, List<String> userIdList, Invoice__c invoiceRecord ) {

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // mail.setOrgWideEmailAddressId(owa.id);
        mail.setSaveAsActivity( false );
        mail.setTargetObjectId( contactId );
        mail.setTemplateID( templateId );
        mail.setWhatId( invoiceRecord.Id );
        mail.setToAddresses( userIdList );
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setSenderDisplayName('CYFD Team');
        return mail;
    }
}