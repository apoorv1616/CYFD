@isTest
public with sharing class NM_CYFD_HeaderControllerTest {
    @TestSetup
    static void makeData(){
        //Create portal account owner
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
                 UserRoleId = portalRole.Id,
                 ProfileId = profile1.Id,
                 Username = 'dotnetcodex@gmail.com' + System.now().millisecond() ,
                 Alias = 'sfdc',
                 Email='dotnetcodex@gmail.com',
                 EmailEncodingKey='UTF-8',
                 Firstname='test',
                 Lastname='user',
                 LanguageLocaleKey='en_US',
                 LocaleSidKey='en_US',
                 TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);
        system.runAs(portalAccountOwner1){
            Account act = new Account(
                Name = 'testAcc',
                OwnerId = portalAccountOwner1.id
            );
            Database.insert(act);
            Contact contact1 = new Contact(
             FirstName = 'Test',
             Lastname = 'McTesty',
             AccountId = act.Id,
             Email = 'newone@noemail.com'
            );
            Database.insert(contact1);
            Profile p=[Select Id from Profile where Name='JCC Community User' LIMIT 1];
            User u = New User(
                UserName = 'newone@noemail.com',
                FirstName = 'Test-First',
                LastName = 'Test-Last',
                Alias = 'test',
                email = 'newone@noemail.com',
                ContactId = contact1.Id,
                CommunityNickName = string.valueOf(math.random()).substring(0,6),
                ProfileID = p.id,
                TimeZoneSidKey = 'America/New_York', 
                LocaleSidKey = 'en_US', 
                EmailEncodingKey = 'UTF-8', 
                LanguageLocaleKey = 'en_US'
            );
            insert u;
            System.setPassword(u.Id,'test@123');            
        }        
    }
    @isTest 
    public static void testUserPositive(){
        test.starttest();
        NM_CYFD_HeaderController.userLogin('newone@noemail.com','test@123');
        NM_CYFD_HeaderController.getUserDetails();
        String result = NM_CYFD_HeaderController.forgotPassword('newone@noemail.com');
        System.AssertEquals('Success',result);
        test.stoptest();
    }
    
    @isTest 
    public static void testForgotPasswordException(){
        test.starttest();
        try{
             String result = NM_CYFD_HeaderController.forgotPassword(null);
        }catch(Exception e){
            system.debug('error ' + e);
        }
        test.stoptest();
    }
    
    
    @isTest 
    public static void testUserNegative(){
        test.starttest();
        try{
            NM_CYFD_HeaderController.failTryBlock = null;
            NM_CYFD_HeaderController.userLogin('newone1``noemailcom','test@123');
            NM_CYFD_HeaderController.forgotPassword('123412');
        }catch(Exception ex){

        }
        
        test.stoptest();
    }
}