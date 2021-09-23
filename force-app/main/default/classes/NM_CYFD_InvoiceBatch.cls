global class NM_CYFD_InvoiceBatch  implements Schedulable,Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC){
        Id recordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Activity__c','Billable Activity');
        String query = 'SELECT Id,Date__c,Contract__c,Invoice__c,RecordTypeId FROM Contract_Activity__c WHERE Contract__r.Grant__c != \'JJAC\' AND Invoice__c = null aND Date__c != NULL AND RecordTypeId =: recordTypeId ORDER BY Contract__c';
        return Database.getQueryLocator(query);
   }
 
   public void execute(Database.BatchableContext BC, List<Contract_Activity__c> scope){
       
       Set<Id> contractIds = new Set<Id>();
       List<Invoice__c> invoicesToInsert = new List<Invoice__c>();
       Map<String, Invoice__c> existingInvoiceMap = new Map<String, Invoice__c>();
       Map<String, Invoice__c> newInvoiceMap = new Map<String, Invoice__c>();
       List<Contract_Activity__c> activitiesForNewInvoices = new List<Contract_Activity__c>();
       Integer month = System.today().month();
       Integer year = System.today().year();
       
       for(Contract_Activity__c ca : scope) {
            if(ca.Date__c.month() == month && ca.Date__c.year() == year){continue;}
                
            contractIds.add(ca.Contract__c);
       }
       
       
       for(Invoice__c i : [SELECT Id, Contract__c, Contract__r.Name, Status__c, Invoice_Date__c FROM Invoice__c 
           WHERE Contract__c in: contractIds AND CALENDAR_MONTH(Invoice_Date__c) =: month  AND
           CALENDAR_YEAR(Invoice_Date__c) =: year]){
           existingInvoiceMap.put(i.Contract__c, i);           
       }
       
       List<Invoice__c> invoices = new List<Invoice__c>();
       for(String contractId : contractIds){
           if(!existingInvoiceMap.containsKey(contractId)){
               Invoice__c inv = new Invoice__c();
               inv.Status__c = 'New';
               inv.Contract__c = contractId;
               inv.Invoice_Date__c = Date.newInstance(year,month,11); 
               invoices.add(inv);
            }
       }
       
       insert invoices;
       
      /* system.debug('existingInvoiceMap ' + existingInvoiceMap);       
       
       for(Contract_Activity__c ca : scope){
              if(ca.Date__c.month() == month && ca.Date__c.year() == year){continue;}
           
               Invoice__c inv = new Invoice__c();
               inv.Status__c = 'New';
               inv.Contract__c = ca.Contract__c;
               inv.Invoice_Date__c = Date.newInstance(year,month,11);  
               
               if(!existingInvoiceMap.containsKey(ca.Contract__c) && !newInvoiceMap.containsKey(ca.Contract__c)){
                   newInvoiceMap.put(ca.Contract__c, inv);    
               }
           
       }
       insert newInvoiceMap.values();*/
       
       for(Invoice__c i : invoices){
           existingInvoiceMap.put(i.Contract__c, i);    
       }
       
       for(Contract_Activity__c ca : scope) {
           if(ca.Date__c.month() == month && ca.Date__c.year() == year){continue;}
           
           if(existingInvoiceMap.containsKey(ca.Contract__c) && 
               existingInvoiceMap.get(ca.Contract__c).Status__c != 'Submitted'){
               ca.Invoice__c = existingInvoiceMap.get(ca.Contract__c).Id;
               activitiesForNewInvoices.add(ca);
           }
       }
       
       if(!activitiesForNewInvoices.isEmpty())
        update activitiesForNewInvoices;
       
    }
 
   public void finish(Database.BatchableContext BC){
       
   }
    
    global void execute(SchedulableContext scon) {
      NM_CYFD_InvoiceBatch b = new NM_CYFD_InvoiceBatch(); //ur batch class
        database.executebatch(b);
   }
}