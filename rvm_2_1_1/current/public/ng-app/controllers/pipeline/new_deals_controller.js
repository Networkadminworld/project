InquirlyApp.controller('PipelineNewDealsController', function($scope,$http, $modalInstance,goServiceUrl,userId,userRole){
	var go_service_url = goServiceUrl;
	var user_id = userId;
    var user_role = userRole;

	$scope.dealName = null;
	$scope.customerName = null;
	$scope.customerMobile = null;
	$scope.customerEmail = null;
    $scope.organizationName = null;
    $scope.dealValue = null;
    $scope.currency = null;


	$scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };

    $scope.saveDeal = function(){

    	$http.post(go_service_url+"/pipeline/newlead",{'user_id':user_id,
                                                        'deal_name':$scope.dealName,
                                                        'customer_name':$scope.customerName,
                                                        'customer_email':$scope.customerEmail,
                                                        'customer_mobile':$scope.customerMobile,
                                                        'user_role': user_role,
                                                        'deal_details': { 'Organization Name':$scope.organizationName,'Deal Value': $scope.dealValue,'Currency':$scope.currency}
                                                    })
            .success(function(resp){
            	console.log(resp);
            	 $modalInstance.dismiss('cancel');
            })
            .error(function(err){
            	console.log("error saving new deal:"+err);
            })
    }

	
});
