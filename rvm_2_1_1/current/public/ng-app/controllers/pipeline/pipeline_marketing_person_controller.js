InquirlyApp.controller('PipelineMarketingPersonController',['$http','$state','$stateParams','$scope','$rootScope','$cookieStore','$modal','$location',
    function($http,$state,$stateParams,$scope,$rootScope,$cookieStore,$modal,$location) {
    	var go_service_url = pipelineURL;
    	var campaign_id = $stateParams.campaign_id;
        var campaign_name = $stateParams.campaign_name;
        var source_type = $stateParams.source_type;
        var status_type = $stateParams.status;


    	initPipelinePerson = function() {
            $http.get("chat/identity").success(function (data, status) {
                console.log("current user=" + data.id);
                $scope.userId = data.id;
                $scope.userEmail = data.email;
                initWebSock();
                if(campaign_id != null && status_type == null) {
                    getCampaignFilterItem();
                }else if(status_type != null && status_type != "All") {
                    //in case, there is a status filter
                     $scope.newFunnelItems = [];
                     $scope.statusFunnelItems = [];
                     $scope.assignedFunnelItems = [];
                     $scope.closedFunnelItems = [];
                     getItems(status_type, $scope.userId, campaign_id);

                }else if($scope.status_type == null || $scope.status_type == "All")  {
                    initMarketingPersonItems();
                }

            });
        };

    	initMarketingPersonItems = function() {
            $scope.confirmedFunnelItems = [];
            $scope.assignedFunnelItems = [];
            $scope.newFunnelItems = [];
            $scope.deliveredFunnelItems = [];
            if(source_type == "Leads") {
                //only make this call when the selected source type is Lead
                //since campaign new items would generally go to the marketing manager 
                getItems('NEW', $scope.userId);
            }
            getItems('ASSIGNED', $scope.userId );
            getItems('CUSTOMER_CONTACTED', $scope.userId );
            getItems('IN_NEGOTIATION', $scope.userId );
            getItems('CLOSED',  $scope.userId);
        };

        getItems = function(item_state,user_id){
            var url = null;
            var params = null;
             if(source_type == "Leads") {
                url =  go_service_url+"/pipeline/marketingPersonLeadItems";
                params = {'user_id': user_id, 'item_state': item_state};
            }else {
                 url = go_service_url+"/pipeline/marketingPersonItems";
                 params = {'user_id': user_id, 'item_state': item_state, 'campaign_id': campaign_id};
            }
            $http.post(url,params)
            .success(function(resp){
                if ( resp != null ){
                        if(item_state == "ASSIGNED" ) {  
                         $scope.newFunnelItems = resp;
                                                        //$scope.newFunnelItems = resp;
                        }else if (item_state == "CUSTOMER_CONTACTED") {
                            $scope.confirmedFunnelItems = resp;
                        }else if(item_state == "IN_NEGOTIATION") {
                            $scope.assignedFunnelItems = resp;
                        }else if (item_state == "CLOSED" || item_state == "WON" || item_state == "LOST") {
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

        handleIncomingMessage = function(evt) {
            console.log("new websocket message="+ evt.data);
            newItem = JSON.parse(evt.data);
          	if (newItem.item_state == "ASSIGNED") {
          		 existingItems = $scope.newFunnelItems;
			     if (existingItems == null) {
			        existingItems = [];
			     }
			    existingItems.unshift(newItem); //place on top
			    $scope.$apply(function(){
			        $scope.newFunnelItems = existingItems;
			    });
          	}
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

        $scope.takeAction = function(item) {
            var modalInstance = $modal.open({
                animation: $scope.animationsEnabled,
                templateUrl: '/ng-app/templates/pipeline/action_details.html',
                controller: 'PipelineMarketingActionController',
                resolve:{
                    item:function(){
                        return item;
                    },
                    goServiceUrl:function(){
                        return go_service_url;
                    },
                    userId:function(){
                        return $scope.userId;
                    },
                    funnelId:function(){
                        return item.item_funnel_id;
                    }
                }
            });
        };

       $scope.onResult = function(item,status) {
        item.item_result = status;
        existingNewItems = $scope.deliveredFunnelItems;
        filteredItems = existingNewItems.filter(function(i){
                return i.item_funnel_id != item.item_funnel_id;
        });
        filteredItems.unshift(item);
        $scope.deliveredFunnelItems = filteredItems;
        checkScopeBeforeApply();
        $http.post(go_service_url+"/pipeline/updateMarketingStatus", {'funnel_id':item.item_funnel_id, 'result':status})
        .success(function(resp){
                            if(resp.status == 200) {
                                console.log("status updated successfully!");
                            }else {
                                console.log("error="+JSON.stringify(err));
                            }
        }).error(function(err){
            console.log("error="+JSON.stringify(err));
        });
    };

    changeMIStatus = function(item_id, status) {
        console.log("change status clicked=" + item_id +" " + status );
        $http.post(go_service_url+"/pipeline/changeMarketingState",{'item_id': item_id, 'status': status,'user_id':$scope.userId})
            .success(function(resp){
                if(resp.status == 200) {
                    console.log("status updated successfully!");
                }
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
                        return "Executive";
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
                }
              });   
                
    };

     /*drag and drop events */
    $scope.onDropNew = function(item,evt) {
        //if it is not a drag and drop on the same column
        if (item.item_state != 'ASSIGNED') {
            removeExistingFunnelItemsBasedOnState(item)
            var oldItems = $scope.newFunnelItems;
            item.item_state = 'ASSIGNED';
            item.item_result = '';
            oldItems.unshift(item);
            $scope.newFunnelItems = oldItems;
            checkScopeBeforeApply();
            changeMIStatus(item.item_funnel_id, 'ASSIGNED');
        }
    };

    $scope.onDropCustomerContacted = function(item,evt){
        //if it is not a drag and drop on the same column
        if (item != null && item.item_state != 'CUSTOMER_CONTACTED') {
            removeExistingFunnelItemsBasedOnState(item)
            var oldItems = $scope.confirmedFunnelItems;
            item.item_state = 'CUSTOMER_CONTACTED';
            item.item_result = '';
            oldItems.unshift(item);
            $scope.confirmedFunnelItems = oldItems;
            checkScopeBeforeApply();
            changeMIStatus(item.item_funnel_id, 'CUSTOMER_CONTACTED');
        }
    };

    $scope.onDropNegotiation = function(item,evt) {
        if (item != null  && item.item_state != 'IN_NEGOTIATION') {
            removeExistingFunnelItemsBasedOnState(item);
            var oldItems = $scope.assignedFunnelItems;
            item.item_state = 'IN_NEGOTIATION';
            item.item_result = '';
            oldItems.unshift(item);
            $scope.assignedFunnelItems = oldItems;
            checkScopeBeforeApply();
            changeMIStatus(item.item_funnel_id, 'IN_NEGOTIATION');
        }
    };

    $scope.onDropClosed = function(item,evt) {
        if (item != null && item.item_state != 'CLOSED') {
            removeExistingFunnelItemsBasedOnState(item);
            var oldItems = $scope.deliveredFunnelItems;
            item.item_state = 'CLOSED';
            oldItems.unshift(item);
            $scope.deliveredFunnelItems = oldItems;
            checkScopeBeforeApply();
            changeMIStatus(item.item_funnel_id, 'CLOSED');
        }
    };

    removeExistingFunnelItemsBasedOnState = function(entry) {
      //remove items from appropriate funnels based on state
        funnel = [];
        if (entry.item_state == 'ASSIGNED') {
           //if item_state = 'NEW' remove it from new funnel items
            existingNewItems = $scope.newFunnelItems;
            filteredItems = existingNewItems.filter(function(i){
                return i.item_funnel_id != entry.item_funnel_id;
            });
            $scope.newFunnelItems = filteredItems;

        }else if (entry.item_state == 'CUSTOMER_CONTACTED') {
            existingNewItems = $scope.confirmedFunnelItems;
            filteredItems = existingNewItems.filter(function(i){
                return i.item_funnel_id != entry.item_funnel_id;
            });
            $scope.confirmedFunnelItems = filteredItems;
        }else if(entry.item_state == 'IN_NEGOTIATION') {
            existingNewItems = $scope.assignedFunnelItems;
            filteredItems = existingNewItems.filter(function(i){
                return i.item_funnel_id != entry.item_funnel_id;
            });
            $scope.assignedFunnelItems = filteredItems;

        }else if(entry.item_state == 'CLOSED') {
            existingNewItems = $scope.deliveredFunnelItems;
            filteredItems = existingNewItems.filter(function(i){
                return i.item_funnel_id != entry.item_funnel_id;
            });
            $scope.deliveredFunnelItems = filteredItems;
        }
        checkScopeBeforeApply();
    };

    checkScopeBeforeApply = function() {
        if(!$scope.$$phase) {
            $scope.$apply();
        }
    };



	getFilterItems = function(item_state,cmp_id,filter_user){
	    $http.post(go_service_url+"/pipeline/campaignItemsById",{'item_id':cmp_id, 'item_state': item_state,'filter_user': filter_user})
	    .success(function(resp){
	        if ( resp != null ){
	                console.log(resp);
	                //debugger;
	                if(item_state == "ASSIGNED") {
	                    $scope.newFunnelItems = resp;
	                }else if (item_state == "IN_NEGOTIATION") {
	                    $scope.confirmedFunnelItems = resp;
	                }else if(item_state == "CUSTOMER_CONTACTED") {
	                    $scope.assignedFunnelItems = resp;
	                }else if (item_state == "CLOSED") {
	                    $scope.deliveredFunnelItems = resp;
	                }
	         }
	    }).error(function(err){
	        console.log("error="+ JSON.stringify(err))
	    });
	};

     getCampaignFilterItem = function(){
            //user clicked on filter
            $scope.newFunnelItems = [];
            $scope.statusFunnelItems = [];
            $scope.assignedFunnelItems = [];
            $scope.closedFunnelItems = [];
            getFilterItems("NEW",campaign_id,$scope.userId);
            getFilterItems("ASSIGNED",campaign_id,$scope.userId);
            getFilterItems("IN_NEGOTIATION",campaign_id,$scope.userId);
            getFilterItems("CUSTOMER_CONTACTED",campaign_id,$scope.userId);
            getFilterItems("CLOSED",campaign_id,$scope.userId);
        }; 

	/*if(campaign_id != null) {
        	//user clicked on filter
        	$scope.newFunnelItems = [];
        	$scope.confirmedFunnelItems = [];
        	$scope.assignedFunnelItems = [];
        	$scope.deliveredFunnelItems = [];
        	getFilterItems("ASSIGNED",campaign_id);
        	getFilterItems("IN_NEGOTIATION",campaign_id);
        	getFilterItems("CUSTOMER_CONTACTED",campaign_id);
        	getFilterItems("CLOSED",campaign_id);
    }else {
        	initPipelinePerson();
     }*/

     initPipelinePerson();
    }
  ]
 );