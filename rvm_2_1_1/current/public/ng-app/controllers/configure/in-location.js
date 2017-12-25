InquirlyApp.controller('InLocationController', function($scope, $http, $modal,$window,ConfigValidation) {

    $scope.currentPage = 1;
    $scope.perPage = 10;
    $scope.beacons = [];
    $scope.beacon = [];
    $scope.loaded = false;
    $scope.getBeaconsList = function() {
        var url = '/configurations/beacons_list.json?page='+$scope.currentPage+'&per_page='+$scope.perPage;
        $http.get(url)
            .then(function(data) {
                var results = data.data;
                $scope.totalItems = results.num_results;
                $scope.beacons = JSON.parse(results.beacons_list);
                $scope.loaded = true;
            });
    };

    $scope.getBeaconsList();

    $scope.pageChanged = function() {
        $scope.getBeaconsList();
    };

    /* Create or Edit Beacons */

    $scope.createOrEditBeacon = function(action) {
        $scope.action = action;
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/configure/beaconForm.html',
            controller: 'createBeaconCtrl',
            scope: $scope
        });
    };

    $scope.editBeacon = function(beacon){
        $scope.beacon.id = beacon.id;
        $scope.beacon.uid = beacon.uid;
        $scope.beacon.name = beacon.name;
        $scope.title = 'Update';
        $scope.createOrEditBeacon('edit');
    };

    $scope.changeStatus = function(beacon) {
        $scope.beacon = beacon;
        $scope.status = $scope.beacon.status ? "Deactivate" : "Activate";

        $modal.open({
            templateUrl: '/ng-app/templates/configure/changeBeaconStatus.html',
            controller: 'changeBeaconStatusCtrl',
            scope: $scope
        });
    };

    // QrCode List

    $scope.qrPage = 1;
    $scope.qrperPage = 10;
    $scope.qrcodes = [];
    $scope.qrcode = [];
    $scope.qloaded = false;
    $scope.getQrCodesList = function() {
        var url = '/configurations/qr_code_list.json?page='+$scope.qrPage+'&per_page='+$scope.qrperPage;
        $http.get(url)
            .then(function(data) {
                var results = data.data;
                $scope.totalQrItems = results.num_results;
                $scope.qrcodes = results.qrcode_list;
                $scope.qloaded = true;
                if(_.isUndefined($scope.selectedQrCode) || _.isEmpty($scope.selectedQrCode)){
                    $scope.selectedQrCode = _.first($scope.qrcodes);
                } else{
                    $scope.selectedQrCode = _.findWhere($scope.qrcodes, {id: $scope.selectedQrCode.id});
                }
            });
    };

    $scope.getQrCodesList();

    $scope.qrPageChanged = function() {
        $scope.getQrCodesList();
    };

    $scope.selectQrCode = function(qr_code){
        $scope.selectedQrCode = qr_code;
    };

    $scope.createQrCode = function() {
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/configure/qrCodeForm.html',
            controller: 'createQrCodeCtrl',
            scope: $scope
        });
    };

    $scope.form = {};
    $scope.updateBtn = "Save";
    $scope.updateQrCode = function(qr_code){
        $scope.updateBtn = "Saving..";
        var details = {id: qr_code.id,name: qr_code.name, url: qr_code.url};
        $http.post('/configurations/update_qr_code', details).success(function(data) {
            $scope.updateBtn = "Save";
            if (data.errors){
                ConfigValidation.qrServerResponse(data,$scope);
            }
        })
    };

    // Download Qr Code

    $scope.downloadQr = function(qrcode,type){
        $window.location.href = "/configurations/download_qr_code?url="+qrcode.short_url+"&type="+type;
    };

    // Change QR Code status

    $scope.changeQrStatus = function(qr_code) {
        $scope.qrcode = qr_code;
        $scope.status = $scope.qrcode.status ? "Deactivate" : "Activate";

        $modal.open({
            templateUrl: '/ng-app/templates/configure/changeQrStatus.html',
            controller: 'changeQrCodeStatusCtrl',
            scope: $scope
        });
    };
});

