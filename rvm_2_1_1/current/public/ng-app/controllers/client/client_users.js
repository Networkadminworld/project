InquirlyApp.controller('ClientUsersController', function($scope,$http,$modal) {

    $scope.currentPage = 1;
    $scope.perPage = 10;
    $scope.users = [];
    $scope.loaded = false;
    $scope.alerts = [];
    $scope.searchText = '';
    $scope.isSearch = false;
    $scope.formSubmitted = false;
    $scope.getUserData = function() {
        var url = '/corporate_users.json?page='+$scope.currentPage+'&per_page='+$scope.perPage+'&search_text='+$scope.searchText;
        $http.get(url)
            .then(function(data) {
                $scope.totalItems = data.data.users_list.num_results;
                $scope.users = data.data.users_list.users_list;
                $scope.roles = data.data.roles;
                $scope.tenants = data.data.tenants;
                $scope.allCurrencies = JSON.parse(data.data.currencies);
                $scope.parent_id = data.data.parent_id;
                $scope.currentTenantId = data.data.tenant_id;
                $scope.currentRegion = data.data.tenant_region_id;
                $scope.loaded = true;
                if(_.isUndefined($scope.selectedUser) || _.isEmpty($scope.selectedUser)){
                    $scope.selectedUser = _.first($scope.users);
                    $scope.userDetails($scope.selectedUser);
                } else{
                    $scope.selectedUser = _.findWhere($scope.users, {id: $scope.selectedUser.id});
                    $scope.userDetails($scope.selectedUser);
                }
            });
    };
    $scope.getUserData();
    $scope.pageChanged = function() {
        $scope.getUserData();
    };

    $scope.resetBtn = false;
    $scope.searchUser = function(){
        if(_.isEmpty($scope.searchText)){ return }
        $scope.isSearch = true;
        $scope.selectedUser = '';
        $scope.resetBtn = true;
        $scope.getUserData();
    };

    $scope.resetSearch = function(){
        $scope.isSearch = true;
        $scope.resetBtn = false;
        $scope.searchText = '';
        $scope.selectedUser = '';
        $scope.getUserData();
    };

    /* Create or Edit Users */
    $scope.user = {};
    $scope.regionBlank = false;
    $scope.createOrEditUser = function(action) {
        $scope.action = action;
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/client/createUser.html',
            controller: 'createUserCtrl',
            size: 'lg',
            scope: $scope
        });
    };

    $scope.editUser = function(user){
        $scope.user.id = user.id;
        $scope.user.first_name = user.first_name;
        $scope.user.last_name = user.last_name;
        $scope.user.email = user.email;
        $scope.user.password = '*********';
        $scope.user.password_confirmation = '*********';
        $scope.user.mobile = user.mobile;
        $scope.user.role_id = user.role_id;
        $scope.user.tenant_id = user.tenant_id;
        $scope.user.tenant_region = user.tenant_region;
        $scope.user.currency_id = user.currency_id;
        $scope.title = 'Update User';
        $scope.createOrEditUser('edit');
    };

    $scope.statusSubmitted = false;
    $scope.changeStatus = function(user) {
        $scope.tenantNames = [];
        angular.forEach($scope.tenants, function (tenant) { $scope.tenantNames.push(tenant[0]); });
        if(!_.isNull(user.tenant) && $scope.tenantNames.indexOf(user.tenant) == -1) {
            $scope.showAlertMsg([{type: 'danger', msg: "You can't change the status of Inactive tenant User."}]);
        }else{
            $scope.user = user;
            $scope.status = $scope.user.is_active ? "Deactivate" : "Activate";

            $modal.open({
                templateUrl: '/ng-app/templates/client/changeStatusDialog.html',
                controller: 'changeStatusCtrl',
                scope: $scope
            });
        }
    };

    $scope.resetPassword = function(user) {
        $scope.userForPwdChange = user;
        $scope.userForPwdChange.new_password = '';
        $scope.userForPwdChange.confirm_password = '';
        $modal.open({
            templateUrl: '/ng-app/templates/client/resetPassword.html',
            controller: 'resetPwdCtrl',
            scope: $scope
        });
        $scope.selectUser(user);
    };

    $scope.selectUser = function(user){
        $scope.selectedUser = user;
        $scope.userDetails($scope.selectedUser);
    };

    $scope.isPermitted = function (feature) {

        if (feature.access_level) {
            return 'fa fa-check-square-o select-icon';
        }else{
            return 'fa fa-square-o select-icon';
        }
    };

    /* Check User Details and Permissions */

    $scope.userDetails = function(user){
        if(user){
            $http.get('/manage_roles/role_permissions?role_id='+user.role_id).success(function(data) {
                $scope.permissions = data;
            });
        }
    };

    $scope.showAlertMsg = function(messages){
        $scope.alerts = [];
        $scope.alerts = messages;
    };


    $scope.closeAlert = function(index) {
        $scope.alerts.splice(index, 1);
    };
});


