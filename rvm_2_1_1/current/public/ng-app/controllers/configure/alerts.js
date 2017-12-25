InquirlyApp.controller('AlertConfigController', function($scope,$rootScope, $http,$modal) {

    $scope.isBusiness = true;
    $scope.isFetching = false;

    $scope.getAlertConfig = function(){
        $scope.isFetching = true;
        $http.get('/alert_config.json').success(function(data) {
            $scope.allEvents = data.alert_events;
            $scope.allConsumerEvents = _.where($scope.allEvents, { is_business_event: false });
            $scope.showEvents();
            $scope.isFetching = false;
        });
    };
    $scope.getAlertConfig();

    $scope.setTab = function(value){
          $scope.isBusiness = value == 'business';
          $scope.showEvents();
    };

    $scope.showEvents = function(){
        if($scope.isBusiness){
            $scope.eventLists = _.where($scope.allEvents, { is_business_event: true });
        }else{
            $scope.eventLists = _.where($scope.allEvents, { is_business_event: false });
        }
    };

    $scope.changeAlertStatus = function(event) {
        $scope.event = event;

        $modal.open({
            templateUrl: '/ng-app/templates/configure/changeAlertStatusDialog.html',
            controller: 'changeAlertStatusCtrl',
            scope: $scope
        });
    };

    $scope.changeChannelStatus = function(eventChannel, event,channel_name){
        $scope.event = event;
        $scope.eventChannel = eventChannel;
        if(channel_name != 'inquirly' && channel_name != 'opinify'){

           if($scope.event.is_business_event){
               if(channel_name == 'email' && !_.isNull($scope.event.alert_config) && $scope.valueExists($scope.event.alert_config.email.recipients)){
                   $scope.openChangeStatusDialog();
               }else if(channel_name == 'sms' && !_.isNull($scope.event.alert_config) && $scope.valueExists($scope.event.alert_config.sms.recipients)){
                   $scope.openChangeStatusDialog();
               }else{
                   var channel = channel_name == 'email' ? 'email' : 'mobile number';
                   var msg = "You must have at-least one valid "+ channel +" to active this channel";
                   $scope.alerts = [{ type: 'danger', msg: msg }];
                   $("html, body").animate({ scrollTop: "10px" });
               }
           }else{
               $scope.openChangeStatusDialog();
           }

        }
    };

    $scope.openChangeStatusDialog = function(){
        $modal.open({
            templateUrl: '/ng-app/templates/configure/changeAlertChannelStatus.html',
            controller: 'changeAlertChannelStatusCtrl',
            scope: $scope
        });
    };

    $scope.valueExists = function(value){
        return (!_.isEmpty(value) && !_.isUndefined(value) && !_.isNull(value))
    };

    $scope.closeAlert = function(index) {
        $scope.alerts.splice(index, 1);
    };

    $scope.changeStatus = function(channel,event){
        $scope.eventE = _.findWhere($scope.allEvents, {name: event.name});
        $scope.actualChannel = _.findWhere($scope.eventE.event_channels, {id: channel.id});
        $scope.actualChannel.is_active = channel.is_active ? false : true;
    };

    var requestPath;
    $scope.alertConfig = function(event){
        $scope.singleEvent = event;
        if($scope.singleEvent.is_default){
            $scope.configDialog();
        }else{
            var isBusinessEvent  = $scope.singleEvent.is_business_event;
            requestPath =  isBusinessEvent ? baseURL + '/campaigns/alertPlaceHolders' : '/alert_config/get_alert_placeholders';
            $http.post(requestPath,{alert_id: $scope.singleEvent.id }).success(function(data) {
                if(_.isNull($scope.singleEvent.alert_config)){
                    $scope.singleEvent.alert_config = isBusinessEvent ? { email: {}, sms: {}, business_app: {} } : { email: {}, sms: {}, consumer_app: {} }
                }
                $scope.singleEvent.alert_config.email.placeholders = data.placeholders;
                $scope.singleEvent.alert_config.sms.placeholders = data.placeholders;
                if(isBusinessEvent){
                    $scope.singleEvent.alert_config.business_app.placeholders = data.placeholders;
                }else{
                    $scope.singleEvent.alert_config.consumer_app.placeholders = data.placeholders;
                }
                $scope.configDialog();
            });
        }
    };

    $scope.configDialog = function(){
        $modal.open({
            templateUrl: '/ng-app/templates/configure/alertConfig.html',
            controller: 'alertConfigCtrl',
            size: 'lg',
            scope: $scope
        });
    };

    // Alert Actions functions

    var templateUrl;
    var controllerName;

    $scope.createCampaignAlerts = function(is_business) {

        if(is_business){
            templateUrl = baseURL + '/campaigns/set_alerts_dialog';
            controllerName = 'setCampaignAlertsCtrl';
        }else{
            templateUrl = '/ng-app/templates/configure/createAlertForm.html';
            controllerName = 'setConsumerAlertsCtrl'
        }
        var modal = $modal.open({
            templateUrl: templateUrl,
            controller: controllerName,
            size: 'md',
            keyboard:false,
            backdrop:'static',
            resolve: {
                alert_id : function () {
                    return null;
                },
                alert_event: function () {
                    return null;
                }
            }
        });

        modal.result.then(function (row) {
            $scope.eventLists.push(row) ;
            $scope.allEvents.push(row);
            var last = $scope.eventLists[$scope.eventLists.length-1];
            $scope.alertConfig(last);
        });
    };

    $scope.deleteCampaignAlert = function(alert_info) {

        if(alert_info.is_default){
            $scope.alerts = [{ type: 'danger', msg: "You don't have permission to delete default alert." }];
            $("html, body").animate({ scrollTop: "10px" });
            return;
        }

        if(alert_info.is_business_event){
            templateUrl = baseURL + '/campaigns/delete_alerts_dialog';
            controllerName = 'deleteCampaignAlertsCtrl';
        }else{
            templateUrl = '/ng-app/templates/configure/removeAlertEvent.html';
            controllerName = 'removeConsumerAlertsCtrl'
        }
        var modal = $modal.open({
            templateUrl: templateUrl,
            controller: controllerName,
            size: 'md',
            resolve: {
                alert_info :alert_info
            }
        });

        modal.result.then(function () {
            for(var i=0; $scope.eventLists.length; i++) {
                if($scope.eventLists[i].id == alert_info.id) {
                    $scope.eventLists.splice(i,1);
                    return;
                }
            }
        });
    };

    $scope.editCampaignAlert = function(alert_info) {

        if(alert_info.is_default){
            $scope.alerts = [{ type: 'danger', msg: "You don't have permission to edit default alert." }];
            $("html, body").animate({ scrollTop: "10px" });
            return;
        }
        if(alert_info.is_business_event){
            templateUrl = baseURL + '/campaigns/set_alerts_dialog';
            controllerName = 'setCampaignAlertsCtrl';
        }else{
            templateUrl = '/ng-app/templates/configure/createAlertForm.html';
            controllerName = 'setConsumerAlertsCtrl'
        }

        var modal = $modal.open({
            templateUrl: templateUrl,
            controller: controllerName,
            size: 'md',
            keyboard:false,
            backdrop:'static',
            resolve: {
                alert_id : function () {
                    return alert_info.id;
                },
                alert_event: alert_info
            }
        });

        modal.result.then(function (row) {
            angular.forEach($scope.eventLists, function(value, i) {
                if (value.id == row.id ) {
                    $scope.eventLists[i] = row;
                }
            });
        });
    };

    // Code Mirror Config
    $scope.uiCodeConfig = {
        lineNumbers: true,
        theme:'xq-light',
        styleActiveLine: true,
        matchBrackets: true,
        mode: 'text/html'
    };

    $scope.emailMessages = [{ text: "Text", isHtmlEmail: false, checked: true }, { text: "HTML", isHtmlEmail: true, checked: false }];

    $scope.showHtml = false;

});

