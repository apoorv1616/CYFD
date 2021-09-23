public with sharing class NM_CYFD_ContentDocLinkTriggerHandler {
    
	public static void beforeInsert(List<ContentDocumentLink> newList) {
        sharingAccessOfFilesToAllUsers(newList, null); //sharing access of files.
    }
    /*
    public static void beforeUpdate(List<ContentDocumentLink> newList, Map<Id, ContentDocumentLink> oldMap) {
        sharingAccessOfFilesToAllUsers(newList, oldMap); //sharing access of files.
    } */
    
    /*
     * Author : Apoorv Anand
     * Desc   : Visibility of Files for Portal Users
     			(Before Insert)
     * Issue  : I-54824
    */
    public static void sharingAccessOfFilesToAllUsers(List<ContentDocumentLink> newList, Map<Id, ContentDocumentLink> oldMap) {
        
        for(ContentDocumentLink cdlRecord : newList) {
            if(cdlRecord.LinkedEntityId != null) {
                if (oldMap == null 
               	|| (oldMap.get(cdlRecord.Id).LinkedEntityId != cdlRecord.LinkedEntityId)) {
                    
                    cdlRecord.Visibility = 'AllUsers';
                }
            }
    	}
    }
}