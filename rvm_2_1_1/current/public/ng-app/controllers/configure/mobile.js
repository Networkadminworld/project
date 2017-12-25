InquirlyApp.controller('MobileController', function($scope, $http, $modal,Upload,Onboarding) {
    $scope.currentPage = 1;
    $scope.perPage = 20;
    $scope.customers = [];
    $scope.loaded = false;
    $scope.syncInit = false;
    $scope.state = false;
    $scope.isConsumer = false;
    $scope.showFilter = false;
    $scope.filterText = "No Filter";
    $scope.filtered = false;
    $scope.alerts = [];
    $scope.searchText = '';

    $scope.onUpload = false;
    $scope.csv = { uploadGroupName: '', uploadGroupId: '', duplicateGroup: false, newGroup: false };

    // Filter Model

    $scope.filterInit = function(){
        $scope.filter = [
            {field: 'age', operator: 'eq', value: ''},
            {field: 'gender', operator: 'equals', value: ''},
            {field: 'country', operator: 'contains', value: ''},
            {field: 'state', operator: 'contains', value: ''},
            {field: 'city', operator: 'contains', value: ''},
            {field: 'area', operator: 'contains', value: ''},
            {field: 'custom_field', operator: 'contains', value: ''}
            ];
    };
    $scope.filterInit();

    $scope.getCustomerData = function() {
        var url = '/customers.json?page='+$scope.currentPage+'&per_page='+$scope.perPage+'&filter_condition='+JSON.stringify($scope.filter)+'&search_text='+$scope.searchText;
        $scope.syncInit = true;
        $http.get(url).then(function(data) {
                var customersList = data.data.customers_list;
                $scope.totalItems = customersList.num_results;
                $scope.customers = JSON.parse(customersList.customers_list);
                $scope.groups = JSON.parse(data.data.groups);
                $scope.csv.newGroup = _.isUndefined($scope.groups) || $scope.groups.length == 0 ? true : false;
                $scope.config = data.data.config;
                $scope.loaded = true;
                $scope.syncInit = false;
                $scope.isCsvProcessing = data.data.is_csv_processed;
                if($scope.state) {
                    angular.forEach($scope.customers, function (customer) {
                        if(!_.contains(customer.id) && $scope.uncheckedCustomer.indexOf(customer.id) == -1){
                            $scope.selectedCustomer.push(customer.id);
                        }
                    });
                }
                if($scope.currentPage == 1){
                    $scope.startValue = 0;
                }else{
                    $scope.startValue = (($scope.currentPage * $scope.perPage) - 20) + 1;
                }
                if ($scope.totalItems < 20){
                    $scope.endValue = $scope.totalItems;
                }else{
                    $scope.endValue = ($scope.currentPage * $scope.perPage)
                }
                $scope.loadCountry();
        });
    };

    $scope.getCustomerData();
    $scope.pageChanged = function() {
        $scope.getCustomerData();
    };


    // Upload with Group
    $scope.uploadCsvFile = function(){
        $http.get('/imports/get_upload_status').success(function(data) {
            $scope.isCsvProcessing = data.is_csv_processed;
            if(!$scope.isCsvProcessing){
                $scope.alerts = [{ type: 'danger', msg: 'Your existing upload in progress. Please try after sometimes.' }];
                return
            }
            $modal.open({
                templateUrl: '/ng-app/templates/configure/uploadCsvDialog.html',
                controller: 'uploadCustomerCtrl',
                scope: $scope,
                resolve: {
                    customer: function () {
                        return $scope.customer;
                    }
                }
            });
        });
    };

    $scope.closeAlert = function(index) {
        $scope.alerts.splice(index, 1);
    };

    $scope.addOrEditCustomer = function(action){
        $scope.action = action;
        if($scope.action != "new"){
            $scope.isConsumer = $scope.customer.consumer_id ? true : false;
        }
        $modal.open({
            templateUrl: '/ng-app/templates/configure/createCustomer.html',
            controller: 'createCustomerCtrl',
            size:'lg',
            scope: $scope,
            resolve: {
                states: function() {
                    return $scope.states;
                }
            }
        });
    };

    $scope.editCustomer = function(customer){
        $scope.customer = customer;
        $scope.customer.country = customer.country;
        $scope.customer.state = customer.state;
        $scope.title = 'Update';
        $http.get('/customers/states?name='+ $scope.customer.country).then(function(data) {
            $scope.states = data.data;
            $scope.addOrEditCustomer('edit');
        });
    };

    $scope.removeCustomer = function(customer){
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/configure/removeCustomer.html',
            controller: 'removeCustomerCtrl',
            scope: $scope,
            resolve: {
                customer: function () {
                    return customer;
                }
            }
        });
        modalInstance.result.then(function (selectedItem) {
            $scope.selected = selectedItem;
        });
    };

    $scope.buttonText = "Save";
    $scope.saveConfig = function(){
        if(!$scope.config.reply_email && !$scope.config.from_email && !$scope.config.from_name){
            return;
        }

        $scope.buttonText = "Saving...";
        var mobileConfig = {};
        mobileConfig['reply_email'] = $scope.config.reply_email;
        mobileConfig['from_email'] = $scope.config.from_email;
        mobileConfig['from_name'] = $scope.config.from_name;
        $http.post('/customers/update_config',mobileConfig).then(function(data) {
            $scope.buttonText = "Save";
        });
    };

    /* Select Filter */

    $scope.selectedCustomer = [];
    $scope.uncheckedCustomer = [];
    $scope.setSelectedCustomer = function (id) {
        if (_.contains($scope.selectedCustomer, id)) {
            $scope.selectedCustomer = _.without($scope.selectedCustomer, id);
        } else {
            $scope.selectedCustomer.push(id);
        }
        if (_.contains($scope.uncheckedCustomer, id)) {
            $scope.uncheckedCustomer.splice($scope.uncheckedCustomer.indexOf(id), 1);
        }else{
            $scope.uncheckedCustomer.push(id);
        }

        return false;
    };

    $scope.isSelected = function (id) {
        if (_.contains($scope.selectedCustomer, id)) {
            return 'fa fa-check-square-o select-icon';
        }else{
            return 'fa fa-square-o select-icon';
        }

    };

    $scope.clearAll = function(){
        $scope.selectedGroup = [];
        $scope.selectedCustomer = [];
        $scope.state = false;
        $scope.uncheckedCustomer = [];
        $scope.filterInit();
        $scope.resetSearch();
    };

    $scope.setSelectedAll  = function(state){
        $scope.state = state ? false : true;
        if($scope.state){
            $scope.selectedCustomer = [];
            $scope.uncheckedCustomer = [];
            angular.forEach($scope.customers, function (customer) {
                $scope.selectedCustomer.push(customer.id);
            });
        }else{
            $scope.selectedCustomer = [];
        }
    };

    $scope.isSelectAll = function(){
        if ($scope.state && $scope.uncheckedCustomer.length == 0) {
            return 'fa fa-check-square-o select-icon';
        }else{
            return 'fa fa-square-o select-icon';
        }
    };
    /* Create Group */

    $scope.getGroups = function(){
        $http.get('/customers/contact_groups').success(function(data) {
            $scope.groups = data;
        });
    };

    $scope.selectedGroup = [];
    $scope.groupName = '';

    $scope.addToGroup = function(){
        $scope.getGroups();

        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/configure/groupDialog.html',
            controller: 'customerGroupCtrl',
            size:'sm',
            scope: $scope,
            resolve: {}
        });
    };

    $scope.isEdit = false;
    $scope.editGroupName = function(group){
        $scope.groupName = group.name;
        $scope.groupID = group.id;
        $scope.isEdit = true;
    };

    $scope.updateGroup = function(){
        var groupParams = { id: $scope.groupID, name: $scope.groupName };
        $http.post('/customers/update_group_name', groupParams).success(function(data) {
            $scope.groupName = '';
            $scope.isEdit = false;
            $scope.getGroups();
            $scope.clearAll();
        });
    };

    $scope.cancelEdit = function(){
        $scope.isEdit = false;
        $scope.groupName = '';
        $scope.groupID = '';
    };

    $scope.showGroupContacts = function(group){

        if(group.contacts == 0){
            return;
        }

        $scope.group = group;
        $scope.groupNameUpper = angular.uppercase(group.name);
        $scope.page = 1;
        $scope.limit = 20;
        $scope.groupCustomers = [];
        $scope.groupLoaded = false;
        $scope.syncGroup = false;
        $scope.getGroupCustomerData = function() {
            var url = '/customers/group_customers.json?page='+$scope.page+'&per_page='+$scope.limit+'&group_id='+group.id;
            $scope.syncGroup = true;
            $http.get(url).then(function(data) {
                var customersList = data.data.customers_list;
                $scope.totalGroupContacts = customersList.num_results;
                $scope.groupCustomers = JSON.parse(customersList.customers_list);
                $scope.groupLoaded = true;
                $scope.syncGroup = false;
            });
        };
        $scope.getGroupCustomerData();
        $scope.groupPageChanged = function() {
            $scope.getGroupCustomerData();
        };
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/configure/groupContactsDialog.html',
            controller: 'groupsContactCtrl',
            size:'lg',
            scope: $scope,
            resolve: {}
        });
    };

    $scope.duplicateGroup = false;
    $scope.$watch("groupName", function(value) {
        $scope.duplicateGroup = false
    }, true);

    $scope.isSubmitted = false;
    $scope.createGroup = function(){
      $scope.groupNames = [];

      angular.forEach($scope.groups, function (group) { $scope.groupNames.push(group.name); });

      if (_.contains($scope.groupNames, $scope.groupName)) {
           $scope.duplicateGroup = true;
           return;
      }
      $scope.isSubmitted = true;
      var groupParams = {groups: $scope.selectedGroup, customers: $scope.selectedCustomer, group_name: $scope.groupName };
      $http.post('/customers/update_group_info', groupParams).success(function(data) {
        $scope.groupName = '';
        $scope.getGroups();
        $scope.clearAll();
        $scope.isSubmitted = false;
      });
    };

    $scope.removeGroup = function(group){
        $scope.contacts = group.contacts;

        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/configure/removeGroupDialog.html',
            controller: 'removeGroupsCtrl',
            size:'lg',
            scope: $scope,
            resolve: {
                group: function () {
                    return group;
                }
            }
        });
    };

    /* Check Consumer */
    $scope.checkIsConsumer = function(state){
        $scope.isConsumer = state ? false : true;
        $scope.isConsumerSelected();
    };

    $scope.isConsumerSelected = function () {
        if ($scope.isConsumer) {
            return 'fa fa-check-square-o';
        }else{
            return 'fa fa-square-o';
        }
    };

    $scope.openFilter = function(){
        $scope.showFilter = $scope.showFilter ? false : true;
        if($scope.showFilter){
            $scope.loadCountry();
        }
    };

    $scope.hideFilter = function(){
        $scope.showFilter = false;
    };

    $scope.removeFilter = function(){
        $scope.showFilter = false;
        $scope.filterText = "No Filter";
        $scope.filtered = false;
        $scope.filterInit();
        $scope.getCustomerData();
    };

    $scope.filterData = function(){
        $scope.showFilter = false;
        $scope.filterText = "Filtered";
        $scope.filtered = true;
        $scope.getCustomerData();
    };

    $scope.uploadNewGroup = function(){
        $scope.csv.newGroup = !$scope.csv.newGroup;
    };

    $scope.isUploadNewGroup = function () {
        if ($scope.csv.newGroup) {
            return 'fa fa-close group-add-icon fnt-orng add-group-upload';
        }else{
            return 'fa fa-plus group-add-icon fnt-orng add-group-upload';
        }
    };

    $scope.showAlert = function(data){
        $scope.alerts  = data;
    };

    /* Load country list */

    $scope.loadCountry = function(){
        $http.get('/customers/all_countries').then(function(data) {
            $scope.countries = data.data;
        });
    };

    $scope.countryStates = function(country) {
        $http.get('/customers/states?name='+ country).then(function(data) {
            $scope.states = data.data;
        });
    };

    $scope.resetBtn = false;
    $scope.searchCustomer = function(){
        if(_.isEmpty($scope.searchText)){ return }
        $scope.isSearch = true;
        $scope.resetBtn = true;
        $scope.getCustomerData();
    };

    $scope.resetSearch = function(){
        $scope.isSearch = true;
        $scope.resetBtn = false;
        $scope.searchText = '';
        $scope.getCustomerData();
    };
});

