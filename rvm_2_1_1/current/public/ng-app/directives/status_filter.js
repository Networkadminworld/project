angular.module('pipelineStatusFilters',[]).filter('statusFilter', function(){
	return function(input) {
		console.log("statusFilter="+input);
		if(input == "IN_NEGOTIATION") {
			return "In Negotiation";
		}else if (input == "CUSTOMER_CONTACTED") {
			return "Customer Contacted";
		}else {
			return input;
		}
	};
});