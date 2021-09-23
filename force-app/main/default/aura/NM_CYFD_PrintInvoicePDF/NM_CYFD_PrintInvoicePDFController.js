({
	initHandler : function(component, event, helper) {
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
        baseURL += '/apex/NM_CYFD_PrintInvoicePDF?id='+component.get("v.recordId");        
        window.open(baseURL,'_blank');
    },
})