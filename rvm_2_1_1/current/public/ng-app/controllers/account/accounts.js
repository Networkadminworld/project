InquirlyApp.controller('AccountSettingsController', function($scope,Onboarding){
    $scope.profileData = { myData: [] };
    Onboarding.update_status($scope.profileData);
});

InquirlyApp.controller('AccountController', function($scope,$rootScope,$http,$parse,$modal,Upload,Session,UserValidations) {
  var user = {};
  user["id"] = {};
    $scope.imageUploading = false;
    $scope.form = {};
    $http.get('/account/user_settings.json').
        success(function(data, status, headers, config) {
            $scope.settings = data.details;
            $scope.settings.first_name = toCamelCase(data.details.first_name);
            $scope.settings.last_name = toCamelCase(data.details.last_name);
            $scope.isTenantUser = data.is_tenant_user;
            $scope.allCurrencies = JSON.parse(data.currencies);
            $scope.user_profile = data.profile ? data.profile : '/ng-app/Images/thumbnail-default.jpg'
        }).
        error(function(data, status, headers, config) {
            // log error
    });

    function toCamelCase(value){
       if(value){
        return value.replace(/\w\S*/g, function(txt){ return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
       }
    }
    $scope.upload_image = function (files) {
        /* With File Upload */
        if (files){
            for (var i = 0; i < files.length; i++) {
                $scope.imageUploading = true;
                var file = files[i];
                $scope.upload = Upload.upload({
                    url: '/account/upload_profile_image',
                    method: 'POST',
                    headers: {'X-CSRF-Token': $('meta[name=csrf-token]').attr('content')},
                    withCredentials: true,
                    fields: '',
                    file: file
                }).success(function (data, status, headers, config) {
                  $scope.imageUploading = false;
                  $scope.user_profile = data.profile_img ? data.profile_img : '/ng-app/Images/thumbnail-default.jpg';
                  $rootScope.session.data.user_profile_top = data.profile_top ? data.profile_top : '/ng-app/Images/thumbnail-default.jpg';
                });
            }
        }
    };


    $scope.removeImage = function(settings) {
      $scope.upload = Upload.upload({
          url: '/account/destroy_profile_image',
          method: 'POST',
          headers: {'X-CSRF-Token': $('meta[name=csrf-token]').attr('content')},
          withCredentials: true,
          fields: {
            'user_id': settings.id
          }
      }).success(function (data, status, headers, config) {
         $scope.user_profile = '/ng-app/Images/thumbnail-default.jpg';
         $rootScope.session.data.user_profile_top = '/ng-app/Images/male_user_icon.png';
      });
    };




    /* Update User details */
    $scope.saveUserDetails = function(settings) {
        var userDetails = {};
        userDetails["user"] = {};
        userDetails["user"]["id"] = settings.id;
        userDetails["user"]["first_name"] = settings.first_name;
        userDetails["user"]["last_name"] = settings.last_name;
        userDetails["user"]["email"] = settings.email;
        userDetails["user"]["mobile"] = settings.mobile;
        userDetails["user"]["currency_id"] = settings.currency_id;
        $http.post('/account/update_user_details', userDetails).
            success(function(data, status, headers, config) {
                if (data.success){
                    $scope.alerts = [{ type: 'success', msg: data["success"] }];
                    Session.data.user_first_name = $scope.settings.first_name = toCamelCase(data.account.first_name);
                    Session.data.user_last_name = $scope.settings.last_name = toCamelCase(data.account.last_name);
                    $scope.settings.email = data.account.email;
                    $scope.settings.mobile = data.account.mobile;
                    $scope.settings.currency_id = data.account.currency_id;
                    UserValidations.serverResponse(data,$scope);
                }else{
                    UserValidations.serverResponse(data,$scope);
                }
            }).
            error(function(data, status, headers, config) {
                // log error
        });
    };

    $scope.closeAlert = function(index) {
        $scope.alerts.splice(index, 1);
    };

    /* Change Password */
    $scope.changePassword = function() {
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/account/changePassword.html',
            controller: 'changePasswordCtrl',
            scope: $scope,
            resolve: {
                passwordForm: function () {
                    return $scope.passwordForm;
                }
            }
        });
        modalInstance.result.then(function (selectedItem) {
            $scope.selected = selectedItem;
        });
    }
});

InquirlyApp.controller('changePasswordCtrl', function ($scope,$http, $parse,$modalInstance,passwordForm) {
    $scope.form = {};
    $scope.submitForm = function(user){
        var passwords = {};
        passwords["user"] = {};
        passwords["user"]["current_password"] = $scope.user ? $scope.user.oldpassword : '';
        passwords["user"]["password"] = $scope.user ? $scope.user.newpassword : '';
        passwords["user"]["password_confirmation"] = $scope.user ? $scope.user.confirmpassword : '';
        $http.post('/account/update_password', passwords).
            success(function(data, status, headers, config) {
                if (data.success){
                    successResponse(data);
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
            }).
            error(function(data, status, headers, config) {
                // log error
        });
    };

    /* Success Response */
    var successResponse = function(data) {
        $scope.alerts = [{ type: 'success', msg: data }];
        $modalInstance.close('closed');
    };

    $scope.closeAlert = function(index) {
        $scope.alerts.splice(index, 1);
    };

    var serverSideErrorResponse = function(data){
        var lengthPattern = "Password length should be 6-16 characters and must contain at least 1 number, 1 small letter, 1 capital letter.";
        var fieldState = {oldpassword: 'VALID', newpassword: 'VALID', confirmpassword: 'VALID'};

        if (data.errors.current_password){
            if (data.errors.current_password[0] == "can't be blank")  fieldState.oldpassword = 'Current Password cannot be blank';
            if (data.errors.current_password[0] == "is invalid") fieldState.oldpassword = 'Current Password is invalid';
        }else{
            fieldState.oldpassword = 'VALID';
        }

        if (data.errors.password){
          if (data.errors.password[0] == "Please enter Password") fieldState.newpassword = 'New Password cannot be blank';
          if (data.errors.password[0] == lengthPattern) fieldState.newpassword = lengthPattern;
        }else{
            fieldState.newpassword = 'VALID';
        }

        if (data.errors.password_confirmation){
          if (data.errors.password_confirmation[0] == "Please enter confirm password.") fieldState.confirmpassword = "Confirm Password cannot be blank";
          if (data.errors.password_confirmation[0] == "Your passwords should match.") fieldState.confirmpassword = "Your passwords should match.";
        }else{
            fieldState.confirmpassword = 'VALID';
        }

        return fieldState;
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});
