@isTest
public with sharing class NM_CYFD_DeleteFilesOnCAControllerTest {
	
    @testSetup
    static void makeData() {
        List<Account> accountList = NM_CYFD_TestDataFactory.createAccounts(1, true);
        List<Contact> contactList = NM_CYFD_TestDataFactory.createContacts(1,accountList[0].Id,true);
        
        List<Contract_Configuration__c> configList = NM_CYFD_TestDataFactory.createContractConfigurationRecords(1, true);
        
        List<Contract__c> contractList = NM_CYFD_TestDataFactory.createContractRecords(1, accountList[0].Id, configList[0].Id, 'Mentoring', true);
        
        List<CYFD_Activity__c> cyfdActivityList = NM_CYFD_TestDataFactory.createCYFDActivity(1, 'Billable Activity', true);
        
        List<Contract_Configuration_Line_Item__c> lineItemList = NM_CYFD_TestDataFactory.createContractConfigurationLIRecords(1, configList[0].Id, cyfdActivityList[0].Id, false);
        lineItemList[0].Minimum_Unit__c  = '2';
        lineItemList[0].Sub_Contractor__c  = 'Test Contracter';
        lineItemList[0].Program__c  = 'Botvin Life Skills';
        insert lineItemList;
        
        List<Contract_Activity__c> activityList = NM_CYFD_TestDataFactory.createContractActivity(1, contractList[0].Id, 'Billable Activity', false);
        activityList[0].Date__c  = system.today() -1;
        activityList[0]. Unit__c = 3.0;
        activityList[0].Contract_Configuration_Line_Item__c = lineItemList[0].Id;
        activityList[0].Invoice_Amount__c = 200;
        insert activityList;
    }
    
    private static ContentDocumentLink createFiles(List<Contract_Activity__c> activityList, Boolean isInsert) {
        ContentVersion contentVer = new ContentVersion();
        contentVer.Title = 'Test';
        contentVer.PathOnClient = 'Test.csv';
        contentVer.VersionData = Blob.valueOf('Date Of Birth,First Name,Last Name\r\n08/12/1988,Apoorv,Apoorv');
        contentVer.IsMajorVersion = true;
        insert contentVer;
        
        List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId
                                                  FROM ContentVersion
                                                  WHERE Id =: contentVer.Id 
                                                  LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.ShareType = 'V';
        contentlink.LinkedEntityId = activityList[0].Id;
        contentlink.ContentDocumentId = contentVersionList[0].ContentDocumentId;
        contentlink.Visibility = 'InternalUsers'; 
        
        if(isInsert) {
            insert contentlink;
        }
        
        return contentlink;
    }
    
    @isTest
    static void testGetFilesAssociatedWithCA() {
        List<Contract_Activity__c> activityList = [SELECT Id 
                                                   FROM Contract_Activity__c 
                                                   LIMIT 1];
        
        ContentDocumentLink contentlink = createFiles(activityList, false);
        
        insert contentlink;
        
        Test.startTest();
        	List<NM_CYFD_DeleteFilesOnCAController.Files> filesList = NM_CYFD_DeleteFilesOnCAController.getFilesAssociatedWithCA(activityList[0].Id,null);
        Test.stopTest();
        
        System.assertNotEquals(0, filesList.size(), 'size of file list should be more than 0');
    }

    @isTest
    static void testSearchInGetFilesAssociatedWithCA() {
        List<Contract_Activity__c> activityList = [SELECT Id 
                                                   FROM Contract_Activity__c 
                                                   LIMIT 1];
        
        ContentDocumentLink contentlink = createFiles(activityList, false);
        
        insert contentlink;
        
        Test.startTest();
        	List<NM_CYFD_DeleteFilesOnCAController.Files> filesList = NM_CYFD_DeleteFilesOnCAController.getFilesAssociatedWithCA(activityList[0].Id,'Test');
        Test.stopTest();
        
        System.assertNotEquals(0, filesList.size(), 'size of file list should be more than 0');
    }
    
    @isTest
    static void testDeleteFiles() {
        List<Contract_Activity__c> activityList = [SELECT Id 
                                                   FROM Contract_Activity__c 
                                                   LIMIT 1];
        
        ContentDocumentLink contentlink = createFiles(activityList, false);
        
        insert contentlink;
        
        List<NM_CYFD_DeleteFilesOnCAController.Files> filesList = NM_CYFD_DeleteFilesOnCAController.getFilesAssociatedWithCA(activityList[0].Id,null);
        filesList[0].isSelected = true;
        
        Test.startTest();
        	NM_CYFD_DeleteFilesOnCAController.deleteFiles(JSON.serialize(filesList));
        Test.stopTest();
        
        System.assertEquals(0, [SELECT Id, LinkedEntityId,LinkedEntity.Name, 
                                ContentDocumentId, ContentDocument.Title,ContentDocument.FileType,
                                ContentDocument.Description, Visibility 
                                FROM ContentDocumentLink 
                                WHERE LinkedEntityId = :activityList[0].Id].size(), 'No files should be attached to CA');
        
    }
}