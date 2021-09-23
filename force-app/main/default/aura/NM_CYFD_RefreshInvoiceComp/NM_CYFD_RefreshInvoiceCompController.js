({
    initHandler : function(component, event, helper) {
        var action = component.get("c.refreshInvoiceWithActivity");
        action.setParams({
            recordId: component.get("v.recordId")
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
            if(result == 'Success') {
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Successs!",
                    "type": "success",
                    "message": 'Invoice refreshed sucessfully!'
                });
                toastEvent.fire();                
            }           
            else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Info!",
                    "type": "Warning",
                    "message": result
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
        
   /* setTimeout(() => {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }, 100)*/
}
})