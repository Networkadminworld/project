InquirlyApp.controller('flickrCtrl',['$scope', '$modalInstance', '$http', '$modal','$window','tags', function ($scope, $modalInstance, $http, $modal,$window,tags) {

    $scope.tags = tags;
    $scope.page_num = 1;
    $scope.page_size = 8;
    $scope.photos = [];
    $scope.total = 0;

    $scope.isLoading = true;
    $scope.hasError = false;
    $scope.errMessage = "";


    $scope.getImages = function() {
	var tags = [];
	angular.forEach($scope.tags, function (tag) {  tags.push(tag.text) });
        $scope.isLoading = true;
        $scope.hasError = false;
        $scope.errMessage = "";
        $scope.photos = [];
        $scope.Math = $window.Math;

        var data = {'tags': tags.join(","),
            'page_num': $scope.page_num,
            'page_size': $scope.page_size };

        $http.post(baseURL+ '/campaigns/suggestImages', data).success(function(resp) {
            $scope.isLoading = false;
            if(resp.status == 'success') {
                $scope.photos = resp.suggest_images.images;
                $scope.total = resp.suggest_images.total;
            } else {
                $scope.hasError = true;
                $scope.errMessage = resp.message;
            }
        }).error(function(){
                $scope.isLoading = false;
                $scope.hasError = true;
                $scope.errMessage = "Unable to reach server";
            });
    };


    $scope.search = function() {
        $scope.page_num = 1;
        $scope.getImages();
    };

    $scope.next = function() {
        if(Math.min(($scope.page_size)*($scope.page_num), $scope.total)==$scope.total){return;}
        $scope.page_num = $scope.page_num+1;
        $scope.getImages();
    };

    $scope.prev = function() {
        if($scope.page_num <= 1) { return; }
        $scope.page_num = $scope.page_num-1;
        $scope.getImages();
    };

    $scope.selectImage = function(img_src){
        $modalInstance.close(img_src);
    };


    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };

    $scope.showFlickrPreview = function(url){
        var modalInstanceSecond = $modal.open({
            templateUrl: '/ng-app/templates/home/flickpreviewDialog.html',
            controller: 'flickrPreviewCtrl',
            size:'fst',
            resolve: {
                url : function () {
                    return url;
                }
            }
        });
    };

    $scope.search();
}]);

InquirlyApp.controller('flickrPreviewCtrl',['$scope', '$modalInstance', '$modal','$http', 'url', function ($scope, $modalInstance, $modal, $http, url) {

    $scope.url = url;

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };

}]);
