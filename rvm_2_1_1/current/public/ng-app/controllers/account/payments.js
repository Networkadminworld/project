InquirlyApp.controller('PaymentController', function($scope, $http) {
    $scope.currentPage = 1;
    $scope.perPage = 5;
    $scope.tracks = [];
    $scope.loaded = false;
    $scope.getData = function() {
        var url = '/account/payment_details.json?page='+$scope.currentPage+'&per_page='+$scope.perPage;
        $http.get(url)
            .then(function(data) {
                var paymentHistory = JSON.parse(data.data.payment_history);
                $scope.current_plan_name = data.data.current_plan;
                $scope.plan_expiry_date = data.data.expiry_date;
                $scope.totalItems = paymentHistory.num_results;
                $scope.tracks = paymentHistory.transaction_history;
                $scope.loaded = true;
            });
    };
    $scope.getData();
    $scope.pageChanged = function() {
        $scope.getData();
    };
});
