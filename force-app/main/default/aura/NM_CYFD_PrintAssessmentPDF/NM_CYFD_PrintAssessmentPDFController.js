({
    initHandler : function(component, event, helper) {

        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        var action = component.get("c.getStatus");
        action.setParams({assessmentId : component.get("v.recordId")});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                if(response.getReturnValue() != 'Completed'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type":"error",
                        "message": "Please complete the Assessment in order to generate a pdf."
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
                else{
                    let urlString = window.location.href;
                    let baseURL = '';
                    if(urlString.includes('/s/')){
                        baseURL = urlString.substring(0, urlString.indexOf("/s"));
                        console.log(baseURL);
                        setTimeout(() => {
                            var dismissActionPanel = $A.get("e.force:closeQuickAction");
                            dismissActionPanel.fire();
                        }, 100)  
                    }else{
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();        
                    }
                    //baseURL += '/apex/NM_CYFD_AssesmentPDF?id='+component.get("v.recordId"); 
                    baseURL += '/apex/NM_CYFD_Assessment2022PDF?id='+component.get("v.recordId");        
                    window.open(baseURL,'_blank');
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        
    },
})