({

	doInit: function (component, event, helper) {
        var action = component.get("c.getUserDetails");
            action.setCallback(this, function (response) {
                var state = response.getState();
            if(state === "SUCCESS"){
                var userDetails = response.getReturnValue();
                component.set("v.userName", userDetails.Name);
                component.set("v.imageResource", userDetails.SmallPhotoUrl);
                if(userDetails.UserType != 'Guest'){
                    component.set("v.isGuestUser",false);
                }                
            }else{
                console.log('error: ');
            }
        });
        $A.enqueueAction(action);       
    },

    navigateToContracts : function (component, event, helper) {
        let navService = component.find("navService");
		let pageReference = {
            type: "comm__namedPage", // community page. See https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/components_navigation_page_definitions.htm
            attributes: {
                pageName: 'my-contracts' // pageName must be lower case
            }
        }
        navService.navigate(pageReference);
    },
    
    navigateToUserGuide: function (component, event, helper) {
        let navService = component.find("navService");
		let pageReference = {
            type: "comm__namedPage", // community page. See https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/components_navigation_page_definitions.htm
            attributes: {
                pageName: 'user-guide' // pageName must be lower case
            }
        }
        navService.navigate(pageReference);
    },
    
    navigateToHome : function (component, event, helper) {
        let navService = component.find("navService");
		let pageReference = {
            type: "comm__namedPage", // community page. See https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/components_navigation_page_definitions.htm
            attributes: {
                pageName: 'home' // pageName must be lower case
            }
        }
        navService.navigate(pageReference);
    },
    
    logout : function(component, event, helper){
        window.location.replace("/cyfd/secur/logout.jsp?retUrl=/cyfd/s/nmcyfd-login");
    },

    gotoURL : function (component, event, helper) {
        var searchString = component.get("v.searchString");
        if(event.which == 13){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": "/global-search/"+searchString
            });
            urlEvent.fire();
        }
    },
    
    handleRouteChange : function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                var currentUrl = window.location.href;
                if(!currentUrl.includes("global-search")){
                    component.set("v.searchString",'');
                }
            }), 1000
       );
        
    }
})