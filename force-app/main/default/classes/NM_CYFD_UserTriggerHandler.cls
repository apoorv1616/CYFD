public class NM_CYFD_UserTriggerHandler {

    public static void createAccessToUser(List<User> newList)
    {
        Set<Id> userIds = new Set<Id>();      
        for(User u : newList){
            userIds.add(u.Id);
        }       
        contractSharingToPortalUsers(userIds);           
    }
    
    @future
    public static void contractSharingToPortalUsers(Set<Id> userIds){
        Map<Id,Id> userIdToContactId = new Map<Id,Id>();
        Map<Id,List<Id>> userIdToContractsId = new Map<Id,List<Id>>();
        Map<Id,List<Id>> userIdToProviderIdsMap = new Map<Id,List<Id>>();
        List<AccountShare> shareList = new List<AccountShare>();
        
        for(User u : [SELECT Id, ContactId FROM User WHERE Id IN: userIds])
        {
            if(u.ContactId != null)
                userIdToContactId.put(u.ContactId,u.Id);
        }
        
        for(Contract_Role__c role : [SELECT Id, Contact__c, Account__c FROM Contract_Role__c 
                                     WHERE Contact__c IN : userIdToContactId.keySet() ]){
                                         
            if(!userIdToProviderIdsMap.containsKey(userIdToContactId.get(role.Contact__c))){
                userIdToProviderIdsMap.put(userIdToContactId.get(role.Contact__c),new List<Id>());
            }
            userIdToProviderIdsMap.get(userIdToContactId.get(role.Contact__c)).add(role.Account__c);
            
        }
        
        for(Id userId : userIdToProviderIdsMap.keySet()){
            if(userIdToProviderIdsMap.containsKey(userId)){
               for(Id providerId : userIdToProviderIdsMap.get(userId)){
                    AccountShare shareRecord = new AccountShare();
                    shareRecord.AccountId  = providerId;
                    shareRecord.UserOrGroupId = userId;
                    shareRecord.AccountAccessLevel  = 'Edit';
                    shareRecord.OpportunityAccessLevel='Read';
                    shareRecord.RowCause  = 'Manual';
                    shareList.add(shareRecord);
                } 
            }
            
        }
        if(!shareList.isEmpty()){
           insert(shareList);
        }
    }
  
}