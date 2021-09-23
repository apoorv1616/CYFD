@isTest
public class NmcyfdExprenditureAmountOnCACtrlTest {
	
    @testSetup
    static void setupData() {
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1,true);
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1,accountList[0].Id,null,'JCC', true);
        List<CYFD_Activity__c> CYFD_ActivityList = NM_CYFD_TestDataFactory.createCYFDActivity(1,'Deliverable',true);
        List<Contract_Activity__c> activityList= NM_CYFD_TestDataFactory.createContractActivity(1,contractList[0].Id ,'Billable Activity', false);
        
        activityList[0].program__c = 'test';
        activityList[0].Program_Expenditure_Amount__c = 100;
        insert activityList;
        
        Contract_Activity_Expenditure_Amount__c exp = new Contract_Activity_Expenditure_Amount__c();
        exp.program__c = 'test';
        exp.Program_Expenditure_Amount__c = 100;
        exp.RecordTypeId = NM_CYFD_Utility.PROGRAM_EXPENDITURE_RECORDTYPE;
        exp.Contract__c = contractList[0].id;
        insert exp;
    }
    
    @isTest
    static void testGetMatchExpenditure() {
         List<Contract__c> contractList = [SELECT Id 
                                          FROM Contract__c];
        List<Contract_Activity__c> activityList = [SELECT Id, Match_Amount__c 
                                                   FROM Contract_Activity__c 
                                                   WHERE Program__c = 'test'];
        activityList[0].Match_Amount__c = 10;
        update activityList;
        
        Test.startTest();
        	List<Contract_Activity__c> contractActivityList = NmcyfdExprenditureAmountOnCAController.getMatchExpenditure( contractList[0].Id, 'Name', true );
        Test.stopTest();
        
        System.assertNotEquals(0, contractActivityList.size(), 'size of contractActivityList should be 1');
    }
    
    @isTest
    static void testGetExpenditureAmountFromCA() {
        List<Contract_Activity__c> activityList = [SELECT Id 
                                                   FROM Contract_Activity__c 
                                                   WHERE Program__c = 'test'];
        Test.startTest();
        	List<NmcyfdExprenditureAmountOnCAController.ActivityAndExpenditure> expList = NmcyfdExprenditureAmountOnCAController.getExpenditureAmount( activityList[0].Id );
        Test.stopTest();
        
        System.assertEquals(1, expList.size(), 'size of expList should be 1');
    }
    
    @isTest
    static void testGetExpenditureAmountFromContract() {
        List<Contract__c> contractList = [SELECT Id 
                                          FROM Contract__c];
        Test.startTest();
        	List<NmcyfdExprenditureAmountOnCAController.ActivityAndExpenditure> expList = NmcyfdExprenditureAmountOnCAController.getExpenditureAmount( contractList[0].Id );
        Test.stopTest();
        
        System.assertEquals(1, expList.size(), 'size of expList should be 1');
    }
    
    @isTest
    static void testGetContractActivityRelatedToGrant() {
        List<Contract__c> contractList = [SELECT Id, Name 
                                          FROM Contract__c];
         
        List<Contract_Activity__c> activityList = [SELECT Id, Name 
                                                   FROM Contract_Activity__c 
                                                   WHERE Contract__c = :contractList[0].Id];
        Test.startTest();
        	List<NmcyfdExprenditureAmountOnCAController.ActivityAndInvoice> contractActivityAndInvoiceList = NmcyfdExprenditureAmountOnCAController.getContractActivityRelatedToGrant( contractList[0].Id, 'test', 'Program Expenditure', activityList[0].Name );
        Test.stopTest();
        
        System.assertEquals(1, contractActivityAndInvoiceList.size(), 'size of contractActivityAndInvoiceList should be 1');
    }
    
    @isTest
    static void testGetProgramSupportFee() {
        List<Contract__c> contractList = [SELECT Id, Name 
                                          FROM Contract__c];
        
        Test.startTest();
        	Decimal totalProgramSupportFee = NmcyfdExprenditureAmountOnCAController.getProgramSupportFee(contractList[0].Id);
        Test.stopTest();
        
        //System.assertNotEquals(null, totalProgramSupportFee, 'totalProgramSupportFee should not be null');
    }
    
     @isTest
    static void testGetTotalMatchAmount() {
        List<Contract__c> contractList = [SELECT Id, Name 
                                          FROM Contract__c];
        
        Test.startTest();
        	Decimal totalProgramSupportFee = NmcyfdExprenditureAmountOnCAController.getTotalMatchAmount(contractList[0].Id);
        Test.stopTest();
    }
}