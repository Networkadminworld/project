InquirlyApp.controller('PipelineMarketingManagerController',['$http','$state','$stateParams','$scope','$rootScope','$cookieStore','$modal','$location',
    function($http,$state,$stateParams,$scope,$rootScope,$cookieStore,$modal,$location) {
        var go_service_url = pipelineURL;
        var campaign_id = $stateParams.campaign_id;
        var campaign_name = $stateParams.campaign_name;
        var source_type = $stateParams.source_type;
        $scope.filter_user_id = $stateParams.filter_user;
        $scope.status_type = $stateParams.status;

        initMarketingManagerData = function() {
            $http.get("chat/identity").success(function (data, status) {
                console.log("current user=" + data.id);
                $scope.userId = data.id;
                $scope.userEmail = data.email;
                initWebSock();
                if(campaign_id != null) {
                    //this will take care of any filter conditions regarding to status too
                    getCampaignFilterItem();
                }else if($scope.status_type != null) {
                    var filterUser = -1;
                    if($scope.filter_user_id != null) {
                        filterUser = $scope.filter_user_id;
                    }
                    $scope.newFunnelItems = [];
                    $scope.statusFunnelItems = [];
                    $scope.assignedFunnelItems = [];
                    $scope.closedFunnelItems = [];
                    getItems($scope.status_type, filterUser);
                }
                else {
                    initItems();
                }

            });
        };
        checkScopeBeforeApply = function() {
            if(!$scope.$$phase) {
                $scope.$apply();
            }
        };

        /*$scope methods*/
        $scope.getChannelText = function(channel) {
            var channelText = "";
            if(channel == "sms") {
                channelText = "Sms";
            }else if(channel == "email") {
                channelText = "Email";
            }else if(channel == "facebook") {
                channelText = "Facebook";
            }else if(channel == "twitter") {
                channelText = "Twitter";
            }else if(channel == "linkedin") {
                channelText = "Linkedin";
            }else if(channel == "QrCode") {
                channelText = "QrCode";
            }else if(channel == "Beacon") {
                channelText = "Beacon";
            }else if(channel == "opinify") {
                channelText = "Opinify";
            }
            return channelText;
        };

        $scope.getChannelIcon = function(channel) {
            var channelIcon = "";
            if(channel == "sms") {
                channelIcon = "fa-comment-o";
            }else if(channel == "email") {
                channelIcon = "fa-envelope-o";
            }else if(channel == "facebook") {
                channelIcon = "fa-facebook";
            }else if(channel == "twitter") {
                channelIcon = "fa-twitter";
            }else if(channel == "linkedin") {
                channelIcon = "fa-linkedin";
            }else if(channel == "QrCode") {
                channelIcon = "fa-qrcode";
            }else if(channel == "Beacon") {
                channelIcon = "fa-thumb-tack";
            }else if(channel == "opinify") {
                channelIcon = "fa-envelope-oo";
            }
            return channelIcon;
        };
        $scope.getChannelCss = function(channel) {
            var channelIcon = "";
            if(channel == "sms") {
                channelIcon = "sms-chnl";
            }else if(channel == "email") {
                channelIcon = "email-chnl";
            }else if(channel == "facebook") {
                channelIcon = "fb-chnl";
            }else if(channel == "twitter") {
                channelIcon = "twt-chnl";
            }else if(channel == "linkedin") {
                channelIcon = "linkin-chnl";
            }else if(channel == "QrCode") {
                channelIcon = "qr-code-chnl";
            }else if(channel == "Beacon") {
                channelIcon = "beacon-chnl";
            }else if(channel == "opinify") {
                channelIcon = "opinify-chnl-mobile-2";
            }
            return channelIcon;
        };

        $scope.viewItemDetails = function(item) {
            //fix-Bug: SI-472
            var url = go_service_url + "/pipeline/getItemById"; 
            $http.post(url, {"item_id": item.item_funnel_id}).
            success(function(resp) {
                var refreshedItem = resp.item;

                var modalInstance = $modal.open({
                animation: $scope.animationsEnabled,
                templateUrl: '/ng-app/templates/pipeline/order_details.html',
                controller: 'PipelineViewItemController',
                resolve:{
                    item:function(){
                        return refreshedItem;
                    },
                    userRole:function() {
                        return "Manager";
                    },
                    userId:function() {
                        return $scope.userId;
                    },
                     goServiceUrl:function(){
                        return go_service_url;
                    }
                }
            });

              modalInstance.result.then(function(status) {
                if(status == "refresh") {
                    //
                    console.log("removing the deleted item from the new items list");
                    funnel_items = $scope.newFunnelItems;
                    //remove the current items from list
                    new_items = funnel_items.filter(function (i) {
                        return i.item_funnel_id != item.item_funnel_id;
                    });
                    $scope.newFunnelItems = new_items;
                    checkScopeBeforeApply()
                }else if(status == "reassign") {
                    $scope.openMarketingAssignDialog(item);
                }
              });  


                
            }).error(function(err){
                console.log("error in getting funnel item "+ err);
            })
            
        };
        
        $scope.openMarketingAssignDialog = function(item) {
            var modalInstance = $modal.open({
                animation: true,
                templateUrl: '/ng-app/templates/pipeline/assign_marketing_person.html',
                controller: 'PipelineAssignController',
                scope: $scope,
                resolve: {
                    item: function () {
                        return item;
                    }
                }
            });

            modalInstance.result.then(function(item){
                funnel_items = $scope.newFunnelItems;
                //remove the current items from list
                new_items = funnel_items.filter(function (i) {
                    return i.item_funnel_id != item.item_funnel_id;
                });
                $scope.newFunnelItems = new_items;
                checkScopeBeforeApply();
                getItems("ASSIGNED",-1);
            });
        };

        /* non-scope methods */
        

         getFilterItems = function(item_state,cmp_id){
            var filterUser = -1;
            if($scope.filter_user_id != null) {
                filterUser = $scope.filter_user_id;
            }
            $http.post(go_service_url+"/pipeline/campaignItemsById",{'item_id':cmp_id, 'item_state': item_state, 'filter_user':filterUser})
            .success(function(resp){
                if ( resp != null ){
                        console.log(resp);
                        //debugger;
                        if(item_state == "NEW") {
                            $scope.newFunnelItems = resp;
                        }else if (item_state == "ASSIGNED") {
                            $scope.assignedFunnelItems = resp;
                        }else if(item_state == "CUSTOMER_CONTACTED") {
                            if(resp != null) {
                                    if($scope.statusFunnelItems.length>0) {
                                        existingStatusFunnelItems = $scope.statusFunnelItems;
                                        angular.forEach(resp,function(item){
                                            existingStatusFunnelItems.unshift(item);
                                        });  
                                       // existingStatusFunnelItems.unshift(resp.data);
                                        $scope.statusFunnelItems = existingStatusFunnelItems;
                                        checkScopeBeforeApply();
                                    }else {
                                        $scope.statusFunnelItems = resp;
                                    }
                             }
                        }else if (item_state == "IN_NEGOTIATION") {
                            if(resp!= null) {
                                if($scope.statusFunnelItems.length>0) {
                                    existingStatusFunnelItems = $scope.statusFunnelItems;
                                    angular.forEach(resp,function(item){
                                        existingStatusFunnelItems.unshift(item);
                                    });  
                                   // existingStatusFunnelItems.unshift(resp.data);
                                    $scope.statusFunnelItems = existingStatusFunnelItems;
                                    checkScopeBeforeApply();
                                }else {
                                    $scope.statusFunnelItems = resp;
                                }
                            }
                        }else if(item_state == "CLOSED" || item_state == "WON" || item_state == "CLOSED") {
                            $scope.closedFunnelItems = resp;
                        }
                 }
            }).error(function(err){
                console.log("error="+ JSON.stringify(err))
            });
        };

        initWebSock = function(){
            var ws = new WebSocket(pipelineWsUrl+$scope.userId);
            ws.onerror = function(evt) {
                console.log("Error initializing websocket="+ JSON.stringify(evt));
            };

            ws.onopen = function(evt) {
                console.log("Websocket initialized!");
            };
            ws.onclose = function(evt) {
                console.log("websocket closed!");
            }
            ws.onmessage = function(evt) {
                handleIncomingMessage(evt);
            };
        };

        handleIncomingMessage = function(evt) {
            console.log("new websocket message="+ evt.data);
            newItem = JSON.parse(evt.data);
            if (newItem.funnel_type == "MARKETING-PIPELINE") {
                if (newItem.item_state == "CLOSED") {
                    existingDeliveredItems = $scope.closedFunnelItems;
                     if (existingDeliveredItems == null) {
                        existingDeliveredItems = [];
                     }
                    existingDeliveredItems.unshift(newItem); //place on top
                    //remove the item from assignedItems
                    status_items = $scope.statusFunnelItems;
                    new_assigned_items = status_items.filter(function (i) {
                        return i.item_funnel_id != newItem.item_funnel_id;
                    });

                    $scope.$apply(function(){
                        $scope.statusFunnelItems = new_assigned_items;
                        $scope.closedFunnelItems = existingDeliveredItems;
                    });
                }else if(newItem.item_state == "Customer Contacted" || newItem.item_state == "In Negotiation") {
                   existingStatusItems = $scope.statusFunnelItems;
                   //remove item from closed queue 
                   var existingDeliveredItems = $scope.closedFunnelItems.filter(function (i) {
                         return i.item_funnel_id != newItem.item_funnel_id;
                    });

                    if (existingStatusItems == null) {
                        existingStatusItems = [];
                     }
                     else {
                        //there are items in it 
                        //remove this item from the list
                        existingStatusItems =  $scope.statusFunnelItems.filter(function (i) {
                             return i.item_funnel_id != newItem.item_funnel_id;
                        });
                     }
                    existingStatusItems.unshift(newItem); //place on top
                    //remove the item from assigned queue 
                    assignedItems = $scope.assignedFunnelItems;
                    newAssignedItems = assignedItems.filter(function(i){
                        return i.item_funnel_id != newItem.item_funnel_id;
                    })

                    $scope.$apply(function(){
                        $scope.statusFunnelItems = existingStatusItems;
                        $scope.assignedFunnelItems = newAssignedItems;
                        $scope.closedFunnelItems = existingDeliveredItems;
                    }); 
                }
                else if(newItem.item_state == "NEW") {
                    existingItems = $scope.newFunnelItems;
                     if (existingItems == null) {
                        existingItems = [];
                     }
                    existingItems.unshift(newItem); //place on top
                    $scope.$apply(function(){
                        $scope.newFunnelItems = existingItems;
                    });
                }
            }
        };

        initItems = function() {
            $scope.statusFunnelItems = [];
            $scope.assignedFunnelItems = [];
            $scope.newFunnelItems = [];
            $scope.closedFunnelItems = [];
            var filterUser = -1;
            if($scope.filter_user_id != null) {
                filterUser = $scope.filter_user_id;
            }
            getItems("NEW",filterUser);
            getItems("ASSIGNED",filterUser);
            getItems("CUSTOMER_CONTACTED",filterUser);
            getItems("IN_NEGOTIATION",filterUser);
            getItems("CLOSED",filterUser);
         };

        getCampaignFilterItem = function(){
            //user clicked on filter
            $scope.newFunnelItems = [];
            $scope.statusFunnelItems = [];
            $scope.assignedFunnelItems = [];
            $scope.closedFunnelItems = [];
            if ($scope.status_type != null ) {
                getFilterItems($scope.status_type, campaign_id);
            }else {
                 getFilterItems("NEW",campaign_id);
                 getFilterItems("ASSIGNED",campaign_id);
                 getFilterItems("IN_NEGOTIATION",campaign_id);
                 getFilterItems("CUSTOMER_CONTACTED",campaign_id);
                 getFilterItems("CLOSED",campaign_id);
            }
           
        };  

        getItems = function(itemState,filterUser) {
            console.log("getItems with state-"+itemState);
            var url = null;
            if(source_type == "Leads") {
                url =  go_service_url+"/pipeline/getMarketingManagerNewLeads";
            }else {
                 url = go_service_url+"/pipeline/getMarketingManagerItems";
            }
            $http.post(url,{'user_id': $scope.userId,'item_state': itemState, 'filter_user':filterUser})
                .success(function(resp){
                    if(resp.item_state == "NEW") {
                        if(resp.data != null) {
                            $scope.newFunnelItems = resp.data;
                        }
                    }else if (resp.item_state == "ASSIGNED") {
                        if(resp.data != null) {
                            $scope.assignedFunnelItems = resp.data;
                            checkScopeBeforeApply();
                        }
                    }else if(resp.item_state == "CUSTOMER_CONTACTED") {
                        if(resp.data != null) {
                            if($scope.statusFunnelItems.length>0) {
                                existingStatusFunnelItems = $scope.statusFunnelItems;
                                angular.forEach(resp.data,function(item){
                                    existingStatusFunnelItems.unshift(item);
                                });  
                               // existingStatusFunnelItems.unshift(resp.data);
                                $scope.statusFunnelItems = existingStatusFunnelItems;
                                checkScopeBeforeApply();
                            }else {
                                $scope.statusFunnelItems = resp.data;
                            }
                        }
                    }else if (resp.item_state == "IN_NEGOTIATION") {
                       if(resp.data != null) {
                             if($scope.statusFunnelItems.length>0) {
                                existingStatusFunnelItems = $scope.statusFunnelItems;
                                angular.forEach(resp.data,function(item){
                                    existingStatusFunnelItems.unshift(item);
                                });               
                                $scope.statusFunnelItems = existingStatusFunnelItems;
                                checkScopeBeforeApply();
                            }else {
                                $scope.statusFunnelItems = resp.data;
                            }
                        }  
                    }else if (resp.item_state == "CLOSED" || resp.item_state == "WON" || resp.item_state == "LOST") {
                        if(resp.data != null){
                            $scope.closedFunnelItems = resp.data;
                        }
                    }
                })
                .error(function(err){
                    console.log("Error="+ err);
                });
        };

       initMarketingManagerData();
    }
]
);