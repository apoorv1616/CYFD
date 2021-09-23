public without sharing class NM_CYFD_RefreshInvoiceCtrl {
    
    @AuraEnabled
    public static string refreshInvoiceWithActivity( String recordId ) {
        try {
            List<Contract_Activity__c> conActivityList = new List<Contract_Activity__c>();
            Map<String,Id> invoiceMap = new Map<String,Id>();

            Invoice__c invoice = [SELECT Id, Invoice_Date__c, Amount__c , Contract__c,Status__c FROM Invoice__c WHERE Id =: recordId];

            Date t = invoice.Invoice_Date__c;
            
            Integer month = t.month();
            Integer year = t.year();
            Date start = Date.newInstance(year, month, 1);
            
            if( invoice.Status__c != null && (invoice.Status__c == NM_CYFD_Utility.REJECTED_STATUS || invoice.Status__c == NM_CYFD_Utility.NEW_STATUS ) ){
            
                String query = 'SELECT Id FROM Contract_Activity__c WHERE Contract__c =: invoice.Contract__c AND ';
                query += ' RecordType.Name = \'Billable Activity\' AND Invoice__c = null AND CALENDAR_MONTH(Date__c) <= '  + month;

                List<Contract_Activity__c> contractActivityList = [SELECT Id FROM Contract_Activity__c 
                                                                   WHERE Contract__c =: invoice.Contract__c AND Date__c <: start
                                                                   AND RecordType.Name = 'Billable Activity' AND Invoice__c = null]; 
                
                for(Contract_Activity__c ca : contractActivityList){
                    ca.Invoice__c = invoice.Id;                    
                }

                /*
                    * Author : Apoorv Anand
                    * Desc   : Invoice Amount should be recalculated in Invoice once the linked activities are moved to another existing invoices.
                    * Issue  : I-66179
                */
                NM_CYFD_ContractActivityTriggerHandler.rollUpInvoiceAmount(new Set<Id>{ invoice.Id });  
              
                if( !contractActivityList.isEmpty() ) {

                    update contractActivityList;
                    return 'Success';
                }
                else {  
                                   
                    return 'No Activities to update';                    
                }
            }
            else {
                return 'Invoice must be in New/Rejected status';
            }          
           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
        @desc : Contract Activities can be deleted where invoices are null, new or rejected and activity roles related to CA are deleted.

    */
   @AuraEnabled
    public static Map<String, Object> deleteContractActivity( String recordId ) {

        Boolean responseResult = false;

        try {
            Map<String, Object> response = new Map<String, Object>();
            List<Activity_Role__c> rolesToDelete = new List<Activity_Role__c>();

            List<Contract_Activity__c> contractActivities =  [ SELECT Id,Sub_Contractor__c,Program__c,Date__c,Activity_Label__c,Invoice_Amount__c,
                                                            Invoice__c,Contract__c, Contract__r.Grant__c, Invoice__r.Status__c,
                                                              Activity_Expenditure_Amount__c,Program_Expenditure_Amount__c, 
                                                              Sub_Contract_Expenditure_Amount__c,
                                                            ( SELECT Id FROM Activity_Roles__r ) 
                                                            FROM Contract_Activity__c
                                                            WHERE ID = :recordId
                                                            ];

            
            if( !contractActivities.isEmpty() ) { 

                //only those Contract Activities can be deleted where invoices are null, new or rejected.
                if(contractActivities[0].Invoice__c == null 
                    || contractActivities[0].Invoice__r.Status__c == NM_CYFD_Utility.NEW_STATUS
                    || contractActivities[0].Invoice__r.Status__c == NM_CYFD_Utility.REJECTED_STATUS ) {
                    
                    rolesToDelete.addAll(contractActivities[0].Activity_Roles__r);
                    
                    Boolean isMentoring = contractActivities[0].Contract__r.Grant__c == NM_CYFD_Utility.MENTORING_GRANT ? true : false;

                    String subContractor = contractActivities[0].Sub_Contractor__c;
                    String program = contractActivities[0].Program__c;
                    Date activityDate = contractActivities[0].Date__c;
                    String label = contractActivities[0].Activity_Label__c;
                    String contractId = contractActivities[0].Contract__c;

                    if( !rolesToDelete.isEmpty() ) {
                        delete rolesToDelete;
                        responseResult = true;
                    }

                    if ( !contractActivities.isEmpty() ) {
                        delete contractActivities[0];
                        responseResult = true;
                    }

                    response.put('contractId', contractId);
                    //response.put('result', true);
                    response.put('result', responseResult);


                    return response;
                }
            }
            
            response.put('result', responseResult);
            return response;  
            
        }
        catch ( Exception e ) {
            throw new AuraHandledException( e.getMessage() );
        }    
        
    }
    
    @AuraEnabled
    public static Map<String, Object> submitInvoice( String recordId, String userId ) {
        Map<String, Object> response = new Map<String, Object>();

        Invoice__c invoice = [SELECT Id, Contract__c,Status__c FROM Invoice__c WHERE Id =: recordId];

        if(invoice.Status__c == NM_CYFD_Utility.NEW_STATUS || invoice.Status__c == NM_CYFD_Utility.REJECTED_STATUS ) {

            invoice.Status__c = NM_CYFD_Utility.SUBMITTED_STATUS;
            invoice.User__c = userId;

            NM_CYFD_InvoiceTriggerHandler.bypassError = true;
            
            update invoice;

            response.put('success', true);   
            
        }
        else{

            response.put('success', false);  
        }

       return response; 
    }
}