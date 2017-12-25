/**
 * Created by Bindesh Vijayan on 10/19/2015.
 */

InquirlyApp.controller("DeliveryBoyController", function($scope,$modalInstance,$http,item){
    $scope.item = item;

    init = function() {
        getDeliveryBoys();
    };

    getDeliveryBoys = function() {
        $http.post(pipelineURL+"/pipeline/deliveryBoys", {'user_id': $scope.userId })
            .success(function(resp) {
                $scope.deliveryBoys = resp;
            }).error(function(err){
                console.log("error in getting delivery boys");
            })

    };

    $scope.assignDeliveryBoy = function() {
        console.log("assigned delivery boy id=" + $scope.deliveryBoy.id.Int64);
        $http.post(pipelineURL+"/pipeline/assignDeliveryBoy", {'item_id': $scope.item.item_funnel_id, 'd_boy_id': $scope.deliveryBoy.id.Int64})
            .success(function(resp){
                $modalInstance.close($scope.item);
            }).error(function(err){
                console.log("error updating delivery boy,", JSON.stringify(err));
            });

    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };


    init();
});