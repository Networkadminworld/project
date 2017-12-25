InquirlyApp.controller('PipelineSalesController',['$http','$state','$stateParams','$scope','$rootScope','$cookieStore','$modal','$location',
    function($http,$state,$stateParams,$scope,$rootScope,$cookieStore,$modal,$location) {
        var go_service_url = pipelineURL;
        var campaign_id = $stateParams.campaign_id;
        var campaign_name = $stateParams.campaign_name;
      
         getFilterItems = function(item_state,cmp_id){
            $http.post(go_service_url+"/pipeline/campaignItemsById",{'item_id':cmp_id, 'item_state': item_state})
            .success(function(resp){
                if ( resp != null ){
                        console.log(resp);
                        //debugger;
                        if(item_state == "NEW") {
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


        initSalesData = function(){
    		$http.get("chat/identity").success(function (data, status) {
	            console.log("current user=" + data.id);
	            $scope.userId = data.id;
	            $scope.userEmail = data.email;
	            getCampaignNames();
	            getItems('SALES-PIPELINE','NEW', $scope.userId);
            	getItems('SALES-PIPELINE', 'CONFIRMED',$scope.userId);
            	getItems('SALES-PIPELINE','ASSIGNED',$scope.userId);
            	getItems('SALES-PIPELINE', 'DELIVERED',$scope.userId);
            });
        };

        $scope.viewItemDetails = function(item) {
            var modalInstance = $modal.open({
                animation: $scope.animationsEnabled,
                templateUrl: '/ng-app/templates/pipeline/order_details.html',
                controller: 'PipelineViewItemController',
                resolve:{
                    item:function(){
                        return item;
                    },
                     userRole:function() {
                        return "Sales";
                    },
                    userId:function() {
                        return $scope.userId;
                    },
                    goServiceUrl:function(){
                        return go_service_url;
                    }
                }
            });
        };

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
        $scope.changeStatus = function(itemId, status) {
            console.log("change status clicked=" + itemId +" " + status );
            $http.post(go_service_url+"/pipeline/changeStatus",{'item_id': itemId, 'status': status})
                .success(function(resp){
                    console.log(JSON.stringify(resp));
                    if(resp.status == 200) {
                        if(status == "CONFIRMED" || status == "REJECT") {
                            funnel_items = $scope.newFunnelItems;
                            //remove the current items from list
                            new_items = funnel_items.filter(function (i) {
                                return i.item_funnel_id != itemId;
                            });

                            $scope.newFunnelItems = new_items;
                            checkScopeBeforeApply();
                            //refresh the confirmed list
                            getItems("SALES-PIPELINE","CONFIRMED",$scope.userId);

                        }else if (status == "ASSIGNED") {
                            funnel_items = $scope.confirmedFunnelItems;
                            new_items = funnel_items.filter(function (i) {
                                return i.item_funnel_id != itemId;
                            });
                            $scope.assignedFunnelItems = new_items;
                            checkScopeBeforeApply();
                            getItems("SALES-PIPELINE","ASSIGNED",$scope.userId);
                        }else if (status == "DELIVERED") {
                            funnel_items = $scope.assignedFunnelItems;
                            new_items = funnel_items.filter(function (i) {
                                return i.item_funnel_id != itemId;
                            });
                            $scope.assignedFunnelItems = new_items;
                            checkScopeBeforeApply();
                            getItems("SALES-PIPELINE","DELIVERED",$scope.userId);
                        }
                    }
                })
                .error(function(err){

                }) ;
        };

	    $scope.assignDeliveryBoy = function(item) {
	        var modalInstance = $modal.open({
	            animation: true,
	            templateUrl: '/ng-app/templates/pipeline/assign_delivery_boy.html',
	            controller: 'DeliveryBoyController',
	            scope: $scope,
	            resolve: {
	                item: function () {
	                    return item;
	                }
	            }
	        });

	        modalInstance.result.then(function(item){
	            funnel_items = $scope.confirmedFunnelItems;
	            console.log("Assigned successfully");
	            //remove the current items from list
	            new_items = funnel_items.filter(function (i) {
	                return i.item_funnel_id != item.item_funnel_id;
	            });
	            $scope.confirmedFunnelItems = new_items;
	            checkScopeBeforeApply();
	            getItems("SALES-PIPELINE","ASSIGNED",$scope.userId);
	        });
	    };


	    getItems = function(pipeline_type,item_state,user_id){
	    	console.log("getitems with state-"+item_state);
            $http.post(go_service_url+"/pipeline/items",{'user_id': user_id,'pipeline_type':
                pipeline_type, 'item_state': item_state})
            .success(function(resp){
                if ( resp != null ){
                        //console.log(resp);
                        //debugger;
                        if(item_state == "NEW") {
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

        handleIncomingMessage = function(evt) {
            console.log("new websocket message="+ evt.data);
            newItem = JSON.parse(evt.data);
             if (newItem.funnel_type == "SALES-PIPELINE") {
	            if (newItem.item_state == "DELIVERED") {

	                existingDeliveredItems = $scope.deliveredFunnelItems;
	                 if (existingDeliveredItems == null) {
	                    existingDeliveredItems = [];
	                 }
	                existingDeliveredItems.unshift(newItem); //place on top
	                //remove the item from assignedItems
	                assigned_items = $scope.assignedFunnelItems;
	                new_assigned_items = assigned_items.filter(function (i) {
	                    return i.item_funnel_id != newItem.item_funnel_id;
	                });

	                $scope.$apply(function(){
	                    $scope.assignedFunnelItems = new_assigned_items;
	                    $scope.deliveredFunnelItems = existingDeliveredItems;
	                });
	            }else {
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

        getFilterItems = function(item_state,cmp_id){
            $http.post(go_service_url+"/pipeline/campaignItemsById",{'item_id':cmp_id, 'item_state': item_state})
            .success(function(resp){
                if ( resp != null ){
                        console.log(resp);
                        //debugger;
                        if(item_state == "NEW") {
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


        if(campaign_id != null) {
        	//user clicked on filter
        	$scope.newFunnelItems = [];
        	$scope.confirmedFunnelItems = [];
        	$scope.assignedFunnelItems = [];
        	$scope.deliveredFunnelItems = [];
        	getFilterItems("NEW",campaign_id);
        	getFilterItems("CONFIRMED",campaign_id);
        	getFilterItems("ASSIGNED",campaign_id);
        	getFilterItems("DELIVERED",campaign_id);
        }else {
        	initSalesData();
        }


        
    }
  ]
)