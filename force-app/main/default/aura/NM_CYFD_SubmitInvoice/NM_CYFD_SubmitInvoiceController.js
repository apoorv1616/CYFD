({
    initHandler : function(component, event, helper) {
        var action = component.get("c.submitInvoice");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
		console.log('userId ', userId);
        action.setParams({
            recordId: component.get("v.recordId"),
            userId : userId
        });
        
    	action.setCallback(this, function (response) {
        console.log('response.value()>>>' + JSON.stringify(response.getReturnValue()));
        var result;
        result = response.getReturnValue();
        var state = response.getState();
        console.log('response.state()>>>' + response.getState());
        if (state === "SUCCESS") {
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
            if(result.success) {
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Successs!",
                    "type": "success",
                    "message": 'Invoice submitted sucessfully!'
                });
                toastEvent.fire();                
            }           
            else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Info!",
                    "type": "Warning",
                    "message": 'Invoice could not be submitted'
                });
                toastEvent.fire();
            }
        } 
        else if (state === "ERROR") {
            var errors = response.getError();
            if (errors) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": errors[0].message
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();

                console.log("Error message: " + JSON.stringify(errors));
            } else {
                console.log("Unknown error");
            }
        }
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    })
    $A.enqueueAction(action);
    /*setTimeout(() => {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }, 100)*/
}
})