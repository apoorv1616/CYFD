@isTest
public class NM_CYFD_TestDataFactory {
    
    public static List<Account> createAccounts(Integer num, Boolean doInsert) {
        List<Account> accounts = new List<Account>();
        for(integer i=0; i<num; i++ ){
            accounts.add(new Account(Name = 'NM CYFD Account'+i, Website = 'http://www.interactiveties.com/'));
        }
        if(doInsert){
            insert accounts; //insert the account list
        }
        return accounts;
    }
    
    public static List<Contact> createContacts(Integer num,Id accountId, Boolean doInsert) {
        List<Contact> contacts = new List<Contact>();
        for(integer i=0; i<num; i++ ){
            contacts.add(new Contact(AccountId = accountId, FirstName = 'Test Contact' + i, LastName = 'Record', email='test'+i+'@abcTesting.com')); //new Contact detail
        }
        if(doInsert){
            insert contacts; //insert the account list
        }
        return contacts;
    }
    
    public static List<User> createJCCPortalUserList(List<Contact> contacts, Boolean doInsert){       
        List<User> userList= new List<User>();
        for(integer i = 0; i<contacts.size(); i++)  {
            User user;
            user = new User();
            user.ProfileID = [Select Id From Profile Where Name='JCC Community User'].id;
            user.EmailEncodingKey = 'ISO-8859-1';
            user.LanguageLocaleKey = 'en_US';
            user.TimeZoneSidKey = 'America/New_York';
            user.LocaleSidKey = 'en_US';
            user.FirstName = 'first'+i;
            user.LastName = 'last'+i;
            user.Username = 'testPortalNMYFDPUser'+i+'@domain.com';   
            user.CommunityNickname = 'testUser123'+i;
            user.Alias = 't1'+i;
            user.Email = 'no'+i+'@email.com';
            user.IsActive = true;
            user.ContactId = contacts[i].Id;
            userList.add(user);
        }
        if(doInsert && !userList.isEmpty()){
            insert userList;
        }
        return userList;
    }
    
    public static List<User> createPortalUserList(List<Contact> contacts, String profileName, Boolean doInsert){       
        List<User> userList= new List<User>();
        for(integer i = 0; i<contacts.size(); i++)  {
            User user;
            user = new User();
            user.ProfileID = [Select Id From Profile Where Name=:  profileName].id;
            user.EmailEncodingKey = 'ISO-8859-1';
            user.LanguageLocaleKey = 'en_US';
            user.TimeZoneSidKey = 'America/New_York';
            user.LocaleSidKey = 'en_US';
            user.FirstName = 'first'+i;
            user.LastName = 'last'+i;
            user.Username = 'testPortalNMYFDPUser'+i+'@domain.com';   
            user.CommunityNickname = 'testUser123'+i;
            user.Alias = 't1'+i;
            user.Email = 'no'+i+'@email.com';
            user.IsActive = true;
            user.ContactId = contacts[i].Id;
            userList.add(user);
        }
        if(doInsert && !userList.isEmpty()){
            insert userList;
        }
        return userList;
    }
    
    public static List<Contract__c> createContractRecords(Integer numContract,Id accountId,Id config, String grant, Boolean doInsert) {
        List<Contract__c> contractList = new List<Contract__c>();
        for(integer i=0; i<numContract; i++ ){
            contractList.add(new Contract__c(Grant__c = grant ,  Contract_Number__c = '0001'+i,Account__c =accountId,Contract_Configuration__c = config ));
        }
        if(doInsert){
            insert contractList;
        }
        return contractList;
    }
    
    public static List<Contract_Configuration__c> createContractConfigurationRecords(Integer num, Boolean doInsert) {
        List<Contract_Configuration__c> contractConfigList = new List<Contract_Configuration__c>();
        for(integer i=0; i<num; i++ ){
            contractConfigList.add(new Contract_Configuration__c( Name__c = 'Contract Config Test'+ i ));
        }
        if(doInsert){
            insert contractConfigList;
        }
        return contractConfigList;
    }
    
    public static List<Contract_Configuration_Line_Item__c> createContractConfigurationLIRecords(Integer num,Id contractConfigId,Id CYFDActivityId ,Boolean doInsert) {
        List<Contract_Configuration_Line_Item__c> contractConfigLineItemList = new List<Contract_Configuration_Line_Item__c>();
        for(integer i=0; i<num; i++ ){
            contractConfigLineItemList.add(new Contract_Configuration_Line_Item__c( Contract_Configuration__c = contractConfigId , CYFD_Activity__c = CYFDActivityId));
        }
        if(doInsert){
            insert contractConfigLineItemList;
        }
        return contractConfigLineItemList;
    }
    