InquirlyApp.controller('changeAlertStatusCtrl', function ($scope,$http, $modalInstance) {

    $scope.statusSubmitted = false;
    $scope.eventS = $scope.event;

    var status;

    $scope.yes = function () {
        $scope.statusSubmitted = true;
        var alertEvents = {};
        status = $scope.eventS.is_set ? false : true;
        $scope.eventS.is_set = status;
        alertEvents["id"] = $scope.event.id;
        alertEvents["is_set_on"] = status;

        $http.post('/alert_config/change_event_status', alertEvents).success(function(data) {
            $scope.statusSubmitted = false;
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

InquirlyApp.controller('changeAlertChannelStatusCtrl', function ($scope,$http, $modalInstance) {

    $scope.statusSubmitted = false;

    $scope.yes = function () {
        $scope.statusSubmitted = true;
        var alertEvents = {};
        $scope.changeStatus($scope.eventChannel,$scope.event,$scope.type);
        alertEvents["id"] = $scope.eventChannel.id;
        alertEvents["is_active"] = $scope.eventChannel.is_active;

        $http.post('/alert_config/change_channel_status', alertEvents).success(function(data) {
            $scope.statusSubmitted = false;
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

InquirlyApp.controller('alertConfigCtrl', function ($scope,$http, $modalInstance,$sce) {

    $scope.state = 'email';
    $scope.isSmsExceed = false;
    $scope.isEmailExceed = false;
    $scope.isSubmitted = false;
    $scope.email = {};
    $scope.sms = {};
    $scope.business_app = {};
    $scope.consumer_app = {};
    $scope.isBusinessEvent = $scope.singleEvent.is_business_event;

    $scope.previewLink = 'Show Preview';
    $scope.selectedOpt = function(value){
        $scope.showHtml = value.text != 'Text';
    };

    $scope.showContent = function(){
        if($scope.previewLink == 'Show Preview'){
            $scope.previewLink = 'Edit HTML';
        }else{
            $scope.previewLink = 'Show Preview';
        }
    };

    if(!_.isNull($scope.singleEvent.alert_config)){
        var config = $scope.singleEvent.alert_config;

        if(config.is_html){
            $scope.emailMessages = [{ text: "Text", isHtmlEmail: false, checked: false }, { text: "HTML", isHtmlEmail: true, checked: true }];
            $scope.showHtml = true;
        }

        // EMAIL

        $scope.email.recipients = [];
        $scope.email.recipients = config.email.recipients;
        $scope.email.message = config.email.message;
        $scope.email.subject = config.email.subject;

        $scope.email.placeholders = [];
        var emailPlaceholders = {label:'Email Placeholders', placeholders: config.email.placeholders };
        if($scope.singleEvent.is_default){
            $scope.email.placeholders.push(emailPlaceholders);
        }else{
            if($scope.isBusinessEvent){
                _.each(config.email.placeholders, function( value,key ) {
                    $scope.email.placeholders.push({label: key, placeholders: value });
                });
            }else{
                $scope.email.placeholders.push(emailPlaceholders);
            }
        }

        // SMS

        $scope.sms.recipients = [];
        $scope.sms.recipients = config.sms.recipients;
        $scope.sms.message = config.sms.message;

        $scope.sms.placeholders = [];
        var smsPlaceholders = {label:'SMS Placeholders', placeholders: config.sms.placeholders };
        if($scope.singleEvent.is_default){
            $scope.sms.placeholders.push(smsPlaceholders);
        }else{
            if($scope.isBusinessEvent){
                _.each(config.sms.placeholders, function( value,key ) {
                    $scope.sms.placeholders.push({label: key, placeholders: value });
                });
            }else{
                $scope.sms.placeholders.push(smsPlaceholders);
            }
        }

        // Inquirly App

        $scope.business_app.message = config.business_app.message;

        $scope.business_app.placeholders = [];
        if($scope.singleEvent.is_default){
            $scope.business_app.placeholders.push({label:'Notification Placeholders', placeholders: config.business_app.placeholders });
        }else{
            _.each(config.business_app.placeholders, function( value,key ) {
                $scope.business_app.placeholders.push({label: key, placeholders: value });
            });
        }

        // Consumer App

        $scope.consumer_app.message = !_.isUndefined(config.consumer_app) ? config.consumer_app.message : '';
        $scope.consumer_app.placeholders = !_.isUndefined(config.consumer_app) ? config.consumer_app.placeholders : [];

    }

    $scope.$watch("email.recipients", function(value) {
        $scope.isEmailExceed = !_.isUndefined(value) && !_.isNull(value) ? value.length > 5  : false
    }, true);

    $scope.$watch("sms.recipients", function(value) {
        $scope.isSmsExceed = !_.isUndefined(value) && !_.isNull(value) ? value.length > 5 : false
    }, true);

    $scope.showTab = function(state){
        $scope.state = state;
    };

    $scope.btnTitle = "SAVE";
    $scope.saveEventForm = function(config, type,isHtml){
        $scope.isSubmitted = true;
        $scope.btnTitle = "SAVING<i class='fa fa-spinner fa-spin'></i>";
        var params;
        if(type == 'email'){
            params = { event_id: $scope.singleEvent.id, email: _.omit(config, 'placeholders'), is_html: isHtml }
        }else if(type == 'sms'){
            params = { event_id: $scope.singleEvent.id, sms: _.omit(config, 'placeholders') }
        }else if(type == 'business_app'){
            params = { event_id: $scope.singleEvent.id, business_app: _.omit(config, 'placeholders') }
        }else if(type == 'consumer_app'){
            params = { event_id: $scope.singleEvent.id, consumer_app: _.omit(config, 'placeholders') }
        }
        $http.post('/alert_config/update_alert_config', params).success(function(data) {
            $scope.btnTitle = "SAVE";
            $scope.singleEvent.alert_config = data;
            $scope.isSubmitted = false;
        })
    };

    $scope.parseContent = function(value) {
        return $sce.trustAsHtml(value);
    };

    $scope.charCount = !_.isUndefined($scope.sms.message) ? 138 - $scope.sms.message.length : 138;
    $scope.$watch("sms.message", function(newValue, oldValue) {
        $scope.charCount  = !_.isUndefined(newValue) ? 138 - newValue.length : 138;
    });

    $scope.postCharCount = !_.isUndefined($scope.business_app.message) ? 100 - $scope.business_app.message.length : 100;
    $scope.$watch("business_app.message", function(newValue, oldValue) {
        $scope.postCharCount  = !_.isUndefined(newValue) ? 100 - newValue.length : 100;
    });


    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('setConsumerAlertsCtrl', function ($scope,$http, $modalInstance, alert_event) {

    $scope.alertEvent = alert_event;
    $scope.consumerEventError = '';
    $scope.consumer_event = $scope.alertEvent ? $scope.alertEvent.name : '';

    $scope.saveConsumerAlert = function(event){
        var params = { event_name: $scope.consumer_event, alert_type: 'consumer', alert_name: 'pipeline', user_id: $("#socket-id").val(), placeholders: $scope.items };
        if(event) { _.extend(params, {event_id : event.id });}
        var requestPath = event ? '/alert_config/update_alert_event' : '/alert_config/create_alert_event';
        $http.post(requestPath, params).success(function(resp) {
            if(resp.status == 200) {
                $modalInstance.close(resp.event);
            }else{
                $scope.consumerEventError = resp.error[0];
            }
        });
    };

    if($scope.alertEvent){
        $scope.items = [];
        if($scope.alertEvent.alert_config){
            angular.forEach($scope.alertEvent.alert_config.email.placeholders, function(value, key){
                var new_value = value.name.slice(1, -1);
                $scope.items.push({name: new_value, title: value.title });
            });
        }
    }else{
        $scope.items = [{name: "", title: ""}];
    }

    $scope.addPlaceholder = function () {
        $scope.items.push({
            name: "",
            title: ""
        });
    };

    $scope.removePlaceholder = function(index) {
        $scope.items.splice(index, 1);
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('removeConsumerAlertsCtrl', function ($scope,$http, $modalInstance, alert_info) {

    $scope.yes = function () {
        $http.post('/alert_config/delete_alert_event', {event_id: alert_info.id, user_id: alert_info.user_id}).success(function(data) {
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