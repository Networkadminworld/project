/**
 * Created by Bindesh Vijayan on 10/19/2015.
 */

InquirlyApp.controller('PipelineViewItemController',function($scope,$http, $modalInstance, item, userRole,userId, goServiceUrl) {
    $scope.item = item;
    $scope.userRole = userRole;
    $scope.userId = userId;
    $scope.goServiceUrl = goServiceUrl;
    //debugger;
    $scope.funnel_type = "MARKETING-PIPELINE";
    $scope.isReassignable = false;
    $scope.isDeletable = false;

    init = function() {

        if( (item.item_source == 'Campaigns' || item.item_source == 'Leads')  && (item.item_state != 'NEW' && userRole == 'Manager' && item.funnel_type == 'MARKETING-PIPELINE')) {
            $scope.isReassignable = true;
        }

        if( item.item_source == 'Leads' && item.item_owner_id == $scope.userId) {
            if($scope.userRole == 'Executive' && item.item_state == 'ASSIGNED') {
                $scope.isDeletable = true;
            }else if($scope.userRole == 'Manager' && item.item_state == 'NEW') {
                $scope.isDeletable = true;
            }
            
        }
        
        $scope.funnel_type = item.funnel_type;
        var keys = [];
        var values = [];
        if (item.item_specifications != null && item.item_specifications != "{}") {
            var specs =  JSON.parse(item.item_specifications);
            $.map(specs, function(val, key){
                keys.push(key);
                if(item.item_source == "Leads") {
                    values.push(val);
                }else {

                 values.push(val[0]);
                }
            });

            $scope.keys = keys;
            $scope.values = values;
        } else {
            console.log("no item specifications for this item");
             $scope.keys = [];
            $scope.values = [];
        }
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };

    $scope.deleteLead = function() {
        $http.post(goServiceUrl + "/pipeline/deleteLead", {'item_id': $scope.item.item_funnel_id, 'user_id': $scope.userId}).
        success(function(resp){
            if(resp.status == 200) {
                $modalInstance.close('refresh');
            }else if(resp.status == 500) {
                console.log("something went wrong deleting item," + resp.message);
            }
        }).error(function(err){
            console.log("error deleting item,",err);    
        })
    }

    $scope.reassignLead = function() {
        $modalInstance.close("reassign");
    }

    init();
});