global class NM_CYFD_InvoiceReminderBatch  implements Schedulable,Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC){
      //  Id recordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Activity__c','Billable Activity');
        Integer month = System.today().month();
       // Integer month = 1;
        Integer year = System.today().year();
        String query = 'SELECT Id, Contract__c, Contract__r.Account__c FROM Invoice__c WHERE Contract__r.Grant__c != \'JJAC\' AND CALENDAR_MONTH(CreatedDate) = ';
        query+=   month + ' AND CALENDAR_YEAR(CreatedDate) = ' + year;
        
        system.debug('query : ' + query);
        return Database.getQueryLocator(query);
   } 
 
   public void execute(Database.BatchableContext BC, List<Invoice__c> scope){
       
       Set<Id> accountIds = new Set<Id>();
       Set<Id> contactIdsSet = new Set<Id>();
       List<Id> contactIds = new List<Id>();
       system.debug('scope : ' + scope);
       for(Invoice__c ca : scope){
           accountIds.add(ca.Contract__r.Account__c);
       }
       
       for(Contract_Role__c cr : [SELECT Id, Contact__c, Contact__r.Name, Contact__r.Email FROM Contract_Role__c 
                                  WHERE Account__c IN: accountIds AND Contact__c != null 
                                  AND Contract_Role__c = 'Provider' AND Contact__r.Email != null ]){
           contactIdsSet.add(cr.Contact__c);
       }
       contactIds.addAll(contactIdsSet);
       system.debug('contactIds ' + contactIds);
       EmailTemplate tem=[Select id,name from EmailTemplate where name = 'NM CYFD Invoice Notification' limit 1];
        Messaging.MassEmailMessage Email = new Messaging.MassEmailMessage();
        Email.setTargetObjectIds(contactIds);
        Email.setSenderDisplayName('System Admin');
        Email.setTemplateId(tem.id);
        Messaging.sendEmail(new Messaging.MassEmailMessage[] { Email });
       
    }
 
   public void finish(Database.BatchableContext BC){
       
   }
    
    global void execute(SchedulableContext scon) {
      NM_CYFD_InvoiceReminderBatch b = new NM_CYFD_InvoiceReminderBatch(); 
        database.executebatch(b);
   }
}