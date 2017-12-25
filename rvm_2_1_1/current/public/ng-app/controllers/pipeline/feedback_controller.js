InquirlyApp.controller("FeedbackController", function($scope,$modalInstance,$http,item){
    $scope.item = item;
    $scope.rating = null;
    var pipelineUrl = document.getElementById('v2_pipeline').value;

    $scope.cancel = function () {
      $modalInstance.dismiss('cancel');
    };

    $scope.saveFeedback = function() {
    	var item_id = $scope.item.item_funnel_id;
    	var rest_url = pipelineUrl + "/pipeline/saveFeedback";
		$http.post(rest_url, {'funnel_id' : item_id, 'rating': $scope.rating}).
		success(function(resp){
			if(resp.status == 200) {
				$scope.item.item_rating = $scope.rating;
				$modalInstance.close($scope.item);
			}else {
				console.error("Error saving feedback at backend:"+ resp.data.message);
			}
		}).error(function(err){
			console.error("error saving feedback");
		});
    };



});