InquirlyApp.controller('ClientTenantsController', function($scope, $http, $modal,fileReader) {
    $scope.currentPage = 1;
    $scope.perPage = 10;
    $scope.tenants = [];
    $scope.loaded = false;
    $scope.searchText = '';
    $scope.getTenantData = function() {
        var url = '/tenants.json?page='+$scope.currentPage+'&per_page='+$scope.perPage+'&search_text='+$scope.searchText;
        $http.get(url).success(function(data) {
                $scope.totalItems = data.tenants_list.num_results;
                $scope.tenants = data.tenants_list.tenants_list;
                $scope.tenantRegions = data.tenant_regions;
                $scope.tenantTypes = data.tenant_types;
                $scope.clientID = data.client_id;
                $scope.loaded = true;
        });
    };
    $scope.getTenantData();
    $scope.pageChanged = function() {
        $scope.getTenantData();
    };

    $scope.onLogoSelect = function(files,tenant) {
        var file = files[0];
        if(file && file.type.match(/^image\/.*/)){
            fileReader.readAsDataUrl(file, $scope)
                .then(function(result) {
                    tenant.logo = result;
                });
        }
    };

    /* Create or Edit Tenants */
    $scope.tenant = {};
    $scope.submitted = false;
    $scope.createOrEditTenant = function(action) {
        $scope.action = action;
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/client/createTenant.html',
            controller: 'createTenantCtrl',
            size:'lg',
            scope: $scope,
            resolve: {}
        });
        modalInstance.result.then(function (selectedItem) {
            $scope.selected = selectedItem;
        });
    };

    $scope.editTenant = function(tenant){
        $scope.tenant.id = tenant.id;
        $scope.tenant.name = tenant.name;
        $scope.tenant.address = tenant.address;
        $scope.tenant.email = tenant.email;
        $scope.tenant.phone = tenant.phone;
        $scope.tenant.contact_number = tenant.contact_number;
        $scope.tenant.tenant_region_id = tenant.tenant_region_id;
        $scope.tenant.tenant_type_id = tenant.tenant_type_id;
        $scope.tenant.website_url = tenant.website_url;
        $scope.tenant.facebook_url = tenant.facebook_url;
        $scope.tenant.twitter_url = tenant.twitter_url;
        $scope.tenant.linkedin_url = tenant.linkedin_url;
        $scope.tenant.redirect_url = tenant.redirect_url;
        $scope.tenant.lat = tenant.lat;
        $scope.tenant.lng = tenant.lng;
        $scope.tenant.logo = tenant.logo_url;
        $scope.tenant.client_id = $scope.clientID;
        $scope.title = 'Update Tenant';
        $scope.createOrEditTenant('edit');
    };

    $scope.changeStatusSubmitted = false;
    $scope.changeStatus = function(tenant) {
        $scope.tenant = tenant;
        $scope.status = $scope.tenant.is_active ? "Deactivate" : "Activate";

        $modal.open({
            templateUrl: '/ng-app/templates/client/tenantStatusDialog.html',
            controller: 'tenantStatusCtrl',
            scope: $scope
        });
    };

    // Map

    $scope.loadMap = function(){

        var url = '/tenants/load_geo_details?search_text='+$scope.searchText;
        $http.get(url).success(function(data) {
            $scope.tenantLists = data[0];
            $scope.defaultInfo = data[1];

            var mapOptions = {
                zoom: 10,
                center: new google.maps.LatLng($scope.defaultInfo.lat, $scope.defaultInfo.long),
                mapTypeId: google.maps.MapTypeId.TERRAIN
            };

            $scope.map = new google.maps.Map(document.getElementById('map'), mapOptions);

            $scope.markers = [];

            var infoWindow = new google.maps.InfoWindow();

            var createMarker = function (info){

                var marker = new google.maps.Marker({
                    map: $scope.map,
                    position: new google.maps.LatLng(info.lat, info.long),
                    title: info.name
                });
                marker.content = '<div class="infoWindowContent">' + info.address + '</div>';

                google.maps.event.addListener(marker, 'click', function(){
                    infoWindow.setContent('<h3 class="map-header">' + marker.title + '</h3>' + marker.content);
                    infoWindow.open($scope.map, marker);
                });

                $scope.markers.push(marker);

            };

            for (i = 0; i < $scope.tenantLists.length; i++){
                createMarker($scope.tenantLists[i]);
            }

            $scope.openInfoWindow = function(e, selectedMarker){
                e.preventDefault();
                google.maps.event.trigger(selectedMarker, 'click');
            }
        });
    };
    $scope.loadMap();

    $scope.resetBtn = false;
    $scope.searchTenant = function(){
        if(_.isEmpty($scope.searchText)){ return }
        $scope.isSearch = true;
        $scope.resetBtn = true;
        $scope.getTenantData();
        $scope.loadMap();
    };

    $scope.resetTenant = function(){
        $scope.isSearch = true;
        $scope.resetBtn = false;
        $scope.searchText = '';
        $scope.getTenantData();
        $scope.loadMap();
    };

    $scope.region = {};
    $scope.type = {};
    $scope.tenant_plan = {};
    $scope.duplicateRegion = false;
    $scope.duplicateType = false;
    $scope.isRegionSubmitted = false;
    $scope.isTypeSubmitted = false;
    $scope.tenantConfig = function(){
        $modal.open({
            templateUrl: '/ng-app/templates/client/tenantConfig.html',
            controller: 'TenantConfigCtrl',
            size:'lg',
            scope: $scope,
            resolve: {}
        });
    };

    $scope.updateRegion = function(values,state){
        if(state == 'type'){
            $scope.tenantTypes = values;
        }else{
            $scope.tenantRegions = values;
        }
    };

    $scope.loadClientPlan = function(){
        $http.get("/tenants/get_client_plan").success(function(data) {
            $scope.client_plan = data[0];
            $scope.client_plan_channels = data[1];
        });
    };
});

