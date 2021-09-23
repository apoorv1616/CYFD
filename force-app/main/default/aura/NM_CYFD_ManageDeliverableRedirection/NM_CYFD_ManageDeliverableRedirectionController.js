({
	initHandler : function(component, event, helper) {
		var address = '/manage-deliverables?contractId='+component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": address,
            "isredirect" :false
        });
        urlEvent.fire();
        setTimeout(() => {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }, 100)
	}
})