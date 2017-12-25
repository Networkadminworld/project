InquirlyApp.controller('PipelineController',['$http','$state','$scope','$rootScope','$cookieStore','$modal','$timeout','$location',
    function($http,$state,$scope,$rootScope,$cookieStore,$modal, $timeout,$location) {
        console.log("pipeline controller");
        var go_service_url = pipelineURL;
        $scope.userSearch ='';
        $scope.selectedUser = "FILTER";
        $scope.selected_source_type = "Campaigns";
        $scope.statusNames = [{ "label":"New Leads", "status": "NEW", "checked": false },
                              { "label":"Assigned Leads", "status": "ASSIGNED", "checked": false },
                              { "label":"Customer Contacted", "status": "CUSTOMER_CONTACTED", "checked": false },
                              { "label":"In Negotiation", "status": "IN_NEGOTIATION", "checked": false },
                              { "label":"Closed", "status": "CLOSED", "checked": false },
                              { "label":"All won deals", "status": "WON", "checked": false },
                              { "label":"All lost deals", "status": "LOST", "checked": false }
                            ];


        getAllMarketingUsers = function() { 
                $http.post(go_service_url+"/pipeline/getMarketingExecs", {"user_id": $scope.userId}).
                success(function(resp) {
                    if(resp.status == 200) {
                        $scope.marketingUsers = resp.data;
                    }else if (resp.status == 500) {
                        console.log("error in getting marketing users="+resp.message);
                    }
                }).error(function(err) {
                    console.log("error getting marketing users="+err);
                });
        };

        $scope.onFilterUserSelection = function(user) {
            resetSelection();
            user.checked = true;
            $scope.userSearch = '';
            if (user == "Everyone") {
                $scope.selectedUser = "FILTER";
                $state.transitionTo("pipeline.markmanager", {campaign_id: $scope.selected_campaign_id , campaign_name: $scope.selected_campaign_name,source_type: $scope.selected_source_type});
            }else {
                $scope.selectedUser = user.name;
                $scope.filter_user_id = user.id;
                $state.transitionTo("pipeline.markmanager", {campaign_id: $scope.selected_campaign_id , campaign_name: $scope.selected_campaign_name,source_type:$scope.selected_source_type, filter_user: $scope.filter_user_id});

            }  
        };

        $scope.onActionSelection = function(actionFilterObj) { 
            $scope.userSearch = ''; 
           // $scope.$apply();
            resetSelection();
            actionFilterObj.checked = true;
            $scope.selectedUser = actionFilterObj.label;
            if($scope.userRole == "Manager") {
              $state.transitionTo("pipeline.markmanager", {campaign_id: $scope.selected_campaign_id , campaign_name: $scope.selected_campaign_name,source_type: $scope.selected_source_type,status: actionFilterObj.status});
            }else { 
              $state.transitionTo("pipeline.marketing", {campaign_id: $scope.selected_campaign_id , campaign_name: $scope.selected_campaign_name,source_type: $scope.selected_source_type,status: actionFilterObj.status});

            }

        }


        init = function(){
            console.log("pipeline controller init");
             $http.get("chat/identity").success(function (data, status) {
                    console.log("current user=" + data.id);
                    $scope.userId = data.id;
                    $scope.userEmail = data.email;
                    getAllMarketingUsers();
                    $scope.selected_campaign_name = null;
                   /* $scope.pipelineTypes = ["Sales", "Marketing"];
                    $scope.selected_campaign_type = "Sales";*/
                    $scope.isMarketing = false;
                    $scope.isAdmin = false;
                    permissions = sessionStorage.getItem("permissions");
                    permissions = JSON.parse(permissions);
                    if ( (permissions['pipeline_marketing'] == true || permissions['pipeline_marketing_manager'] == true) && 
                        (permissions['pipeline_sales'] == true) ) {
                        //user can view both views 
                         $scope.pipelineTypes = ["Marketing","Sales"];
                         getCampaignNames("all");

                    }else if( permissions['pipeline_sales'] == true && ((permissions['pipeline_marketing'] == false || permissions['pipeline_marketing_manager'] == false) )) {
                        $scope.pipelineTypes = ["Sales"];
                        getCampaignNames("sales");

                    }else if( permissions['pipeline_sales'] == false && ((permissions['pipeline_marketing'] == true || permissions['pipeline_marketing_manager'] == true) )) {
                        $scope.pipelineTypes = ["Marketing"];
                        $scope.selected_campaign_type = "Marketing";
                        getCampaignNames("marketing");

                    }else if (permissions['pipeline_delivery'] == true ) {
                        $scope.pipelineTypes = ["Sales"];
                        $scope.selected_campaign_type = "Sales";
                    }else if(permissions['jb_pipeline'] == true){
                        $state.go('justbake');
                        $location.path('/justbake/pipeline');
                    }
                   // initWebSock();
                   initPipelineItems();

                });
        };

        initPipelineItems = function() {
            console.log("init pipeline items function of pipelinecontroller called");
            $scope.confirmedFunnelItems = [];
            $scope.assignedFunnelItems = [];
            $scope.newFunnelItems = [];
            $scope.deliveredFunnelItems = [];
            //conditional branching
            permissions = sessionStorage.getItem("permissions");
            permissions = JSON.parse(permissions);
            if (permissions["pipeline_marketing_manager"] == true ){
                    //on init transition to sales pipeline
                    $scope.isAdmin = true;
                    $scope.selected_campaign_type = "Marketing";
                    $scope.isMarketing = true;
                    $scope.sourceType = ["Leads","Campaigns"]; 
                    getCampaignNames("marketing");
                    $scope.userRole = "Manager";
                    $state.go("pipeline.markmanager");
            }else if(permissions["pipeline_marketing"] == true ){
                    $scope.pipelineTypes = ["Marketing"];
                    $scope.isMarketing = true;
                    $scope.selected_campaign_type = "Marketing";
                    $scope.sourceType = ["Leads","Campaigns"];
                     $scope.userRole = "Executive"; 
                    getCampaignNames("marketing");    
                    cleanUpStatusForMarketing();
                    $state.transitionTo("pipeline.marketing");
            }else if(permissions["pipeline_sales"] == true) {
                    $scope.selected_campaign_type = "Sales";
                    $state.go("pipeline.sales")
            }else if(permissions["pipeline_delivery"] == true ) {
                    $scope.isMarketing = false;
                    $scope.pipelineTypes = ["Sales"];
                    getCampaignNames("marketing");
                    $state.go('pipeline.dboy');
            }

           
            //$state.transitionTo("pipeline.sales");
        };

         $scope.onExportClick = function() {
                var modalInstance = $modal.open({
                animation: true,
                templateUrl: '/ng-app/templates/pipeline/pipeline_export.html',
                controller: 'PipelineExportController',
                scope: $scope,
                resolve: {
                    goServiceUrl: function(){
                        return go_service_url;
                    },
                    userId: function(){
                        return $scope.userId;
                    },
                    userRole: function() {
                        return $scope.userRole;
                    }
                }
            });
        };


         
        
        $scope.onNewDeals = function() {
                var modalInstance = $modal.open({
                animation: true,
                templateUrl: '/ng-app/templates/pipeline/new_deals.html',
                controller: 'PipelineNewDealsController',
                scope: $scope,
                resolve: {
                    goServiceUrl: function(){
                        return go_service_url;
                    },
                    userId: function(){
                        return $scope.userId;
                    },
                    userRole: function() {
                        return $scope.userRole;
                    }
                }
            });
        };

    

        $scope.onCampaignTypeSelect = function(campaign_type) {
          $scope.selected_campaign_type = campaign_type;
           $scope.newFunnelItems = [];
           $scope.confirmedFunnelItems = [];
           $scope.assignedFunnelItems = [];
           $scope.deliveredFunnelItems = [];
          if (campaign_type == 'Sales') {
            $scope.isMarketing = false;
            getCampaignNames("sales");
            $state.transitionTo('pipeline.sales');
          }else if (campaign_type == "Marketing") {
            $scope.isMarketing = true;
            getCampaignNames("marketing");
            permissions = sessionStorage.getItem("permissions");
            permissions = JSON.parse(permissions);
            if(permissions["pipeline_marketing_manager"] == true) {
                $state.transitionTo('pipeline.markmanager');
            }else if(permissions["pipeline_marketing"] == true) {
                $state.transitionTo('pipeline.marketing')
            }

          }
        };


        $scope.onSourceTypeSelect = function(source_type) {  
           $scope.selected_source_type = source_type;
           $scope.newFunnelItems = [];
           $scope.confirmedFunnelItems = [];
           $scope.assignedFunnelItems = [];
           $scope.deliveredFunnelItems = [];
           checkScopeBeforeApply();
           permissions = sessionStorage.getItem("permissions");
           permissions = JSON.parse(permissions);
           if(permissions["pipeline_marketing_manager"] == true) {
                 $scope.selectedUser = "FILTER";
                 resetSelection();
                $state.transitionTo("pipeline.markmanager", {campaign_id: null, campaign_name: null, source_type: source_type});
            }else if(permissions["pipeline_marketing"] == true) {
                resetSelection();
                 $scope.selectedUser = "FILTER";
                $state.transitionTo("pipeline.marketing", {campaign_id: null, campaign_name: null, source_type: source_type});
           }           
        }

        $scope.onViewCampaign = function(){
            if ($scope.selected_campaign_id != null) {
                $state.transitionTo('campaigns.campaign-builder',{'campaign_id':$scope.selected_campaign_id});
            } else {
                console.log("no campaigns selected!");
            }
        };

        $scope.onViewPipeline = function(){
             $timeout(function() {
                        console.log("view pipeline hit="+$state.current.name);
                        $scope.selected_campaign_name = "All Campaigns";
                        $scope.selected_campaign_id = null;
                        $scope.selectedUser = "FILTER";
                        $scope.userSearch = '';
                        resetSelection();
                        $state.transitionTo($state.current.name);
                        },
                        0);
        };

        $scope.onCampaignSelect = function(campaign_id,campaign_name) {
            $scope.selected_campaign_name = campaign_name;
            $scope.selected_campaign_id = campaign_id;
            if($scope.selected_campaign_type == "Sales") {
                $state.transitionTo("pipeline.sales", {campaign_id: campaign_id, campaign_name: campaign_name});
            }else if($scope.selected_campaign_type == "Marketing") {
                 permissions = sessionStorage.getItem("permissions");
                 permissions = JSON.parse(permissions);
                 if(permissions["pipeline_marketing_manager"] == true ){
                    $state.transitionTo("pipeline.markmanager", {campaign_id: campaign_id, campaign_name: campaign_name,source_type: "Campaigns",filter_user: $scope.filter_user_id});
                 }else if(permissions["pipeline_marketing"] == true) {
                     $state.transitionTo("pipeline.marketing", {campaign_id: campaign_id, campaign_name: campaign_name, source_type:"Campaigns"});
                 }
            }
        
        };

         getCampaignNames = function(campaign_type) {
            console.log("getting campaign names for type="+ campaign_type);
            $http.post(go_service_url+"/pipeline/campaignNames",{'user_id':$scope.userId,'type': campaign_type})
            .success(function(resp){
                if(resp.data != null) {
                    $scope.campaign_names = resp.data;
                    $scope.campaign_names.unshift("All Campaigns");
                    $scope.selected_campaign_name =  $scope.campaign_names[0];
                }

            }).error(function(err){
                console.log("error loading campaign names");
            });
        };


         getItems = function(pipeline_type,item_state,user_id){
            $http.post(go_service_url+"/pipeline/items",{'user_id': user_id,'pipeline_type':
                pipeline_type, 'item_state': item_state})
            .success(function(resp){
                if ( resp != null ){
                        //console.log(resp);
                        //debugger;
                        if(item_state == "ASSIGNED") {
                            $scope.newFunnelItems = resp;
                        }else if (item_state == "CONFIRMED") {
                            $scope.confirmedFunnelItems = resp;
                        }else if(item_state == "ASSIGNED") {
                            $scope.assignedFunnelItems = resp;
                        }else if (item_state == "DELIVERED") {
                            $scope.deliveredFunnelItems = resp;
                        }
                 }
            }).error(function(err){
                console.log("error="+ JSON.stringify(err))
            });
        };

        checkScopeBeforeApply = function() {
            if(!$scope.$$phase) {
                $scope.$apply();
            }
        };

        resetSelection = function() {
            for(var i=0; i<$scope.marketingUsers.length; i++) {
               $scope.marketingUsers[i].checked = false;
            }
            for(var i=0; i<$scope.statusNames.length; i++) {
                $scope.statusNames[i].checked = false;
            }
        }

        cleanUpStatusForMarketing = function() {
            var statusList = $scope.statusNames;
            var allLead = {"label": "All Leads", "status":"All", "checked":false};
            statusList.unshift(allLead);
            $scope.statusNames = statusList.filter(function(item){
               return item.status != "NEW";
            });
        };

        init();
    }
]);