InquirlyApp.controller('createCustomerCtrl', function ($scope,$http, $parse,$modalInstance,Onboarding,states) {

    $scope.states = states;

    $scope.loadStates = function(){
        $http.get('/customers/states?name='+ $scope.customer.country).then(function(data) {
            $scope.states = data.data;
        });
    };

    if($scope.action == 'new') {
        $scope.customer = {};
        $scope.customer.groups = [];
        $scope.title = 'Create';
    }else{
        $scope.customer.groups = [];
    }

    $scope.customer.selected_groups = [];

    $scope.isSubmitted = false;
    $scope.submitForm = function(customer){
        $scope.isSubmitted = true;
        var customers = {};
        customers["customer"] = {};
        customers["customer"]["email"] = customer.email || '';
        customers["customer"]["customer_name"] = customer.customer_name || '';
        customers["customer"]["mobile"] = customer.mobile || '';
        customers["customer"]["age"] = customer.age || '';
        customers["customer"]["gender"] = customer.gender || '';
        customers["customer"]["country"] = customer.country || '';
        customers["customer"]["state"] = customer.state || '';
        customers["customer"]["city"] = customer.city || '';
        customers["customer"]["area"] = customer.area || '';
        customers["customer"]["custom_field"] = customer.custom_field || '';
        customers["contact_groups"] = customer.selected_groups || '';
        customers["is_consumer"] = $scope.isConsumer;
       if($scope.action == 'new'){
            $http.post('/customers',customers).then(function(data) {
                   serverResponse(data.data);
            });
       }else{
           $http.put("/customers/"+ customer.id, customers).success(function(data) {
               serverResponse(data);
           })
       }
    };

    var serverResponse = function(data){
        $scope.isSubmitted = false;
        if(data && data.errors){
            var errorResponse = customerErrorResponse(data);
            for (var fieldName in errorResponse) {
                var message = errorResponse[fieldName];
                var serverMessage = $parse('form.customers.'+fieldName+'.$error.serverMessage');

                if (message == 'VALID') {
                    $scope.form.customers.$setValidity(fieldName, true, $scope.form.customers);
                    serverMessage.assign($scope, undefined);
                }
                else {
                    $scope.form.customers.$setValidity(fieldName, false, $scope.form.customers);
                    serverMessage.assign($scope, errorResponse[fieldName]);
                }
            }
        }else{
            $modalInstance.close();
            $scope.getCustomerData();
            Onboarding.update_status($scope.$parent.profileData);
        }
    };

    var customerErrorResponse = function(data){
        var fieldState = {email: 'VALID', mobile: 'VALID', age: 'VALID', country: 'VALID'};
        if (data.errors.email){
            if (data.errors.email[0] == "can't be blank")  fieldState.email = "Email can't be blank";
            if (data.errors.email[0] == "has already been taken")  fieldState.email = 'Email already been taken';
            if (data.errors.email[0] == "is invalid")  fieldState.email = 'Invalid Email';
        }else if(data.errors.mobile){
            if (data.errors.mobile[0] == "can't be blank")  fieldState.mobile = "Mobile number can't be blank";
            if (data.errors.mobile[0] == "is invalid")  fieldState.mobile = "Invalid mobile number.";
        }else if(data.errors.age){
            if (data.errors.age[0] == "is not a number")  fieldState.age = "Invalid age.";
            if(data.errors.age[0] == "is too long (maximum is 3 characters)" || data.errors.age[0] == "is too short (minimum is 2 characters)") fieldState.age = "Invalid age";
        }else if(data.errors.country){
            if (data.errors.country[0] == "can't be blank")  fieldState.country = "Country can't be blank";
        }
        return fieldState;
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('removeCustomerCtrl', function ($scope,$http, $modalInstance, customer,Onboarding) {
    $scope.yes = function () {
        var config = {
            headers:  {
                'X-CSRF-Token': $('meta[name=csrf-token]').attr('content'),
                'Content-Type': 'application/json'
            }
        };
        $http.delete('/customers/'+customer.id,config).then(function(data) {
            $scope.getCustomerData();
            Onboarding.update_status($scope.$parent.profileData);
            $modalInstance.close();
        });
    };
    $scope.no = function () {
        $modalInstance.dismiss('cancel');
    };
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('customerGroupCtrl', function ($scope,$http, $modalInstance) {

    $scope.setSelectedGroup = function (id) {
        if (_.contains($scope.selectedGroup, id)) {
            $scope.selectedGroup = _.without($scope.selectedGroup, id);
        } else {
            $scope.selectedGroup.push(id);
        }

        return false;
    };

    $scope.isSelectedGroup = function (id) {
        if (_.contains($scope.selectedGroup, id)) {
            return 'fa fa-check-square-o group-select';
        }else{
            return 'fa fa-square-o group-select';
        }
    };

    $scope.duplicateMGroup = false;
    $scope.modalGroupName = '';
    $scope.$watch("modalGroupName", function(value) {
        $scope.duplicateMGroup = false
    }, true);
    $scope.addGroup = function(){
        $scope.groupNames = [];

        angular.forEach($scope.groups, function (group) { $scope.groupNames.push(group.name); });

        if (_.contains($scope.groupNames, $scope.modalGroupName)) {
            $scope.duplicateMGroup = true;
            return;
        }
        $scope.isSubmitted = true;
        var groupParams = { groups: $scope.selectedGroup, customers: $scope.selectedCustomer,
                            group_name: $scope.modalGroupName, state: $scope.state,
                            filter_condition: JSON.stringify($scope.filter),search_text: $scope.searchText,
                            unchecked_customers: $scope.uncheckedCustomer};
        $http.post('/customers/update_group_info', groupParams).success(function(data) {
            $scope.modalGroupName = '';
            $scope.getGroups();
            $scope.clearAll();
            $scope.isSubmitted = false;
            $modalInstance.close();
        });
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('groupsContactCtrl', function ($scope,$http, $modalInstance) {

    $scope.removeGroupCustomer = function(group,customer){
        $scope.groupCustomers = _.without($scope.groupCustomers, _.findWhere($scope.groupCustomers, {id: customer.id}));
        var config = {
            headers:  {
                'X-CSRF-Token': $('meta[name=csrf-token]').attr('content'),
                'Content-Type': 'application/json'
            }
        };
        $http.post('/customers/remove_group_customer?group_id='+group.id+'&customer_id='+customer.id,config).success(function(data) {
            $scope.getGroups();
            $scope.clearAll();
            if($scope.groupCustomers.length == 0) { $modalInstance.close();}
        });
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('removeGroupsCtrl', function ($scope,$http, $modalInstance,group) {

    $scope.yes = function () {
        $http.post('/customers/remove_group?group_id='+group.id).success(function(data) {
            $scope.getGroups();
            $scope.clearAll();
            $modalInstance.close();
        });
    };
    $scope.no = function () {
        $modalInstance.dismiss('cancel');
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('uploadCustomerCtrl', function ($scope,$http,Upload, Onboarding,$modalInstance){

    $scope.form = {};
    $scope.csvSubmitted = false;
    $scope.uploadText = "Upload";

    $scope.$watch("csv.uploadGroupName", function(value) {
        $scope.csv.duplicateGroup = false
    }, true);

    $scope.csvUpload = function (files) {
        $scope.csvSubmitted = true;
        $scope.uploadText = "Uploading...";
        $scope.groupsInCsv = [];

        angular.forEach($scope.groups, function (group) { $scope.groupsInCsv.push(group.name); });

        if (_.contains($scope.groupsInCsv, $scope.csv.uploadGroupName)) {
            $scope.csv.duplicateGroup = true;
            return;
        }

        if (files){
            for (var i = 0; i < files.length; i++) {
                $scope.onUpload = true;
                var file = files[i];
                $scope.upload = Upload.upload({
                    url: '/imports/create_customer_info',
                    method: 'POST',
                    headers: {'X-CSRF-Token': $('meta[name=csrf-token]').attr('content'),'Content-Type': 'application/json'},
                    withCredentials: true,
                    fields: {
                        'customer[group_name]': $scope.csv.uploadGroupName,
                        'customer[is_new_group]': $scope.csv.newGroup,
                        'customer[group_id]': $scope.csv.uploadGroupId
                    },
                    file: file,
                    fileFormDataName: 'business_customer_info[datafile]'
                }).success(function (data) {
                        $scope.onUpload = false;
                        $scope.alerts = [{ type: 'success', msg: data["success"] }];
                        $scope.showAlert($scope.alerts);
                        Onboarding.update_status($scope.$parent.profileData);
                        $scope.csvSubmitted = false;
                        $scope.uploadText = "Upload";
                        $modalInstance.close();
                });
            }
        }
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});