InquirlyApp.controller('createBeaconCtrl', function ($scope,$http, $parse,$modalInstance) {

    $scope.form = {};

    if($scope.action == 'add') {
        $scope.beacon.uid = '';
        $scope.beacon.name = '';
        $scope.title = 'Create';
    }

    /* Create New User */
    $scope.isBSubmitted = false;
    $scope.submitBeaconForm = function(beacons){
        var beacon = { uid: $scope.beacon.uid, name: $scope.beacon.name };

        if($scope.action == 'add'){
            $scope.isBSubmitted = true;
            $http.post('/configurations/create_beacon', beacon).success(function(data) {
                asyncServerResponse(data);
            })
        }else {
            beacon["id"] = $scope.beacon.id;
            $scope.isBSubmitted = true;
            $http.post('/configurations/update_beacon', beacon).success(function(data) {
                asyncServerResponse(data);
            })
        }
    };

    var asyncServerResponse = function(data){
        $scope.isBSubmitted = false;
        if(data.errors){
            var errorResponse = beaconErrorResponse(data);
            for (var fieldName in errorResponse) {
                var message = errorResponse[fieldName];
                var serverMessage = $parse('form.beacon.'+fieldName+'.$error.serverMessage');

                if (message == 'VALID') {
                    $scope.form.beacon.$setValidity(fieldName, true, $scope.form.beacon);
                    serverMessage.assign($scope, undefined);
                }
                else {
                    $scope.form.beacon.$setValidity(fieldName, false, $scope.form.beacon);
                    serverMessage.assign($scope, errorResponse[fieldName]);
                }
            }
        }else{
            $scope.getBeaconsList();
            $modalInstance.close('closed');
        }
    };

    var beaconErrorResponse = function(data){
        var fieldState = { uid: 'VALID', name: 'VALID' };

        if (data.errors.uid){
            if (data.errors.uid[0] == "can't be blank") fieldState.uid = 'Please enter Beacon ID';
            if (data.errors.uid[0] == "has already been taken") fieldState.uid = 'Beacon ID already exists';
        }else{
            fieldState.uid = 'VALID';
        }

        if (data.errors.name){
            if (data.errors.name[0] == "has already been taken") fieldState.name = 'Beacon name already exists';
        }else{
            fieldState.name = 'VALID';
        }
        return fieldState;
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('changeBeaconStatusCtrl', function ($scope,$http, $modalInstance) {

    $scope.yes = function () {
        var beacon = {};
        var beforeStatus = $scope.beacon.status ? false : true;
        beacon["id"] = $scope.beacon.id;
        beacon["status"] = beforeStatus;
        $scope.beacon.status = beforeStatus;
        $http.post('/configurations/change_status', beacon).success(function(data) {
            $modalInstance.close();
        })
    };
    $scope.no = function () {
        $modalInstance.dismiss('cancel');
    };
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('createQrCodeCtrl', function ($scope,$http, $parse,$modalInstance) {

    $scope.form = {};
    $scope.isSubmitted = false;
    $scope.submitQrCodeForm = function(){
        $scope.isSubmitted = true;
        var qrCode = { name: $scope.qrcode.name, url: $scope.qrcode.url };
        $http.post('/configurations/create_qr_code', qrCode).success(function(data) {
            asyncServerResponse(data);
        })
    };

    var asyncServerResponse = function(data){
        $scope.isSubmitted = false;
        if(data.errors){
            var errorResponse = qrCodeErrorResponse(data);
            for (var fieldName in errorResponse) {
                var message = errorResponse[fieldName];
                var serverMessage = $parse('form.qrcode.'+fieldName+'.$error.serverMessage');

                if (message == 'VALID') {
                    $scope.form.qrcode.$setValidity(fieldName, true, $scope.form.qrcode);
                    serverMessage.assign($scope, undefined);
                }
                else {
                    $scope.form.qrcode.$setValidity(fieldName, false, $scope.form.qrcode);
                    serverMessage.assign($scope, errorResponse[fieldName]);
                }
            }
        }else{
            $scope.getQrCodesList();
            $modalInstance.close('closed');
        }
    };

    var qrCodeErrorResponse = function(data){
        var fieldState = { name: 'VALID', url: 'VALID' };

        if (data.errors.name){
            if (data.errors.name[0] == "can't be blank") fieldState.name = "Name can't be blank";
            if (data.errors.name[0] == "has already been taken") fieldState.name = 'Name already exists';
        }else{
            fieldState.name = 'VALID';
        }
        if (data.errors.url){
            if (data.errors.url[0] == "is invalid") fieldState.url = 'Please enter valid URL';
        }else{
            fieldState.url = 'VALID';
        }
        return fieldState;
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('changeQrCodeStatusCtrl', function ($scope,$http, $modalInstance) {

    $scope.yes = function () {
        var qrcode = {};
        var beforeStatus = $scope.qrcode.status ? false : true;
        qrcode["id"] = $scope.qrcode.id;
        qrcode["status"] = beforeStatus;
        $scope.qrcode.status = beforeStatus;
        $http.post('/configurations/change_qr_status', qrcode).success(function(data) {
            $modalInstance.close();
        })
    };
    $scope.no = function () {
        $modalInstance.dismiss('cancel');
    };
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});