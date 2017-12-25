InquirlyApp.controller("PipelineAssignController", function($scope,$modalInstance,$http,item){
    $scope.item = item;

     init = function() {
        getMarketingUsers();
    };

    getMarketingUsers = function() {
        $http.post(pipelineURL+"/pipeline/marketingUsers", {'user_id': $scope.userId })
            .success(function(resp) {
                $scope.marketingUsers = resp;
            }).error(function(err){
                console.log("error in getting delivery boys");
            })

    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };

     $scope.assignMarketingPerson = function() {
        $http.post(pipelineURL+"/pipeline/assignMarketingPerson", {'item_id': $scope.item.item_funnel_id, 'person_id': $scope.assignedUser.id.Int64})
            .success(function(resp){
                $modalInstance.close($scope.item);
            }).error(function(err){
                console.log("error updating delivery boy,", JSON.stringify(err));
            });
    };
    init();
	}
);