InquirlyApp.controller('createTenantCtrl', function ($scope,$http, $parse,$modalInstance,Upload) {
    $scope.form = {};

    if($scope.action == 'add') {
        $scope.tenant = {};
        $scope.title = 'Create Tenant';
    }

    /* Create New Tenant */
    $scope.submitTenantForm = function(file){
        $scope.submitted = true;
        var tenants = {};
        if($scope.action == 'add'){

            if (file){
                $scope.fileUploadFn(file,'/tenants.json', 'POST');
            }else{
                tenants["tenant"] = {};
                tenants["tenant"]["name"] = $scope.tenant.name;
                tenants["tenant"]["address"] = document.getElementById('txtPlaces').value;
                tenants["tenant"]["email"] = $scope.tenant.email;
                tenants["tenant"]["phone"] = $scope.tenant.phone;
                tenants["tenant"]["contact_number"] = $scope.tenant.contact_number;
                tenants["tenant"]["tenant_type_id"] = $scope.tenant.tenant_type_id;
                tenants["tenant"]["tenant_region_id"] = $scope.tenant.tenant_region_id;
                tenants["tenant"]["website_url"] = $scope.tenant.website_url;
                tenants["tenant"]["facebook_url"] = $scope.tenant.facebook_url;
                tenants["tenant"]["twitter_url"] = $scope.tenant.twitter_url;
                tenants["tenant"]["linkedin_url"] = $scope.tenant.linkedin_url;
                tenants["tenant"]["redirect_url"] = $scope.tenant.redirect_url;
                tenants["tenant"]["client_id"] = $scope.clientID;
                tenants["tenant"]["lat"] = document.getElementById('lat').value;
                tenants["tenant"]["lng"] = document.getElementById('lng').value;

                $http.post('/tenants.json', tenants).success(function(data) {
                    asyncResponse(data);
                })
            }
        }else {
            var url = "/tenants/"+ $scope.tenant.id +".json";
            if(file){
                $scope.fileUploadFn(file,url,'PUT');
            }else{
                tenants["tenant"] = $scope.tenant;
                tenants["tenant"]["address"] = document.getElementById('txtPlaces').value;
                tenants["tenant"]["lat"] =  _.isEmpty(document.getElementById('lat').value) ? $scope.tenant.lat : document.getElementById('lat').value;
                tenants["tenant"]["lng"] =  _.isEmpty(document.getElementById('lng').value) ? $scope.tenant.lng : document.getElementById('lng').value;
                $http.put(url, tenants).success(function(data) {
                    asyncResponse(data);
                })
            }
        }

    };

    $scope.fileUploadFn = function(file,path,method){

        $scope.upload = Upload.upload({
            url: path,
            method: method,
            headers: {'X-CSRF-Token': $('meta[name=csrf-token]').attr('content')},
            withCredentials: true,
            fields: {
                'tenant[name]': $scope.tenant.name || '',
                'tenant[address]': document.getElementById('txtPlaces').value || '',
                'tenant[email]': $scope.tenant.email || '',
                'tenant[phone]': $scope.tenant.phone || '',
                'tenant[contact_number]': $scope.tenant.contact_number || '',
                'tenant[tenant_type_id]': $scope.tenant.tenant_type_id,
                'tenant[tenant_region_id]': $scope.tenant.tenant_region_id,
                'tenant[website_url]': $scope.tenant.website_url || '',
                'tenant[facebook_url]': $scope.tenant.facebook_url || '',
                'tenant[twitter_url]': $scope.tenant.twitter_url || '',
                'tenant[linkedin_url]': $scope.tenant.linkedin_url || '',
                'tenant[redirect_url]': $scope.tenant.redirect_url || '',
                'tenant[client_id]': $scope.clientID || '',
                'tenant[lat]': document.getElementById('lat').value,
                'tenant[lng]': document.getElementById('lng').value
            },
            file: file,
            fileFormDataName: 'tenant[logo]'
        }).success(function (data) {
                asyncResponse(data);
        })
    };

    var asyncResponse = function(data){
        $scope.submitted = false;
        if(data.errors){
            var errorResponse = tenantErrorResponse(data);
            for (var fieldName in errorResponse) {
                var message = errorResponse[fieldName];
                var serverMessage = $parse('form.tenant.'+fieldName+'.$error.serverMessage');

                if (message == 'VALID') {
                    $scope.form.tenant.$setValidity(fieldName, true, $scope.form.tenant);
                    serverMessage.assign($scope, undefined);
                }
                else {
                    $scope.form.tenant.$setValidity(fieldName, false, $scope.form.tenant);
                    serverMessage.assign($scope, errorResponse[fieldName]);
                }
            }
        }else{
            $scope.getTenantData();
            $scope.loadMap();
            $modalInstance.close('closed');
        }
    };

    var tenantErrorResponse = function(data){
        var fieldState = {name: 'VALID'};
        if (data.errors.name){
            if (data.errors.name[0] == "Please enter tenant name.")  fieldState.name = 'Please enter tenant name.';
            if (data.errors.name[0] == "Tenant already exists.") fieldState.name = 'Tenant already exists.';
        }else{
            fieldState.name = 'VALID';
        }
        return fieldState;
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('tenantStatusCtrl', function ($scope,$http, $modalInstance) {
    $scope.changeStatusSubmitted = false;

    $scope.yes = function () {
        $scope.changeStatusSubmitted = true;
        var tenants = {};
        var beforeStatus = $scope.tenant.is_active ? false : true;
        tenants["tenant_id"] = $scope.tenant.id;
        tenants["is_active"] = beforeStatus;
        $scope.tenant.is_active = beforeStatus;
        $http.post('/tenants/change_tenant_status', tenants).success(function(data) {
            $scope.changeStatusSubmitted = false;
            var status = $scope.tenant.is_active ? "activated" : "deactivated";
            var message = $scope.tenant.name + "has successfully " + status;
            $scope.alerts = [({ type: 'success', msg: message })];
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

InquirlyApp.controller('TenantConfigCtrl', function ($scope,$http, $modalInstance) {
    $scope.state = "region";

    $scope.form = {};

    $scope.initForm = function(){
        $scope.region.name = '';
        $scope.region.description = '';
        $scope.type.name = '';
        $scope.type.description = '';
        $scope.regionBlank = false;
        $scope.regionDuplicate = false;

        $scope.typeBlank = false;
        $scope.typeDuplicate = false;

        $scope.tenant_plan.email_count = '',
        $scope.tenant_plan.sms_count = '',
        $scope.tenant_plan.customer_records_count = '',
        $scope.tenant_plan.campaigns_count = '',
        $scope.tenant_plan.fb_boost_budget = '',
        $scope.tenant_plan.total_reach = ''
    };
    $scope.initForm();

    $scope.showTab = function(state){
        $scope.initForm();
        $scope.state = state;
    };

    $scope.createRegion = function(){
        $scope.isRegionSubmitted = true;
        var region = { name: $scope.region.name, description: $scope.region.description };
        $http.post('/tenants/create_region', region).success(function(data) {
            $scope.isRegionSubmitted = false;
            if(data.errors){
                if(data.errors.name[0] == "can't be blank"){
                    $scope.regionDuplicate = false;
                    $scope.regionBlank = true;
                }else{
                    $scope.regionBlank = false;
                    $scope.regionDuplicate = true;
                }
                $scope.duplicateRegion = true;
            }else{
                $scope.duplicateRegion = false;
                $scope.updateRegion(data,'region');
                $modalInstance.close();
            }
        })
    };

    $scope.createType = function(){
        $scope.isTypeSubmitted = true;
        var type = {name: $scope.type.name, description: $scope.type.description };
        $http.post('/tenants/create_type', type).success(function(data) {
            $scope.isTypeSubmitted = false;
            if(data.errors){
                if(data.errors.name[0] == "can't be blank"){
                    $scope.typeDuplicate = false;
                    $scope.typeBlank = true;
                }else{
                    $scope.typeBlank = false;
                    $scope.typeDuplicate = true;
                }
                $scope.duplicateType = true;
            }else{
                $scope.updateRegion(data,'type');
                $scope.duplicateType = false;
                $modalInstance.close();
            }
        })
    };

    $scope.selectedChannelList = [];
    $scope.toggleCheck = function (channel_id) {
        if ($scope.selectedChannelList.indexOf(channel_id) === -1) {
            $scope.selectedChannelList.push(channel_id);
        } else {
            $scope.selectedChannelList.splice($scope.selectedChannelList.indexOf(channel_id), 1);
        }
    };

    $scope.selected_tenant_id = '';

    $scope.saveTenantPlan = function(){
        if($scope.selected_tenant_id == ''){
            $scope.tenant_blank = "Please select tenant";
            return true;
        }else{
            var tenant_plan = {
                tenant_id: $scope.selected_tenant_id,
                client_pricing_plan_id: $scope.client_plan.id,
                channels_id: $scope.selectedChannelList,
                email_count: $scope.tenant_plan.email_count || 0,
                sms_count: $scope.tenant_plan.sms_count || 0,
                customer_records_count: $scope.tenant_plan.customer_records_count || 0,
                campaigns_count: $scope.tenant_plan.campaigns_count || 0,
                fb_boost_budget: $scope.tenant_plan.fb_boost_budget || 0,
                total_reach: $scope.tenant_plan.total_reach || 0,
                pricing_plan_id: $scope.client_plan.pricing_plan_id,
                is_active: $scope.client_plan.is_active,
                start_date: $scope.client_plan.start_date,
                exp_date: $scope.client_plan.exp_date
            };
            $http.post('/tenants/save_tenant_plan', { tenant_plan: tenant_plan }).success(function(data) {
                if(data["error"]){
                    $scope.limit_error = data["error"];
                }else{
                    $scope.tenant_plan = {};
                    $scope.selected_tenant_id = '';
                    $scope.loadClientPlan();
                }
            })
        }
    };

    $scope.changeTenantPlan = function(tenant_id){
        $scope.selected_tenant_id = tenant_id;
        $http.get("/tenants/get_tenant_plan?id="+ tenant_id).success(function(data) {
            $scope.tenant_plan = data[0] || {};
            $scope.selectedChannelList = data[1];
            $scope.tenant_plan_channels = data[1];
        });
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});