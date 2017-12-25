InquirlyApp.controller('HistoryController', function($scope,$http,$modal,$state,$location) {
    $scope.currentState = 'history';
    $scope.selectedChannel = [];
    $scope.selectedMobileChannel = [];
    $scope.selectedLocationChannel = [];
    /* Default Accounts (Should Move to service) */

    $http.get('/power_share/social_accounts.json').success(function(data) {
        $scope.socialAccounts =  data.social_accounts;
        $scope.mobileAccounts =  data.mobile_accounts;
        $scope.locationAccounts = data.in_location_accounts;
    });

    $scope.offset = 0;
    $scope.limit = 10;
    $scope.total = 0;
    $scope.historyCampaigns = [];
    $scope.isBusy = false;
    $scope.isLoading = true;
    var lists;
    $scope.loadMoreHistory = function(){
        if($scope.isBusy === true) return;
        $scope.isBusy = true;
        $http.get('/power_share/power_share_history.json?offset='+$scope.offset+'&limit='+$scope.limit+
            '&selected_socials='+$scope.selectedChannel+
            '&selected_mobiles='+$scope.selectedMobileChannel+
            '&selected_locations='+$scope.selectedLocationChannel)
            .success(function(data){
                lists = data;
                if( lists.length > 0 ){
                    for(var x=0; x< lists.length; x++){
                        $scope.historyCampaigns.push(lists[x]);
                    }
                    $scope.offset += lists.length;
                }
                $scope.total += lists.length;
                $scope.isLoading = false;
                $scope.isBusy = false;
            });
    };
    $scope.loadMoreHistory();

    /* Archive Post Function Begin */

    $scope._offset = 0;
    $scope._limit = 10;
    $scope.archiveTotal = 0;
    $scope.archiveCampaigns = [];
    $scope.isABusy = false;
    $scope.isALoading = true;
    var aLists;
    $scope.loadMoreArchive = function(){
        if($scope.isABusy === true) return;
        $scope.isABusy = true;
        $http.get('/power_share/power_share_archive?offset='+$scope._offset+'&limit='+$scope._limit+
            '&selected_socials='+$scope.selectedChannel+
            '&selected_mobiles='+$scope.selectedMobileChannel+
            '&selected_locations='+$scope.selectedLocationChannel)
            .success(function(data){
                aLists = data;
                if( aLists.length > 0 ){
                    for(var x=0; x< aLists.length; x++){
                        $scope.archiveCampaigns.push(aLists[x]);
                    }
                    $scope._offset += aLists.length;
                }
                $scope.archiveTotal += aLists.length;
                $scope.isALoading = false;
                $scope.isABusy = false;
            });
    };

    $scope.archive = function(post,is_archive){
         $scope.is_archive = is_archive;
         $scope.label = $scope.is_archive ? "archive" : "history";
         $scope.post = post;
         var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/home/historyDialog.html',
            controller: 'historyArchiveCtrl',
            size:'lg',
            scope: $scope,
            resolve: {}
         });
    };

    $scope.history_location = $location;
    $scope.$watch('history_location.search()', function(search) {
        if(!_.isEmpty(search) && !_.isUndefined(search.post_id) && !_.isNull(search.post_id)){
            $scope.postNotify(search.post_id);
        }
    });

    $scope.postNotify = function(post_id){
        $http.post('/power_share/post_info',{post_id: post_id}).success(function(data) {
            $scope.postCount = data.length;
            $scope.postCampaign = _.isEmpty(data) ? [] : data[0];
            if( $location.path() == '/home/history'){
                $modal.open({
                    templateUrl: '/ng-app/templates/home/postInfo.html',
                    controller: 'postInfoCtrl',
                    size:'lg',
                    backdrop : 'static',
                    scope: $scope,
                    resolve: {}
                });
            }
        });
    };

    /* Archive Post Function End */

    $scope.showPost = function(state){
        $scope.currentState = state;
        $scope.reset();
    };

    $scope.showDetails = function(historyCampaign){
        $scope.reach = historyCampaign.reach;
        $scope.views = historyCampaign.views;
        $scope.reachData = {};

        var channels = { email_accounts: [], sms_accounts: [], fb_accounts: [], tw_accounts: [], ln_accounts: [] };
        angular.forEach(historyCampaign.mobile_accounts, function (mobile) {
            if(mobile.channel == "email")
                channels.email_accounts.push(mobile.id);
            else if(mobile.channel == "sms")
                channels.sms_accounts.push(mobile.id);
        });

        angular.forEach(historyCampaign.social_accounts, function (social) {
            if(social.channel == "facebook")
                channels.fb_accounts.push(social.id);
            else if(social.channel == "twitter")
                channels.tw_accounts.push(social.id);
            else if(social.channel == "linkedin")
                channels.ln_accounts.push(social.id);
        });

        $http.post("/power_share/get_reach", channels).success(function(data) {
            if (data.current_reach['sms'] == "0" && data.current_reach['email'] == "0"
                && data.current_reach['tw'] == "0" && data.current_reach['fb'] == "0" && data.current_reach['ln'] == "0"){
                $scope.reachData = {};
            }else{
                $scope.reachData = {
                    "donut_label" : "Total Reach",
                    "values" :[{
                        "label":"SMS",
                        "color":"#BD10E0",
                        "reach": data.current_reach['sms']
                    },
                    {
                        "label":"Email",
                        "color":"#F5A623",
                        "reach": data.current_reach['email']
                    },
                    {
                        "label":"Twitter",
                        "color":"#4099FF",
                        "reach": data.current_reach['tw']
                    },
                    {
                        "label":"Facebook",
                        "color":"#3B5998",
                        "reach": data.current_reach['fb']
                    },
                    {
                        "label":"LinkedIn",
                        "color":"#0077B5",
                        "reach": data.current_reach['ln']
                    }]
                }
            }
            $scope.totalReach = 0;
            angular.forEach(data.reaches, function (obj) { $scope.totalReach += obj.value;});
            $scope.reaches = data.reaches;

            var modalInstance = $modal.open({
                templateUrl: '/ng-app/templates/home/viewReachDialog.html',
                controller: 'historyDetailsCtrl',
                size:'lg',
                scope: $scope,
                resolve: {}
            });
        });
    };

    $scope.rePost = function(post){
        var result = { postParams: {post_info: post } };
        $state.transitionTo('home.index', result);
    };

    /* Filter Function Begin */
    $scope.filterTxt = "No Filter";
    $scope.setSelectedChannel = function (account) {
        var id = account.id;
        if (_.contains($scope.selectedChannel, id)) {
            $scope.selectedChannel = _.without($scope.selectedChannel, id);
        } else {
            $scope.selectedChannel.push(id);
        }
        if($scope.selectedChannel.length > 0) {
            $scope.filterTxt = "Filters Applied";
        }else{
            $scope.filterTxt = "No Filter";
        }

        $scope.reset();
        return false;
    };


    $scope.reset = function(){
        if($scope.currentState == "history"){
            $scope.resetHistory();
        }else{
            $scope.resetArchive();
        }
    };

    $scope.resetHistory = function(){
        $scope.offset = 0;
        $scope.limit = 10;
        $scope.isLoading = true;
        $scope.total = 0;
        $scope.historyCampaigns = [];
        $scope.loadMoreHistory();
    };

    $scope.resetArchive = function(){
        $scope._offset = 0;
        $scope._limit = 10;
        $scope.archiveTotal = 0;
        $scope.isALoading = true;
        $scope.archiveCampaigns = [];
        $scope.loadMoreArchive();
    };

    $scope.clearAll = function(){
        $scope.selectedChannel = [];
        $scope.selectedMobileChannel = [];
        $scope.selectedLocationChannel = [];
        $scope.filterTxt = "No Filter";
        $scope.reset();
    };

    $scope.isFiltered = function(){
        if($scope.selectedChannel.length > 0 || $scope.selectedMobileChannel.length > 0 || $scope.selectedLocationChannel.length > 0){
            return 'fnt-blue';
        }
        return false;
    };

    $scope.isChecked = function (id) {
        if (_.contains($scope.selectedChannel, id)) {
            return 'fa fa-check pull-right account-check';
        }
        return false;
    };

    $scope.setSelectedMobileChannel = function (account) {
        var id = account.id;
        if (_.contains($scope.selectedMobileChannel, id)) {
            $scope.selectedMobileChannel = _.without($scope.selectedMobileChannel, id);
        } else {
            $scope.selectedMobileChannel.push(id);
        }
        if($scope.selectedMobileChannel.length > 0) {
            $scope.filterTxt = "Filtered Feed";
        }else{
            $scope.filterTxt = "No Filter";
        }

        $scope.reset();
        return false;
    };

    $scope.isMobileChecked = function (id) {
        if (_.contains($scope.selectedMobileChannel, id)) {
            return 'fa fa-check pull-right account-check';
        }
        return false;
    };

    $scope.setSelectedLocationChannel = function (account) {
        var id = account.id;
        if (_.contains($scope.selectedLocationChannel, id)) {
            $scope.selectedLocationChannel = _.without($scope.selectedLocationChannel, id);
        } else {
            $scope.selectedLocationChannel.push(id);
        }
        if($scope.selectedLocationChannel.length > 0) {
            $scope.filterTxt = "Filters Applied";
        }else{
            $scope.filterTxt = "No Filter";
        }

        $scope.reset();
        return false;
    };

    $scope.isLocationChecked = function (id) {
        if (_.contains($scope.selectedLocationChannel, id)) {
            return 'fa fa-check pull-right account-check';
        }
        return false;
    };

    $scope.checkOnlyBeaconShared = function(location){
        var beacon = _.findWhere(location, {channel: "beacon"});
        return _.isUndefined(beacon) ? [] : beacon;
    };

    $scope.previewOnHistory = function (data,mobile_accounts,social_accounts,location_accounts) {
        $scope.sms_contents = [];
        $scope.campaignData = data;
        $scope.content =  $scope.campaignData.share_content;
        if (!_.isUndefined($scope.campaignData.sms_content)){
            $scope.campaignData.sms_content.length > 160 ? $scope.sms_contents = $scope.campaignData.sms_content.match(/.{1,160}/g) : $scope.sms_contents.push($scope.campaignData.sms_content)
        }
        $scope.twitterAccounts = [];
        $scope.facebookAccounts = [];
        $scope.linkedinAccounts = [];
        angular.forEach(social_accounts, function (account) {
            if(account.channel == 'twitter'){
                $scope.twitterAccounts.push(account.id);
                $scope.twitterName = account.name;
                $scope.twitterProfile = account.profile_image;
            }else if(account.channel == 'facebook'){
                $scope.facebookAccounts.push(account.id);
                $scope.facebookName = account.name;
                $scope.facebookProfile = account.profile_image;
            }else if(account.channel == 'linkedin'){
                $scope.linkedinAccounts.push(account.id);
                $scope.linkedinName = account.name;
                $scope.linkedinProfile = account.profile_image;
            }
        });
        $scope.smsAccounts = [];
        $scope.emailAccounts = [];
        angular.forEach(mobile_accounts, function (account) {
            if(account.channel == 'sms')
                $scope.smsAccounts.push(account.id);
            else if(account.channel == 'email')
                $scope.emailAccounts.push(account.id);
        });
        $scope.beaconAccounts = [];
        $scope.qrCodeAccounts = [];
        angular.forEach(location_accounts, function (account) {
            if(account.channel == 'beacon')
                $scope.beaconAccounts.push(account.id);
            else if(account.channel == 'qrcode') {
                $scope.qrCodeAccounts.push(account.id);
                $scope.historyQrImage = account.image;
            }
        });
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/home/previewOnHistory.html',
            controller: 'historyPreviewCtrl',
            scope: $scope,
            size: 'lg',
            resolve: {
                accounts: function(){
                    return  $scope.socialAccounts;
                }
            }
        });

    };

    $scope.getInitials = function (name) {
        var canvas = document.createElement('canvas');
        canvas.style.display = 'none';
        canvas.width = '32';
        canvas.height = '32';
        document.body.appendChild(canvas);
        var context = canvas.getContext('2d');
        context.fillStyle = "#999";
        context.fillRect(0, 0, canvas.width, canvas.height);
        context.font = "18px Arial";
        context.fillStyle = "#ECECF0";
        if (name) {
            var initials;
            initials = name;
            context.fillText(initials.toUpperCase(), 10, 23);
            var data = canvas.toDataURL();
            document.body.removeChild(canvas);
            return data;
        } else {
            return false;
        }
    };

});

