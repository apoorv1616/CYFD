@isTest
    public without sharing class BulkUploadCMControllerTest {
    
        @isTest
        static void testGetAllCustomMetadata() {
            Test.startTest();
                List < BulkUploadCMController.CustomMetadataWrapper > customMetadataObjectList = BulkUploadCMController.getAllCustomMetadata();
            Test.stopTest();
    
            System.assertNotEquals(customMetadataObjectList, NULL , 'Custom Metadata  list should not be null if exists in org');
        }
        
        @isTest
        static void testGetAllCustomMetadataFields() {
            List < BulkUploadCMController.CustomMetadataWrapper > customMetadataObjectList = BulkUploadCMController.getAllCustomMetadata();
            Test.startTest();
            List < BulkUploadCMController.CustomMetadataWrapper > fieldList = BulkUploadCMController.getAllCustomMetadataFields(customMetadataObjectList.get(0).fieldAPI);
            Test.stopTest();
    
            System.assertNotEquals(customMetadataObjectList, NULL , 'Custom Metadata  list should not be null if exists in org');
        }
        
        @isTest
        static void testGetAllCustomMetadRecords() {
            List < BulkUploadCMController.CustomMetadataWrapper > customMetadataObjectList = BulkUploadCMController.getAllCustomMetadata();
            List < BulkUploadCMController.CustomMetadataWrapper > fieldList = BulkUploadCMController.getAllCustomMetadataFields(customMetadataObjectList.get(0).fieldAPI);
            String fields = '';
    
            for(BulkUploadCMController.CustomMetadataWrapper fieldRecord : fieldList) {
                fields += fieldRecord.fieldAPI + ',';
            }
    
            fields = fields.substring(0,fields.length() - 1);
    
            Test.startTest();
            List < sobject > recordList = BulkUploadCMController.getAllCustomMetadRecords(fields , customMetadataObjectList.get(0).fieldAPI);
            Test.stopTest();
    
            System.assertNotEquals(recordList, NULL , 'Custom Metadata  list should not be null if exists in org');
        }
        
        @isTest
        static void testReadCSVFile() {
            List < BulkUploadCMController.CustomMetadataWrapper > customMetadataObjectList = BulkUploadCMController.getAllCustomMetadata();
            List < BulkUploadCMController.CustomMetadataWrapper > fieldList = BulkUploadCMController.getAllCustomMetadataFields('City_County_Mapping__mdt');
    
            String fields = '';
            //String data = '';
    
            for(BulkUploadCMController.CustomMetadataWrapper fieldRecord : fieldList) {
                fields += fieldRecord.fieldAPI + ',';
                //data += 
            }
    
            fields = fields.substring(0,fields.length() - 1);
    
    
            ContentVersion contentVer = new ContentVersion();
            contentVer.Title = 'Test';
            contentVer.PathOnClient = 'Test.csv';
            contentVer.VersionData = Blob.valueOf('City__c,County__c\r\n test,test');
            contentVer.IsMajorVersion = true;
            insert contentVer;
            
            Contact con = new Contact();
            con.LastName = 'test';
            insert con;
            
            ContentVersion insertedContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentVer.Id ]; 
    
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.ShareType = 'V';
            contentlink.LinkedEntityId = con.Id;
            contentlink.ContentDocumentId = insertedContentVersion.ContentDocumentId;
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink;
    
    
            BulkUploadCMController.readCSVFile(insertedContentVersion.ContentDocumentId, 'City_County_Mapping__mdt', fields);
        }
    }