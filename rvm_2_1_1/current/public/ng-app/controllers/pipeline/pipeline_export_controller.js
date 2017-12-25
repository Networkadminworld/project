InquirlyApp.controller('PipelineExportController', function($scope,$http,$q, $modalInstance,goServiceUrl,userId,userRole){
    var goServiceUrl = goServiceUrl;
    var userId = userId;
    var userRole = userRole;
    $scope.popup = {
        isOpenedSD: false,
        isOpenedED: false
     };

    $scope.sourceType = ["All", "Campaign Leads", "Manual Leads"]; 
    $scope.selectedSourceType = "All"
    $scope.csvHeaders = ["Lead Title","Customer Name", "Customer Address","Customer Mobile","Customer Email","Organization Name", "Deal Value","Currency","Status","Deal Result","Owned By","Assigned To", "Note", "Created At", "Lead Source"];


      checkScopeBeforeApply = function() {
            if(!$scope.$$phase) {
                $scope.$apply();
            }
    };

   	$scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };


    $scope.onTypeSelect = function(type) {
    	$scope.selectedSourceType = type;
    }

    $scope.getExportData = function(){
    	//ngCsv expects a promis or array
    	var startDate = null;
    	var endDate = null;
    	$scope.fileName = $scope.fileName + "_" + $scope.selectedSourceType;
    	if($scope.dtSD != null && $scope.dtED != null) {
    		startDate = moment($scope.dtSD).format("YYYY-MM-DD");
    		endDate = moment($scope.dtED).format("YYYY-MM-DD");
    		$scope.fileName = $scope.fileName + "_" +startDate + "_" + endDate + ".csv";
    	}else {
    		$scope.fileName = $scope.fileName +".csv";
    	}
    	

    	var reqParams = {
            method: "post",
            url: goServiceUrl + "/pipeline/getExportData",
            data: {
                user_id: userId,
                start_date:startDate,
                end_date:endDate,
                source_type:$scope.selectedSourceType,
                user_role:userRole
            }
        };
        var deferred = $q.defer();
        $http(reqParams).then(function(resp){
        		console.log("pipeline export got data="+JSON.stringify(resp.data));
                deferred.resolve(resp.data.data);
            },
            function(err){
            	console.log("pipeline export got error="+err);
                deferred.reject(err);
            }
        );
        return deferred.promise;
    };

    initExportController = function() {
          //  $scope.popup.isOpened = false;
          
            $scope.dtSD = null;
            $scope.dtED = null;
            $scope.format = 'dd-MMMM-yyyy';
            $scope.maxDate = new Date();
            $scope.dateOptions = {
                formatYear: 'yy',
                startingDay: 1
            };
            $scope.fileName = "Marketing_Lead";
    }

    $scope.openSD = function() {
         $scope.popup.isOpenedSD = true;
         checkScopeBeforeApply();
    };
      $scope.openED = function() {
         $scope.popup.isOpenedED = true;
         checkScopeBeforeApply();
    };
    //initiliaze
    initExportController();
}
);
