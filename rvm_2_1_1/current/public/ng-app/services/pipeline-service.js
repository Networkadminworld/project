InquirlyApp.service('pipelineService',['$http', '$q', function($http,$q){
	var service = this;
	var pipelineUrl = document.getElementById('v2_pipeline').value;



	/*
	*Name:isDboy()
	*Description:check if the current logged in user 
	  has the delivery boy role 
	 */
	service.isDboy = function(){
		 var d = $q.defer();
		 console.log("pipelineService isDboy");
		 $http.get("chat/identity").success(function (data, status) {
                    console.log("pipeline service go user id=" + data.id);
                    $http.post( pipelineUrl+"/pipeline/checkIfDeliveryBoy",{'user_id': data.id})
                    .then(function(resp){
                    	d.resolve(resp);
                    },function(err){
                    	d.reject(err);
                    })
                }).error(function(err){
                	console.log("chat identity failed");
                });
        return d.promise;        
	};

	/*
	*Name:getDBoyAssignments()
	*Description: Get dboy assignments
	 */
	 service.getDBoyAssignments = function(user_id) {
	 	var d = $q.defer();
	 	var rest_url = pipelineUrl + "/pipeline/getDeliveryBoyItems";

	 	$http.post(rest_url, {'d_boy_id':user_id})
	 	.then(function(resp){
	 			d.resolve(resp);
		 	},
		 	function(err) {
		 		d.reject(err);
		 	}
	 	);
	 	return d.promise;
	 };

	return service;
}]);