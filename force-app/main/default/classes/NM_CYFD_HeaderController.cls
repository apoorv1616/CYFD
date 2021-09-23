public without sharing class NM_CYFD_HeaderController {
    @TestVisible private static String failTryBlock = UserInfo.getUserId();
    static Id userIds = UserInfo.getUserId();
    
    @AuraEnabled(cacheable=true)
    public static User getUserDetails(){
        List<User> userList = [SELECT Name, FirstName, LastName, CompanyName, Email, Phone, smallPhotoUrl, ContactId, Contact.AccountId,
                                UserType FROM User WHERE Id = :userIds];
        return userList[0];        
    }

    @AuraEnabled
    public static Map<String, Object> userLogin(String username, String password){
        Map<String, Object> result = new Map<String, Object>();
        try{
            if (Test.isRunningTest()) {
				Id failTryBlockId = Id.valueOf(failTryBlock);
			}
            ApexPages.PageReference lgn = Site.login(username, password, '/s');
            if (!Test.isRunningTest()) {
                aura.redirect(lgn);
                result.put('redirectURL',lgn.getUrl());
            }
            return result;
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage()); 
        }
  
    }

    @AuraEnabled
    public static String forgotPassword(String username) {
        try {
            if (Test.isRunningTest()) {
				Id failTryBlockId = Id.valueOf(failTryBlock);
			}
            Site.forgotPassword(username);            
            if(!Site.isValidUsername(username)) {
                return Label.Site.invalid_email;
            }else{                
                return 'Success';
            }
        }
        catch (Exception ex) {return ex.getMessage();}
    }
    
}