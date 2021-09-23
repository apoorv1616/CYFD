public without sharing class NM_CYFD_InvoiceTriggerHandler {
    public static Boolean bypassError = false;
    public static Boolean stopRecurssion = false;
    
    public static void afterInsert( List<Invoice__c> newList ) {
        rollUpInvoiceAmountToInvoice(newList, null);
    }
    
    public static void beforeUpdate(List<Invoice__c> newList, Map<Id,Invoice__c> oldMap){
        onStatusUpdate(newList, oldMap);
        createPaymentRecordsOnInvoiceAccept(newList, oldMap);
        throwErrorIfPaidStatusIsChanged(newList, oldMap);
     }
    
    public static void afterUpdate(List<Invoice__c> newList, Map<Id,Invoice__c> oldMap) {
        updateInvoiceStatusOnPayment(newList, oldMap);
        rollUpInvoiceAmountToInvoice(newList, oldMap);
    }
	

    public static void rollUpInvoiceAmountToInvoice(List<Invoice__c> newList, Map<Id,Invoice__c> oldMap) {
        Set<Id> invoiceIdSet = new Set<Id>();
        
        for(Invoice__c invoiceRecord : newList) {
            
            if(oldMap == null 
               || 
               (invoiceRecord.Invoice_Total__c != oldMap.get(invoiceRecord.Id).Invoice_Total__c
               ||
               invoiceRecord.Match_Amount__c != oldMap.get(invoiceRecord.Id).Match_Amount__c )) {
                	
                   invoiceIdSet.add( invoiceRecord.Id );
            }
        }
        
        if (!invoiceIdSet.isEmpty() ) {
            stopRecurssion = true;
            NM_CYFD_ContractActivityTriggerHandler.rollUpInvoiceAmount( invoiceIdSet );
        }
    } 
    
    public static void throwErrorIfPaidStatusIsChanged(List<Invoice__c> newList, Map<Id,Invoice__c> oldMap) {
        String error = 'As a CYFD Program Manager you can only change the status of an invoice {0} to either Approved or Rejected.';
        
        for(Invoice__c invoiceRecord : newList) {
            if(invoiceRecord.Status__c != oldMap.get(invoiceRecord.Id).Status__c) {
                if(oldMap.get(invoiceRecord.Id).Status__c == 'Paid')
                    //invoiceRecord.Status__c.addError(String.format(error, new List<String>{'from Paid'}));
                	invoiceRecord.Status__c.addError('You cannot change the status once it is paid');
                /*if((oldMap.get(invoiceRecord.Id).Status__c != 'Approved'
                    && invoiceRecord.Status__c == 'Paid'))
                    invoiceRecord.Status__c.addError(String.format(error, new List<String>{''})); */
                
                if(invoiceRecord.Status__c != 'Approved' 
                    && invoiceRecord.Status__c != 'Rejected'
                    //&& Userinfo.getUserType() == 'Standard'
                  	&& !bypassError)
                    
                    invoiceRecord.Status__c.addError(String.format(error, new List<String>{''}));
            }
        }
    }
    
    /*
     * Author : Apoorv Anand 
     * Desc   : Update Invoice status on payment for payment trigger to fire and calculate rollUpAmountToContract().
      			(Before Update)
     * Issue  : I-55358
    */
    public static void updateInvoiceStatusOnPayment(List<Invoice__c> newList, Map<Id,Invoice__c> oldMap) {
        Set<Id> invoiceIdSet = new Set<Id>(); 
        for(Invoice__c invoiceRecord : newList) {
            if(invoiceRecord.Status__c != oldMap.get(invoiceRecord.Id).Status__c) {
                   
                   invoiceIdSet.add(invoiceRecord.Id);     
               }
        }
        
        if(!invoiceIdSet.isEmpty()) {
            List<Payment__c> paymentList = [SELECT Id, invoice__r.Contract__c, Invoice__c, Match_Amount__c, Payment_Amount__c 
                                           FROM Payment__c
                                           WHERE Invoice__c IN :invoiceIdSet];
            if(!paymentList.isEmpty()) {
                
                NM_CYFD_PaymentTriggerHandler.rollUpAmountToContract(paymentList, null);
            }
        }
    }
    
    /*
     * Author : Apoorv Anand 
     * Desc   : create payment records when status is approved of invoices.
      			(Before Update)
     * Issue  : I-55358
    */
    private static void createPaymentRecordsOnInvoiceAccept(List<Invoice__c> newList, Map<Id,Invoice__c> oldMap) {

       Set<Id> invoiceIdSet = new Set<Id>();
       List<Payment__c> paymentList = new List<Payment__c>();
        //1. Get Invoices with approved status.
        for(Invoice__c invoiceRecord : newList) {
        
            if(invoiceRecord.Status__c == 'Approved') {
                if(oldMap == null 
                   || (oldMap.get(invoiceRecord.Id).Status__c != invoiceRecord.Status__c)) {
                       
                    invoiceIdSet.add(invoiceRecord.Id);  
                }
            }
        }
        
        if(!invoiceIdSet.isEmpty()) {
            //2. Check if payment already exist on that invoice.
            Set<Id> invoiceIdAlreadyHavingPaymentSet = new Set<Id>();
            
            for(Payment__c paymentRecord : [SELECT Id, Invoice__c
                                           FROM Payment__c
                                           WHERE Invoice__c IN :invoiceIdSet]) {
                                               
                invoiceIdAlreadyHavingPaymentSet.add(paymentRecord.Invoice__c);                               
           }
            //3. Insert payment only when no payment previously exist on the invoice.
            for(Id invoiceId : invoiceIdSet) {
                if(!invoiceIdAlreadyHavingPaymentSet.contains(invoiceId)) {
                    paymentList.add(createPayment(invoiceId));
                }
            }
            //4.Insert payment
            if(!paymentList.isEmpty()) {
                NM_CYFD_PaymentTriggerHandler.throwError = true;
                insert paymentList;
            }
        }
    }
    
    private static Payment__c createPayment(Id invoiceId) {
        Payment__c paymentRecord = new Payment__c();
        paymentRecord.Invoice__c = invoiceId;
        
        return paymentRecord;
    }
    
    public static void onStatusUpdate(List<Invoice__c> newList, Map<Id,Invoice__c> oldMap){
        
        List<Invoice__c> invoicesToPostChatter = new List<Invoice__c>();
        for(Invoice__c inv : newList){
            if(oldMap != null && inv.Status__c == 'Submitted' && inv.Status__c != oldMap.get(inv.Id).Status__c){
                system.debug('inv.LastModifiedById '+ inv.LastModifiedById);
                
                //inv.User__c = inv.LastModifiedById;
                /*
                    * Author : Apoorv Anand
                    * Issue  : I-46156
                    * Desc   : Update user on invoice with the current user.
                */
                inv.User__c = userInfo.getUserId();
            }
            
            if(oldMap != null && (inv.Status__c == 'Rejected' || inv.Status__c == 'Approved') && inv.Status__c != oldMap.get(inv.Id).Status__c){
                    invoicesToPostChatter.add(inv);
            }
        }
        
        if(!invoicesToPostChatter.isEmpty())
            postChatter(invoicesToPostChatter);
    }
    
    
    public static void postChatter(List<Invoice__c> invoices){
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        for(Invoice__c c : invoices){
            
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            //Mention user here
            mentionSegmentInput.id = c.User__c;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            
            textSegmentInput.text = '\n'+' The invoice has been ' + c.Status__c;
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = c.Id;
            feedItemInput.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;
            
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
            batchInputs.add(batchInput);
            
        }
       ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchinputs);
    }
    
}