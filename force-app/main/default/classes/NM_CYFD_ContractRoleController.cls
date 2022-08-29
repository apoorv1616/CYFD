public with sharing class NM_CYFD_ContractRoleController {

    @AuraEnabled
    public static Map<String, Object> getRecordTypeDetails(String contractRoleId){
        Map<String, Object> response = new Map<String, Object>();
        
        Contract_Role__c role = [SELECT RecordType.Name, Contract_Role__c  FROM Contract_Role__c WHERE Id =:contractRoleId LIMIT 1];
        response.put('roleType', role.Contract_Role__c );
        return response;
        
    }
    
    @AuraEnabled
    public static Map<String, Object> getContractRoleDetails(String contractRoleId){
        Map<String, Object> response = new Map<String, Object>();
        
         Schema.DescribeSObjectResult r = Contract_Role__c.sObjectType.getDescribe();
         List<String>apiNames =  new list<String>();
         for(string apiName : r.fields.getMap().keySet()){
            apiNames.add(apiName);
         }
         String fieldList = String.join(apiNames, ',');
         String query = 'SELECT ' + fieldList + ', RecordType.Name FROM Contract_Role__c WHERE Id =:contractRoleId ';
        system.debug('query ** ' + query);
        List<Contract_Role__C> roles = Database.query(query);
        system.debug(' roles '  + roles);
        
        
        if(!roles.isEMpty()){
            Contract_Role__c role = roles[0];
            ContractRoleWrapper roleWrapper =  new ContractRoleWrapper();
            response.put('roleType', role.Recordtype.Name);
            if(role.Recordtype.Name == 'Provider'){
                roleWrapper = roleWrapper.getStaffDetails(role);
                
            }else{
                roleWrapper = roleWrapper.getClientDetails(role);
            }
            response.put('roleData', roleWrapper);
            
        }
        
        return response;
        
    }
    
    
    @AuraEnabled 
    public static Map<String, Object> saveContractRole(String roleJSON, String contractId, String roleType, String contractRoleId){
        Map<String, Object> response = new Map<String, Object>();
        ContractRoleWrapper contractRole = (ContractRoleWrapper)JSON.deserialize(roleJSON, ContractRoleWrapper.class);
        try{
            Contract_Role__c role = new Contract_Role__c();
            
            if(roleType == 'Staff'){
                role = contractRole.createStaff(contractRole);
            }else if(roleType == 'Client'){
                role = contractRole.createClient(contractRole, '');
                
            }
            if(contractRoleId == null){
                Contract__c contract = [SELECT Account__c, Grant__c FROM Contract__c WHERE Id= :contractId LIMIT 1 ];
                String recordtype = '';
                role.Account__c = contract.Account__c;
                if(roleType == 'Client'){
                    if(contract.Grant__c == 'JCC'){                    
                        recordType = 'JCC Client';
                    }else if(contract.Grant__c == 'JJAC'){
                        recordType = 'JJAC Client';
                    }else if(contract.Grant__c == 'Mentoring'){
                        recordType = 'Mentoring Client'; 
                    } 
                    role.Contract_Role__c = recordType;
                     
               }else
                   recordtype = 'Provider';
               role.RecordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Role__c', recordtype);
                
            }
            system.debug('role %%%% ' + role.Id);
            
            
            upsert role;
            response.put('success', true);
            response.put('msg', 'Contract Role saved successfully !');
        }catch(Exception e){
            response.put('success', false);
            System.debug('exception'+ e);
            response.put('msg', e.getMessage());
        }
        return response;        
    }
}