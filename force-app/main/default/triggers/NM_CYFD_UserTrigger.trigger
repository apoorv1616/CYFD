trigger NM_CYFD_UserTrigger on User (before insert,after insert) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        NM_CYFD_UserTriggerHandler.createAccessToUser(Trigger.new);
    }
    
}