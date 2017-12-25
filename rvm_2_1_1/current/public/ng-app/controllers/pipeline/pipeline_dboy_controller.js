InquirlyApp.controller("PipelineDBoyController",['$http','$scope','$rootScope','$cookieStore', 'pipelineService','$modal',
	function($http,$scope,$rootScope,$cookieStore, pipelineService, $modal){

		console.log("pipeline dboy controller");
		$scope.dBoyDelivered = [];

		 $scope.viewItemDetails = function(item) {
            var modalInstance = $modal.open({
                animation: $scope.animationsEnabled,
                templateUrl: '/ng-app/templates/pipeline/order_details.html',
                controller: 'PipelineViewItemController',
                resolve:{
                    item:function(){
                        return item;
                    },  
                    userRole:function() {
                        return "Sales";
                    },
                    userId:function() {
                        return $scope.userId;
                    },
                    goServiceUrl:function(){
                        return "";
                    }
                }
            });
        };


         $scope.onEngageClick = function(item) {
            var modalInstance = $modal.open({
                animation: true,
                templateUrl: '/ng-app/templates/pipeline/feedback.html',
                controller: 'FeedbackController',
                scope: $scope,
                resolve: {
                    item: function () {
                        return item;
                    }
                }
            });

            modalInstance.result.then(function(item){
                funnel_items = $scope.dBoyUndelivered;
                console.log("feedback saved successfully");
                //remove the current items from list
                new_items = funnel_items.filter(function (i) {
                    return i.item_funnel_id != item.item_funnel_id;
                });

                $scope.dBoyUndelivered = new_items;
                checkScopeBeforeApply();
                $scope.dBoyDelivered.unshift(item);
            });
        };

		init = function(){
			pipelineService.getDBoyAssignments($rootScope.current_user.id)
				.then(function(resp){
					console.log("got dboy assignments!");
					$scope.dBoyUndelivered = resp.data.data;
				},
				function(err) {
					console.log("error getting dboy assignments="+JSON.stringify(err));
				}
			);
		};


		checkScopeBeforeApply = function() {
            if(!$scope.$$phase) {
                $scope.$apply();
            }
        };

		init();

}]);