InquirlyApp.controller('historyArchiveCtrl',['$scope', '$modalInstance', '$modal','$http', function ($scope, $modalInstance, $modal, $http) {
    $scope.yes = function () {
        var archivePost = { campaign_id: $scope.post.campaign_id, state: $scope.is_archive};
        if($scope.is_archive){
            var hIndex = $scope.historyCampaigns.indexOf($scope.post);
            $scope.historyCampaigns.splice(hIndex, 1);
        }else{
            var aIndex = $scope.archiveCampaigns.indexOf($scope.post);
            $scope.archiveCampaigns.splice(aIndex, 1);
        }
        $http.post('/power_share/archive_post', archivePost).success(function(data) {
            $scope.reset();
            $modalInstance.close();
        });
    };
    $scope.no = function () {
        $modalInstance.dismiss('cancel');
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };

}]);


InquirlyApp.controller('historyPreviewCtrl', function($scope,$http,$modalInstance) {

    defaultState();

    $scope.showPreview = function(channel){
        $scope.state = channel;
    };
    $scope.ok = function () {
        $modalInstance.close();
    };
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };

    function defaultState(){
        var social_blank = ($scope.facebookAccounts.length == 0 && $scope.twitterAccounts.length == 0 && $scope.linkedinAccounts.length == 0);
        var mobile_not_blank = ($scope.smsAccounts.length > 0 && $scope.emailAccounts.length > 0);
        var email_blank = ($scope.smsAccounts.length > 0 && $scope.emailAccounts.length == 0);
        $scope.state = "facebook";
        if($scope.facebookAccounts.length == 0 && $scope.twitterAccounts.length == 0 && $scope.linkedinAccounts.length == 0 && $scope.smsAccounts.length == 0 && $scope.emailAccounts.length > 0)
            $scope.state = "email";
        else if(social_blank && (mobile_not_blank || email_blank))
            $scope.state = "sms";
        else if($scope.facebookAccounts.length == 0 && $scope.twitterAccounts.length == 0 && $scope.linkedinAccounts.length > 0)
            $scope.state = "LinkedIn";
        else if($scope.facebookAccounts.length == 0 && $scope.twitterAccounts.length > 0 && ($scope.linkedinAccounts.length == 0 || $scope.linkedinAccounts.length > 0))
            $scope.state = "twitter";
        else if(social_blank && $scope.qrCodeAccounts.length > 0)
            $scope.state = "qrcode";
    }
});

InquirlyApp.controller('historyDetailsCtrl', function($scope,$http,$modalInstance) {
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('postInfoCtrl', function($scope,$http,$modalInstance,$location) {
    $scope.cancel = function () {
        $location.url($location.path());
        $location.$$search = {};
        $modalInstance.dismiss('cancel');
    };
});