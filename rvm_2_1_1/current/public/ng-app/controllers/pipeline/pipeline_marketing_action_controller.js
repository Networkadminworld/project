/**
 * Created by Bindesh Vijayan on 11/4/2015.
 */
InquirlyApp.controller('PipelineMarketingActionController', function($scope,$http, $modalInstance,item,goServiceUrl,userId,funnelId){

    $scope.item = item;
    $scope.goServiceUrl = goServiceUrl;
    $scope.userId = userId;
    $scope.funnelId = funnelId;
    $scope.popup = {
        isOpened: false
     };


    init = function() {
          //  $scope.popup.isOpened = false;
          
            $scope.dt = new Date();
            $scope.time = new Date();
            $scope.note = null;
            $scope.actionName = null;
            $scope.formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'dd.MM.yyyy', 'shortDate'];
            $scope.format = $scope.formats[0];
            $scope.minDate = new Date();
            $scope.maxDate = new Date(2020, 5, 22);
            $scope.dateOptions = {
                formatYear: 'yy',
                startingDay: 1
            };
            getMarketingStatus(); 
    }

    getMarketingStatus = function(){
        $http.post($scope.goServiceUrl+"/pipeline/getMarketingStatus",{'funnel_id':$scope.item.item_funnel_id})
        .success(function(resp){
            console.log("marketing status resp="+JSON.stringify(resp));
           if(resp.status == 200) {
                $scope.actionName = resp.marketing_action.action_name;
                $scope.note = resp.marketing_action.note;
                $scope.dt = moment(resp.marketing_action.appointment_at).format("YYYY-MM-DD");
                $scope.minDate = new Date();
                /*var time = new Date();
                time.setTime();*/
                $scope.time = Date.parse(resp.marketing_action.appointment_at);
                //moment(resp.marketing_action.appointment_at).format("HH:mm");
           }
        });
    }

    checkScopeBeforeApply = function() {
            if(!$scope.$$phase) {
                $scope.$apply();
            }
    };


    $scope.onActionSelect = function(actionName) {
        $scope.actionName = actionName;
    }

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };

    $scope.datepickerOptions = {
        format: 'yyyy-mm-dd',
        language: 'en',
        autoclose: true,
        weekStart: 0
    };

    $scope.open = function() {
         $scope.popup.isOpened = true;
         checkScopeBeforeApply();
    };

    $scope.save = function() {
        /*ActionName    string `json:"action_name"`
        Note          string `json:"note"`
        AppointmentAt string `json:"appointment_at"`
        UserId        int    `json:"user_id"`
        FunnelId      int    `json:"funnel_id"`
        */
        //expected server date format "Wed, 09 Mar 2016 09:08:24 GMT"
        appointmentAt = moment($scope.dt).format("ddd, DD MMM YYYY") + ' ' + moment.utc($scope.time).format("HH:mm:SS") + " GMT";//moment($scope.dt).format("DD/MMM/YYYY")+":"+moment($scope.time).format("HH:mm");
        $http.post($scope.goServiceUrl+"/pipeline/updateMarketingStatus",{"action_name":$scope.actionName,
        "note":$scope.note,"appointment_at":appointmentAt,"user_id":$scope.userId,"funnel_id":$scope.funnelId})
        .success(function(resp){
            console.log("Save resp="+JSON.stringify(resp));
             $modalInstance.dismiss('cancel');
        })
        .error(function(err){

        });
    };

    init();

});