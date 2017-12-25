InquirlyApp.controller('ScheduleController', function($scope, $http,$modal) {

    $scope.getScheduleList = function(){
        $http.get('/configurations/get_schedule_types').success(function(data) {
            $scope.scheduleTypes = data;
            $scope.scheduleNames = [];
            $scope.activeDays = [];
            $scope.scheduleSlots = [];
            $scope.currentStates = [];
            $scope.currentStates.push($scope.scheduleTypes[0].name);
            angular.forEach($scope.scheduleTypes, function (type) {
                $scope.scheduleNames.push({name: type.name, is_active: type.is_active});
                if($scope.currentStates.indexOf(type.name) == 0){
                    $scope.activeScheduleType = type;
                    _.map(type.schedule_days, function(v, k) {
                        $scope.activeDays.push({name: k, is_active: v})
                    });
                    $scope.scheduleSlots = type.schedule_slots;
                }
            });
        });
    };

    $scope.time = new Date();
    $scope.showMeridian = true;
    $scope.isInvalid = false;
    $scope.isDuplicate = false;

    $scope.addSlot = function(){
        if(!_.isNull($scope.time)){
            $scope.isInvalid = false;
            $scope.isDuplicate = false;
            var slot = {slot: getCurrentTime($scope.time), schedule_type_id: $scope.activeScheduleType.id};
            // Check for duplicate
            var slots = _.findWhere($scope.scheduleSlots, {slot: slot.slot});
            if(_.isEmpty(slots)){
                $http.post('/configurations/add_slot', slot).success(function(data) {
                    if(data && data.errors){
                        $scope.isDuplicate = true;
                    }else{
                        $scope.scheduleSlots = data;
                    }
                });
            }else{
                $scope.isDuplicate = true;
            }
        }else{
            $scope.isInvalid = true;
        }
    };

    $scope.removeSlot = function(slot){
        $scope.selectedForRemove = slot;
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/configure/removeSlot.html',
            controller: 'removeSlotCtrl',
            scope: $scope,
            resolve: {}
        });
    };

    function getCurrentTime(time) {
        var slotTime;
        var hour = time.getHours();
        var mm = hour >= 12 ? " PM" : " AM";
        slotTime = ((hour + 11) % 12 + 1) + ":" + addZeroToMinutes(time) + mm;
        return slotTime;
    }

    function addZeroToMinutes(time){
        var min = time.getMinutes();
        if (min.toString().length == 1) {
            min  = "0" + min;
        }
        return min;
    }

    $scope.getScheduleList();

    $scope.resetSlots = function(slots){
        $scope.scheduleSlots = slots;
    };

    $scope.changeActiveDays = function(day,state){
        var inactiveDays;
        angular.forEach($scope.activeDays, function (active,i) {
            if(active.name == day.name){

                $scope.activeDays[i] = {name: day.name, is_active: state ? false : true };

                inactiveDays = _.where($scope.activeDays, {is_active: false });
                if( inactiveDays.length == $scope.activeDays.length){
                    $scope.alerts = [{ type: 'danger', msg: "There must be at-least one active day in a schedule" }];
                    $scope.activeDays[i] = {name: day.name, is_active: true };
                }
            }
        });

        if( inactiveDays.length != $scope.activeDays.length){
            var schedule = {schedule_days: $scope.activeDays, id: $scope.activeScheduleType.id };
            $http.post('/configurations/update_active_days', schedule).success(function(data) {
                $scope.activeDays = [];
                _.map(data, function(v, k) {
                    $scope.activeDays.push({name: k, is_active: v})
                });
            });
        }
    };

    $scope.closeAlert = function(index) {
        $scope.alerts.splice(index, 1);
    };

    $scope.mapSchedule = function(){
        var schedule = { id: $scope.activeScheduleType.id };
        $http.post('/configurations/update_schedule', schedule).success(function(data) {
            $scope.alerts = [data];
        });
    };

    $scope.addSchedule = function(){
        $scope.weekDays = [{ name: "MONDAY", is_active: false }, { name: "TUESDAY", is_active: false},{ name: "WEDNESDAY",is_active: false},
                       { name: "THURSDAY",is_active: false},{ name: "FRIDAY",is_active: false},{ name: "SATURDAY",is_active: false},
                       { name: "SUNDAY",is_active: false}];
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/configure/addSchedule.html',
            controller: 'addScheduleCtrl',
            scope: $scope,
            resolve: {}
        });
    };

    $scope.setActiveState = function(schedule){
        $scope.currentStates = [];
        $scope.currentStates.push(schedule.name);

        // On Select
        $scope.scheduleNames = [];
        $scope.activeDays = [];
        $scope.scheduleSlots = [];
        angular.forEach($scope.scheduleTypes, function (type) {
            $scope.scheduleNames.push({name: type.name, is_active: type.is_active});
            if($scope.currentStates.indexOf(type.name) == 0){
                $scope.activeScheduleType = type;
                _.map(type.schedule_days, function(v, k) {
                    $scope.activeDays.push({name: k, is_active: v})
                });
                $scope.scheduleSlots = type.schedule_slots;
            }
        });
    }
});

InquirlyApp.controller('addScheduleCtrl', function ($scope,$http, $modalInstance,$parse) {

    $scope.isActive = function(day){
        if (day.is_active) {
            return 'fa fa-check-square-o group-select';
        }else{
            return 'fa fa-square-o group-select';
        }
    };

    $scope.setActive = function (day) {
        angular.forEach($scope.weekDays, function (active,i) {
            if(active.name == day.name){
                $scope.weekDays[i] = {name: day.name, is_active: day.is_active ? false : true };
            }
        });
        return false;
    };

    $scope.scheduleName = '';
    $scope.form = {};

    $scope.saveSchedule = function(){

        $scope.isSubmitted = true;
        var params = { name: $scope.scheduleName, schedule_days: $scope.weekDays };
        $http.post('/configurations/save_schedule', params).success(function(data) {
            if(data && data.errors){
                var errorResponse = scheduleErrorResponse(data);
                for (var fieldName in errorResponse) {
                    var message = errorResponse[fieldName];
                    var serverMessage = $parse('form.schedules.'+fieldName+'.$error.serverMessage');

                    if (message == 'VALID') {
                        $scope.form.schedules.$setValidity(fieldName, true, $scope.form.schedules);
                        serverMessage.assign($scope, undefined);
                    }
                    else {
                        $scope.form.schedules.$setValidity(fieldName, false, $scope.form.schedules);
                        serverMessage.assign($scope, errorResponse[fieldName]);
                    }
                }
            }else{
                $scope.scheduleName = '';
                $scope.isSubmitted = false;
                $scope.getScheduleList();
                $modalInstance.close();
            }
        });
    };

    var scheduleErrorResponse = function(data){
        var fieldState = {name: 'VALID'};
        if (data.errors.name){
            if (data.errors.name[0] == "can't be blank")  fieldState.name = "Name can't be blank";
            if (data.errors.name[0] == "has already been taken")  fieldState.name = 'Duplicate name not allowed';
        }
        return fieldState;
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('removeSlotCtrl', function ($scope,$http, $modalInstance) {
    $scope.yes = function () {
        var slot = { id: $scope.selectedForRemove.id, schedule_type_id: $scope.selectedForRemove.schedule_type_id };
        var slots = _.without($scope.scheduleSlots, _.findWhere($scope.scheduleSlots, {id: $scope.selectedForRemove.id }));
        $http.post('/configurations/remove_slot', slot).success(function(data) {
            $scope.scheduleSlots = data;
            $scope.resetSlots(slots);
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