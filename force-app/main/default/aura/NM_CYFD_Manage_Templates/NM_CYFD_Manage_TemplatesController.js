({
	getValueFromLwc : function(component, event, helper) {
		component.set("v.accountId",event.getParam('value'));
		console.log('ttt ' + component.get("v.accountId"));
	},

	saveClick : function(component, event, helper) {
		helper.saveRelationship(component, event, helper);
	},

	close : function(component, event, helper){
		$A.get("e.force:closeQuickAction").fire();
	}
})