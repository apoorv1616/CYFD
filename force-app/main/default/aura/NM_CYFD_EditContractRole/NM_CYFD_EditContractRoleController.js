({
	initHandler : function(component, event, helper) {
        console.log('bjfj ' + component.get("v.recordId"));
		var action = component.get("c.getRecordTypeDetails");
        action.setParams({
            contractRoleId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            var state = response.getState();
            console.log('response.state()>>>' + result.roleType+ ' role ' );
            if (state === "SUCCESS") {
                
               if(result.roleType == 'Staff')
                   component.set("v.staff", true);
                else{
                    component.set("v.client", true);
                    if(result.roleType == 'JCC Client')
                        component.set("v.jccClient", true);
                    else if(result.roleType == 'JJAC Client')
                        component.set("v.jjacClient", true);
                    else if(result.roleType == 'Mentoring Client')
                        component.set("v.mentoringClient", true);
                }
//                component.set("v.member", result.roleData);
            } 
            else if (state === "ERROR") {
                
                var errors = response.getError();
                console.log('error --> ', errors)
              
            }
        })
        $A.enqueueAction(action);
        //window.locat
	},
    
    close : function(component, event, helper){
		$A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
	}
})