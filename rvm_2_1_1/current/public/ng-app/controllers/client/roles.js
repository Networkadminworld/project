InquirlyApp.controller('ClientController', function($scope,$http,$modal,$state,Onboarding) {
    $scope.profileData = { myData: [] };
    Onboarding.update_status($scope.profileData);
});

InquirlyApp.controller('RolesController', function($scope,$http,$modal,$state) {

    /* Client Roles */

    $scope.isDisabled = true;
    $scope.isChanged = false;
    $scope.isTenantRole = false;

    $scope.getRoles = function(){

        $http.get('/manage_roles.json').success(function(data) {
            $scope.roles = data;
            if(!_.isEmpty($scope.roles)){
                if(_.isUndefined($scope.selectedRole) || _.isEmpty($scope.selectedRole)){
                    $scope.selectedRole = _.last($scope.roles);
                    $scope.rolePermissions($scope.selectedRole);
                } else{
                    $scope.selectedRole = _.findWhere($scope.roles, {id: $scope.selectedRole.id});
                }

            }
        });
    };

    $scope.getRoles();

    $scope.selectRole = function(role){
        $scope.selectedRole = role;
        $scope.rolePermissions($scope.selectedRole);
    };

    /* Check role permissions */

    $scope.rolePermissions = function(role){

        $http.get('/manage_roles/role_permissions.json?role_id='+role.id).success(function(data) {
            $scope.permissions = data;
        });
    };

    /* Create Role */
    $scope.role = {};
    $scope.createRole = function(action){
        $scope.action = action;
        $scope.title = $scope.action == "new" ? "Create" : "Update";
        if($scope.action == "new"){
            $scope.isTenantRole = false;
        }
        $scope.isSubmitted = false;
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/client/roleForm.html',
            controller: 'createRoleCtrl',
            scope: $scope,
            resolve: {}
        });
        modalInstance.result.then(function () {
        });
    };

    /* Edit Role */

    $scope.editRole = function(role){
        $scope.role.id = role.id;
        $scope.role.name = role.name;
        $scope.role.profile = role.profile;
        $scope.isTenantRole = role.visible_to_tenant;
        $scope.createRole('edit')
    };

    $scope.editPermission = function(){
        $scope.isDisabled = false;
    };

    $scope.changedPermissions = [];

    $scope.changePermission = function(permission){
       if(!$scope.isDisabled){
            $scope.isChanged = true;
            if (_.contains($scope.changedPermissions, permission)) {
                var index = $scope.changedPermissions.indexOf(permission);
                $scope.changedPermissions.splice(index, 1);
                $scope.changedPermissions.push(permission);
            } else {
                $scope.changedPermissions.push(permission);
            }
       }
    };

    $scope.savePermission = function(){
        var permissions  = [];
        var features = { permission: permissions, role_id: $scope.selectedRole.id};
        angular.forEach($scope.changedPermissions, function (permission) {
            permissions.push({feature_id: permission.id, access_level: permission.access_level})
        });
        $http.post('/manage_roles/update_permissions', features).success(function(data) {
            $scope.isDisabled = true;
            $scope.isChanged = false;
        });
    };

    $scope.checkIsTenantRole = function(state){
        $scope.isTenantRole = state ? false : true;
        $scope.isTenantRoleSelected();
    };

    $scope.isTenantRoleSelected = function () {
        if ($scope.isTenantRole) {
            return 'fa fa-check-square-o';
        }else{
            return 'fa fa-square-o';
        }
    };
});

InquirlyApp.controller('createRoleCtrl', function ($scope,$http, $parse,$modalInstance) {

    $scope.form = {};

    if($scope.action == 'new'){
        $scope.role.name = '';
        $scope.role.profile = '';
    }

    $scope.submitRoleForm = function(){
        $scope.isSubmitted = true;
        var roles = { name: $scope.role.name, profile: $scope.role.profile,visible_to_tenant: $scope.isTenantRole };
        if($scope.action == 'new'){
            $http.post('/manage_roles', roles).success(function(data, status) {
                asyncResponse(data);
            })
        }else{
            var url = "/manage_roles/"+ $scope.role.id;
            $http.put(url, roles).success(function(data, status) {
                asyncResponse(data);
            })
        }
    };

    var asyncResponse = function(data){
        $scope.isSubmitted = false;
        if(data.errors){
            var errorResponse = roleErrorResponse(data);
            for (var fieldName in errorResponse) {
                var message = errorResponse[fieldName];
                var serverMessage = $parse('form.role.'+fieldName+'.$error.serverMessage');

                if (message == 'VALID') {
                    $scope.form.role.$setValidity(fieldName, true, $scope.form.role);
                    serverMessage.assign($scope, undefined);
                }
                else {
                    $scope.form.role.$setValidity(fieldName, false, $scope.form.role);
                    serverMessage.assign($scope, errorResponse[fieldName]);
                }
            }
        }else{
            $scope.getRoles();
            $modalInstance.close('closed');
        }
    };

    var roleErrorResponse = function(data){
        var fieldState = { name: 'VALID' };
        if (data.errors.name){
            if (data.errors.name[0] == "Role name shouldn't be blank")  fieldState.name = 'Please enter role name.';
            if (data.errors.name[0] == "Role already exists") fieldState.name = 'Role already exists';
        }else{
            fieldState.name = 'VALID';
        }
        return fieldState;
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});