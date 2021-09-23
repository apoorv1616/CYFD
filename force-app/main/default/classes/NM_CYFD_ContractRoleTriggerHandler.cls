public without sharing class NM_CYFD_ContractRoleTriggerHandler {
    
    /*
*   Method is used to track all method calls on after Insert
*  This method takes input of List of Cases
*/
    
    public static void beforeInsert(List<Contract_Role__c> newList){
       // checkDuplicateRoles(newList);
       populateDateofBirthForMatchingRule(newList, null);
    }
    
    public static void afterInsert(List<Contract_Role__c> newList){
         contactShareAccess(newList,null);
        
    }
    
    public static void beforeUpdate(List<Contract_Role__c> newList, Map<Id,Contract_Role__c> oldMap){
        populateDateofBirthForMatchingRule(newList, oldMap);
        
    }
    public static void afterUpdate(List<Contract_Role__c> newList, Map<Id,Contract_Role__c> oldMap){
        contactShareAccess(newList,oldMap);
        
    }
    
    /*
     * Author : Apoorv Anand
     * Issue  : I-52204
     * Desc   : populate Date_of_Birth_for_Matching_Rule__c as text field from Date_of_Birth__c for matching rules.
    */
    private static void populateDateofBirthForMatchingRule(List<Contract_Role__c> newList, Map<Id,Contract_Role__c> oldMap) {
        for(Contract_Role__c contractRoleRecord : newList) {
            if(contractRoleRecord.Date_of_Birth__c != null) {
                if(oldMap == null || (oldMap.get(contractRoleRecord.Id).Date_of_Birth__c != contractRoleRecord.Date_of_Birth__c)) {
                    contractRoleRecord.Date_of_Birth_for_Matching_Rule__c = String.valueOf(contractRoleRecord.Date_of_Birth__c).trim();
                }
            }
        }
    }
    
  /*  private static void checkDuplicateRoles(List<Contract_Role__c> newList){
        Set<Id> parentContractId = new Set<Id>();
        Map<Id,List<String>> contractToContractRoleMap = new Map<Id,List<String>>();
        for(Contract_Role__c cR : newList){
            if(cR.First_Name__c != null && cR.Last_Name__c != null && cR.Date_of_Birth__c != null ){
                parentContractId.add(cR.Account__c );
            }
        }
           contractToContractRoleMap = getContractToCotractRoleMap(parentContractId);
            for(Contract_Role__c cR1 : newList){
                String uniqueKey = cR1.First_Name__c.toLowercase() + cR1.Last_Name__c.toLowercase() + cR1.Date_of_Birth__c;
                if(contractToContractRoleMap.containsKey(cR1.Account__c)){
                    for(String s : contractToContractRoleMap.get(cR1.Account__c)){
                        if(uniqueKey == s){
                            cR1.addError('Contract Role with same details already present');
                        }
                    }
                     contractToContractRoleMap.get(cR1.Account__c).add(uniqueKey);
                }
                
            }
        }
  
    private static Map<Id,List<String>> getContractToCotractRoleMap(Set<ID> Ids){
        Map<Id,List<String>> duplicateContractRoleMaps = new Map<Id,List<String>>();
         List<Contract__c> getContractChild = [SELECT Id,(SELECT ID,First_Name__c,Last_Name__c,Date_of_Birth__c,Contract__c FROM Contract_Roles__r WHERE First_Name__c != null AND Last_Name__c != null AND Date_of_Birth__c != null),Name FROM Contract__c WHERE id IN:Ids ];
            for(Contract__c c : getContractChild){
                duplicateContractRoleMaps.put(c.id,new List<String>());
                for(Contract_Role__c selectedRole : c.Contract_Roles__r){
                    duplicateContractRoleMaps.get(c.id).add(selectedRole.First_Name__c.toLowercase() + selectedRole.Last_Name__c.toLowercase() + selectedRole.Date_of_Birth__c);
                }
            }
        return duplicateContractRoleMaps;
    }*/
    
    
    /*
     * Method used to share contract access to Provider users added as Contract Roles on Contracts
     */ 
    public static void contactShareAccess(List<Contract_Role__c> newList, Map<id,Contract_Role__c> oldMap){
        
        Map<String, String> contractRoleToProviderMap = new Map<String, String>();
        Map<Id, List<Id>> providerIdToContractIdsMap = new Map<Id, List<Id>>();
        Map<Id,Id> contactIdsToAccountMap = new Map<Id,Id>();
        Map<Id,Id> contactToUserMap = new Map<Id, Id>();
        List<AccountShare> providerShareList = new List<AccountShare>();
        
        Set<Id> deleteUserIdSet = new Set<Id>();
        Set<Id> deleteContractIdSet = new Set<Id>();
        
        for(Contract_Role__c role : newList){
            if(role.Contact__c != null &&  (oldMap == null ||(oldMap.get(role.id).Contact__c !=  role.Contact__c))){
                if(role.RecordTypeId == NM_CYFD_Constants.NM_CYFD_CONTRACT_ROLE_RECORDTYPEID){ 
                    contactIdsToAccountMap.put(role.Contact__c, role.Account__c);
                }
                
                /*
                 * Author : Apoorv Anand 
                 * Desc   : removal sharing access for the old contracts which are of different account.
                 * Issue  : I-53246
                */
                if(oldMap != null 
                   && oldMap.get(role.id).Contact__c !=  role.Contact__c
                   && oldMap.get(role.id).Account__c !=  role.Account__c
                  ) {
                       
                    deleteContractIdSet.add(oldMap.get(role.id).Contact__c);
                }
            }
        }
        
        for(User u: [Select Id, ContactId 
                     FROM User 
                     Where IsActive = true 
                     AND 
                     	(
                            ContactId IN :contactIdsToAccountMap.keySet()
                             /*
                                * Author : Apoorv Anand 
                                * Desc   : removal sharing access for the old contracts.
                                * Issue  : I-53246
                            */
                            OR 
                            ContactId IN :deleteContractIdSet
                        )
                    ]){
            contactToUserMap.put(u.ContactId, u.Id);
        }
       /* for(Contract__c c : [SELECT Id, Account__c FROM Contract__c WHERE Account__c IN: contractRoleToProviderMap.values()]){
            if(!providerIdToContractIdsMap.containsKey(c.Account__c))
                providerIdToContractIdsMap.put(c.Account__c, new List<Id>());
            providerIdToContractIdsMap.get(c.Account__c).add(c.Id);
        }*/
        
        for(Contract_Role__c role : newList){
            if(contactToUserMap.containsKey(role.Contact__c)){
                AccountShare actShare = prepareShareRecord(role.Account__c, contactToUserMap.get(role.Contact__c), 'Edit');
                providerShareList.add(actShare);
            }           
        }
        
        if(!providerShareList.isEmpty())
            insert providerShareList;
        /*
            * Author : Apoorv Anand 
            * Desc   : removal sharing access for the old contracts of diffrent account.
            * Issue  : I-53246
        */
        if(!deleteContractIdSet.isEmpty()) {
            for(Id ContactId : deleteContractIdSet){
                if(contactToUserMap.containsKey(ContactId)){
                    Id userRecordId = contactToUserMap.get(ContactId);
                    deleteUserIdSet.add(userRecordId);
                }           
        	}
            
            List<AccountShare> accountShareListToBeDeleted = [SELECT Id 
                                                              FROM AccountShare
                                                              WHERE UserOrGroupId IN :deleteUserIdSet
                                                              AND RowCause = 'Manual'];
            if(!accountShareListToBeDeleted.isEmpty()) {
                delete accountShareListToBeDeleted;
            }
         }
       
    }


    public static AccountShare prepareShareRecord(Id providerId, Id userId, String accessType){
        AccountShare shareRecord = new AccountShare();
        shareRecord.AccountId  = providerId;
        shareRecord.UserOrGroupId = userId;
        shareRecord.AccountAccessLevel  = accessType;
        shareRecord.OpportunityAccessLevel='Read';
        shareRecord.RowCause  = 'Manual';
        return shareRecord;
    }
}