    public static List<CYFD_Activity__c> createDeliverableCYFDActivityRec(Integer num,Boolean doInsert){
        List<CYFD_Activity__c> CYFDActivityList =  new List<CYFD_Activity__c>();
        Id deliverableRecordId = NM_CYFD_Utility.getRecordTypeId('CYFD_Activity__c','Deliverable');
        if(deliverableRecordId != null){
            for(integer i=0; i<num; i++ ){
                CYFDActivityList.add(new CYFD_Activity__c(Name__c    = 'Test '+i+'', RecordTypeId = deliverableRecordId,Activity_Rate__c = i));
            }
            if(doInsert){
                insert CYFDActivityList;
            } 
        }
        
        return CYFDActivityList;
    }
    public static List<Contract_Activity__c> createDeliverableContractActivityRec(Integer num,Id ContractId, Boolean doInsert) {
        List<Contract_Activity__c> contractActivityList = new List<Contract_Activity__c>();
        Id deliverableRecordId = NM_CYFD_Utility.getRecordTypeId('Contract_Activity__c', 'Deliverable');
        if(deliverableRecordId != ''){
            for(integer i=0; i<num; i++ ){
                contractActivityList.add(new Contract_Activity__c(Contract__c = ContractId, RecordTypeId = deliverableRecordId));
            }
            if(doInsert){
                insert contractActivityList;
            } 
        }
        
        return contractActivityList;
    }
    
    public static List<Contract_Activity__c> createBillableContractActivityRec(Integer num,Id ContractId, Boolean doInsert) {
        List<Contract_Activity__c> contractActivityList = new List<Contract_Activity__c>();
        Id billableRecordID = NM_CYFD_Utility.getRecordTypeId('Contract_Activity__c', 'Billable Activity');
        if(billableRecordID != null){
            for(integer i=0; i<num; i++ ){
                contractActivityList.add(new Contract_Activity__c(Contract__c = ContractId, RecordTypeId = billableRecordID));
            }
            if(doInsert){
                insert contractActivityList;
            } 
        }
        
        return contractActivityList;
    }
    
    public static List<Contract_Role__c> createContractRole(Integer num,Date birthDate,Id providerId,Id ContactId, String recordType, Boolean doInsert) {
        List<Contract_Role__c> contractRoleList = new List<Contract_Role__c>();
        Id clientRecordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Role__c', recordType);
        if(clientRecordTypeId != null){
            for(integer i=0; i<num; i++ ){
                contractRoleList.add(new Contract_Role__c(Account__c = providerId, RecordTypeId = clientRecordTypeId,Contact__c = ContactId,First_Name__c = 'Test1'+i,Last_Name__c = String.valueOf(i),Date_of_Birth__c = birthDate-i ));
            }
            if(doInsert){
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.AllowSave = true; 
                //insert contractRoleList;
                Database.insert(contractRoleList, dml);
            } 
        }
        
        return contractRoleList;
    }
    
    
    public static List<Invoice__c> createInvoiceRecords(Integer num,Id contractId,Date invoiceDate, Boolean doInsert) {
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        for(integer i=0; i<num; i++ ){
            invoiceList.add(new Invoice__c( Contract__c =contractId, status__c = 'New' ,Invoice_Date__c = invoiceDate ));
        }
        if(doInsert){
            insert invoiceList;
        }
        return invoiceList;
    }
    
    public static List<Payment__c> createPayment(Integer num,Id invoiveId, Boolean doInsert) {
        List<Payment__c> paymentList = new List<Payment__c>();
        for(integer i=0; i<num; i++ ){
            paymentList.add(new Payment__c( Invoice__c =invoiveId, Voucher_Number__c = '001'+i,Reference_Number__c ='01001'+i));
        }
        if(doInsert){
            insert paymentList;
        }
        return paymentList;
    }
    
    public static List<Activity_Role__c> createPayment(Integer num,Id contractActivity,Id contractRole, Boolean doInsert) {
        List<Activity_Role__c> activityRoleList = new List<Activity_Role__c>();
        for(integer i=0; i<num; i++ ){
            activityRoleList.add(new Activity_Role__c( Contract_Activity__c =contractActivity, Contract_Role__c = contractRole));
        }
        if(doInsert){
            insert activityRoleList;
        }
        return activityRoleList;
    }
    
    
    //Added by Anushka
    public static List<Contract_Activity__c> createContractActivity(Integer num,Id ContractId, String recordType, Boolean doInsert) {
        List<Contract_Activity__c> contractActivityList = new List<Contract_Activity__c>();
        Id recordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Activity__c', recordType);
        if(recordTypeId != null){
            for(integer i=0; i<num; i++ ){
                contractActivityList.add(new Contract_Activity__c(Contract__c = ContractId, RecordTypeId = recordTypeId));
            }
            if(doInsert){
                insert contractActivityList;
            } 
        }
        
        return contractActivityList;
    }
    
    public static List<CYFD_Activity__c> createCYFDActivity(Integer num,String recordType, Boolean doInsert){
        List<CYFD_Activity__c> CYFDActivityList =  new List<CYFD_Activity__c>();
        Id recordTypeId = NM_CYFD_Utility.getRecordTypeId('CYFD_Activity__c',recordType);
        if(recordTypeId != null){
            for(integer i=0; i<num; i++ ){
                CYFDActivityList.add(new CYFD_Activity__c(Name__c    = 'Test '+i+'', RecordTypeId = recordTypeId, Activity_Rate__c = i));
            }
            if(doInsert){
                insert CYFDActivityList;
            } 
        }
        
        return CYFDActivityList;
    }
}