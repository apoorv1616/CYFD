@isTest
public class NM_CYFD_GenerateInvoicePDFTest {
    @isTest
    public static void NM_CYFD_GenerateInvoicePDF_Test(){
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1, true);
        List<Contract_Configuration__c> configList = NM_CYFD_TestDataFactory.createContractConfigurationRecords(1, true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1, accountList[0].Id, configList[0].Id,'JCC', true);
        Invoice__c invoice = new Invoice__c();
        invoice.Invoice_Date__c = Date.newInstance(2020, 2, 11);
        invoice.Contract__c = contractList[0].Id;
       	insert invoice; 
        List<Invoice__c> invoiceList = [SELECT Id FROM Invoice__c LIMIT 1];
        List<Contract_Activity__c> activityList = NM_CYFD_TestDataFactory.createContractActivity(2, contractList[0].Id, 'Billable Activity', false);
        activityList[0].Invoice__c  = invoiceList[0].Id;
        activityList[1].Invoice__c = invoiceList[0].Id;
        insert activityList;
        Test.startTest();
        PageReference pageRef = Page.NM_CYFD_SurveyPDF;
        Test.setCurrentPage(pageRef);
     	pageRef.getParameters().put('Id', String.valueOf(invoiceList[0].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(invoiceList[0]);
        NM_CYFD_GenerateInvoicePDF generateInvoice = new NM_CYFD_GenerateInvoicePDF(sc);
        generateInvoice.keyList = new List<String>(); 
        Test.stopTest();
	}

}