InquirlyApp.controller('createUserCtrl', function ($scope,$http, $parse,$modalInstance,UserValidations,Onboarding) {
    $http.get('/corporate_users/load_regions').then(function(data) {
        $scope.tenantRegions = data.data;
        if(_.isEmpty($scope.tenantRegions)){
            $scope.regionBlank = true;
            $scope.loadTenants();
        }else{
            $scope.tenantRegions = data.data;
        }
    });

    $scope.loadTenants = function() {
        var value = $scope.user.tenant_region;
        value = _.isNull(value) ? '' : value;
        $http.get('/corporate_users/load_tenants?tenant_region_id='+ value+'&region_blank='+$scope.regionBlank).then(function(data) {
            $scope.tenants = data.data;
        });
    };

    $scope.form = {};

    if($scope.action == 'add') {
        $scope.user.first_name = '';
        $scope.user.last_name = '';
        $scope.user.email = '';
        $scope.user.mobile = '';
        $scope.user.role_id = '';
        $scope.user.password = '';
        $scope.user.password_confirmation = '';
        $scope.user.tenant_region = $scope.currentRegion;
        $scope.user.tenant_id = $scope.currentTenantId;
        $scope.user.currency_id = '';
        $scope.title = 'Create User';
        $scope.loadTenants();
    }else{
        $scope.loadTenants();
    }

    /* Create New User */

    $scope.submitUserForm = function(user){
        $scope.formSubmitted = true;
        var users = {};
        users["user"] = {};
        users["user"]["first_name"] = $scope.user.first_name;
        users["user"]["last_name"] = $scope.user.last_name;
        users["user"]["email"] = $scope.user.email;
        users["user"]["mobile"] = $scope.user.mobile;
        users["user"]["password"] = $scope.user.password;
        users["user"]["password_confirmation"] = $scope.user.password_confirmation;
        users["user"]["role_id"] = $scope.user.role_id;
        users["user"]["tenant_id"] = $scope.user.tenant_id;
        users["user"]["parent_id"] = $scope.parent_id;
        users["user"]["currency_id"] = $scope.user.currency_id;
        if($scope.action == 'add'){
            $http.post('/corporate_users.json', users).success(function(data, status, headers, config) {
                $scope.formSubmitted = false;
                if (data.errors){
                    UserValidations.serverResponse(data,$scope);
                }else{
                    $scope.getUserData();
                    Onboarding.update_status($scope.$parent.profileData);
                    $modalInstance.close('closed');
                }
            })
        }else {
            var url = "/corporate_users/"+ $scope.user.id +".json";
            $http.put(url, users).success(function(data, status, headers, config) {
                $scope.formSubmitted = false;
                if (data.errors){
                    UserValidations.serverResponse(data,$scope);
                }else{
                    $scope.getUserData();
                    $modalInstance.close('closed');
                }
            })
        }
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('resetPwdCtrl', function ($scope,$http, $modalInstance,$parse) {

    $scope.submitPwdForm = false;
    $scope.changePwd = function (user) {
        $scope.submitPwdForm = true;
        var users = {};
        users["user_id"] = user.id;
        users["password"] = user.new_password;
        users["password_confirmation"] = user.confirm_password;
        $http.post('/corporate_users/reset_password', users).success(function(data) {
            $scope.submitPwdForm = false;
            if(data.status == 200){
                $scope.showAlertMsg([{ type: 'success', msg: data.message }]);
                $scope.userForPwdChange.new_password = '';
                $scope.userForPwdChange.confirm_password = '';
                $modalInstance.close();
            }else{
                var serverResponse = serverSideErrorResponse(data);
                for (var fieldName in serverResponse) {
                    var message = serverResponse[fieldName];
                    var serverMessage = $parse('form.passwordForm.'+fieldName+'.$error.serverMessage');

                    if (message == 'VALID') {
                        $scope.form.passwordForm.$setValidity(fieldName, true, $scope.form.passwordForm);
                        serverMessage.assign($scope, undefined);
                    }
                    else {
                        $scope.form.passwordForm.$setValidity(fieldName, false, $scope.form.passwordForm);
                        serverMessage.assign($scope, serverResponse[fieldName]);
                    }
                }
            }
        });
    };


    var serverSideErrorResponse = function(data){
        var lengthPattern = "Password length should be 6-16 characters and must contain at least 1 number, 1 small letter, 1 capital letter.";
        var fieldState = {new_password: 'VALID', confirm_password: 'VALID'};

        if (data.errors.password){
            if (data.errors.password[0] == "Please enter Password") fieldState.new_password = 'New Password cannot be blank';
            if (data.errors.password[0] == lengthPattern) fieldState.new_password = lengthPattern;
        }else{
            fieldState.new_password = 'VALID';
        }

        if (data.errors.password_confirmation){
            if (data.errors.password_confirmation[0] == "Please enter confirm password.") fieldState.confirm_password = "Confirm Password cannot be blank";
            if (data.errors.password_confirmation[0] == "Your passwords should match.") fieldState.confirm_password = "Your passwords should match.";
        }else{
            fieldState.confirm_password = 'VALID';
        }

        return fieldState;
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('changeStatusCtrl', function ($scope,$http, $modalInstance) {

    $scope.statusSubmitted = false;
    $scope.yes = function () {
        $scope.statusSubmitted = true;
        var users = {};
        var beforeStatus = $scope.user.is_active ? false : true;
        users["user_id"] = $scope.user.id;
        users["is_active"] = beforeStatus;
        $scope.user.is_active = beforeStatus;
        $http.post('/corporate_users/change_user_status', users).success(function(data) {
            $scope.statusSubmitted = false;
            var status = $scope.user.is_active ? "activated" : "deactivated";
            var message = $scope.user.first_name + " account has successfully " + status;
            $scope.showAlertMsg([({ type: 'success', msg: message })]);
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

InquirlyApp.filter('truncate', function () {
    return function (text, length, end) {
        if (isNaN(length))
            length = 10;

        if (end === undefined)
            end = "...";

        if (text.length <= length || text.length - end.length <= length) {
            return text;
        }
        else {
            return String(text).substring(0, length-end.length) + end;
        }
    };
});