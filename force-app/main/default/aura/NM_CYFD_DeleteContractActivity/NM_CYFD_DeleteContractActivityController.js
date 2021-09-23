({
    /*initHandler : function(component, event, helper) {
       component.set('v.showConfirmDialog', true);
    },*/
    
    /*handleConfirmDialog : function(component, event, helper) {
        component.set('v.showConfirmDialog', true);
    },*/
    
    handleConfirmDialogYes : function(component, event, helper) {
        console.log('Yes');
        console.log('fnjfbjhbhb');
        var action = component.get("c.deleteContractActivity");
        component.set('v.showSpinner',true);
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            console.log('response.value()>>>' + JSON.stringify(response.getReturnValue()));
            var result = response.getReturnValue();
            var state = response.getState();
            console.log('response.state()>>>' + response.getState());
            debugger;
            if (state === "SUCCESS") {
                
                if(result.result) {
                    var contractId = result.contractId;
                    var address = '/contract/'+contractId;
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": address,
                        "isredirect" :false
                    });
                    urlEvent.fire();
                    console.log('contract ID ', contractId);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Successs!",
                        "type": "success",
                        "message": 'Contract Activity deleted sucessfully!'
                    });
                    toastEvent.fire();    
                    component.set('v.showSpinner',false);

                }           
                else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "",
                        "type": "Warning",
                        "message": 'Activities can only be deleted when related invoice is in new or rejected status !'
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    component.set('v.showSpinner',false);

                }
            } 
            else if (state === "ERROR") {
                
                var errors = response.getError();
                console.log('error --> ', errors)
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
                    component.set('v.showSpinner',false);
                } else {
                    console.log("Unknown error");
                    component.set('v.showSpinner',false);

                }
            }
        })
        $A.enqueueAction(action);
        //window.location.reload();
    },
    
    handleConfirmDialogNo : function(component, event, helper) {
        console.log('No');
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
    },
})