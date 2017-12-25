InquirlyApp.controller('DashboardController', function($scope,$http,$modal,$state,Onboarding) {
    Onboarding.update_status($scope);
});

InquirlyApp.controller('CommandCenterController', function($scope,$http,$modal,$state,Session,$cookies,$location,uiCalendarConfig,$sce) {
    $scope.isServiceUser = Session.data.is_service_user;
    $scope.channels = [];
    $scope.campaigns = [];
    $scope.chartData = [];
    $scope.pipeLineGraphData = [];

    $scope.campaignFilter = '';
    $scope.channelFilter = 'all channels';
    $scope.filterBy = '';
    $scope.reviewSelection = 'POST';
    $scope.clientEmail = '';

    /* Fetch User Campaigns */

    $scope.loadUserDetails = function(client_user_id){
        $http.get('/dashboard?client_id='+ client_user_id).success(function(data) {
            $scope.updateDashboard(data,client_user_id);
            $cookies.client_user_id = client_user_id;
            $scope.clientId = $cookies.client_user_id;
        });
    };


    /* Choose Business Dialog */
    $scope.disableDialog = false;

    $scope.loadBusinessDialog = function(){
        $scope.disableDialog = true;
        $scope.user = {};
        $http.post('/dashboard/get_businesses_info',{type: 'business', id: Session.data.user_id }).success(function(data) {
            $scope.businesses = data;
            $modal.open({
                templateUrl: '/ng-app/templates/command-center/choose-business-dialog.html',
                controller: 'ChooseBusinessCtrl',
                size:'md',
                backdrop : 'static',
                scope: $scope,
                resolve: {}
            });
            $scope.disableDialog = false;
        });
    };

    $scope.loadAnalayticDialog = function(){
        var piwikURL = document.getElementById('piwik_url').value;
        var piwikSiteID = document.getElementById('piwik_site_id').value;
        var piwikToken = document.getElementById('piwik_token').value;
        $scope.piwik_url =  piwikURL + "index.php?module=Widgetize&action=iframe&moduleToWidgetize=Dashboard&actionToWidgetize=index&idSite=" + piwikSiteID + "&period=week&date=yesterday&token_auth=" + piwikToken;

        $http.get('/dashboard/get_piwik_info').success(function(data) {
            $scope.piwik_id = data;
            console.log($scope.piwik_id);

            $scope.piwik_url = $sce.trustAsResourceUrl($scope.piwik_url.replace('piwik_id', data));
            $modal.open({
                templateUrl:'/ng-app/templates/command-center/analytic-dialog.html',
                size:'lg',
		scope: $scope,
                resolve :{}
            });
        });
    };
    $scope.clientId = $cookies.client_user_id;

    $scope.checkValidSession = function(){
        if($scope.isServiceUser && !_.isUndefined($scope.clientId) && !_.isNull($scope.clientId) && !_.isEmpty($scope.clientId)){
            $scope.loadUserDetails($scope.clientId);
        }else if($scope.isServiceUser) {
            $scope.loadBusinessDialog();
        }else if(!$scope.isServiceUser){
            $scope.loadUserDetails(Session.data.user_id);
        }
    };

    if(_.isUndefined($scope.isServiceUser)){
        $http.get('/account/user_details').
            success(function(data, status, headers, config) {
                Session.data.user_id = data.id;
                Session.data.user_first_name = data.first_name;
                Session.data.user_last_name = data.last_name;
                Session.data.user_profile_top = data.user_attachment ? data.user_attachment : '/ng-app/Images/user.png';
                Session.data.company_area = data.area;
                Session.data.company_address = data.address;
                Session.data.company_logo = data.company_attachment ? data.company_attachment : '/ng-app/Images/placeholder.png';
                Session.data.permissions = data.permissions;
                Session.data.industry = data.industry;
                Session.data.is_service_user = data.is_service_user;
                $scope.isServiceUser = Session.data.is_service_user;
                $scope.checkValidSession();
        });
    }else{
        $scope.checkValidSession();
    }

    $scope.isChartLoading = false;
    $scope.updateDashboard = function(data,client_user_id){
        $scope.campaigns = data.campaigns;
        $scope.channels = data.channels;
        $scope.companyLogo = data.company_logo;
        $scope.companyName = data.company_name;
        $scope.clientEmail = data.client_email;
        $scope.fetchUserEngagedChart(client_user_id);
        $scope.fetchPipelineDetails(client_user_id);
        $scope.filterReviewPosts();
        $scope.alertDetails();
    };

    $scope.changeChannelFilter = function(channel){
        $scope.channelFilter = channel;
        $scope.fetchUserEngagedChart($scope.clientId);
    };

    /* Area Chart Details */

    $scope.fetchUserEngagedChart = function(user_id){
        $scope.isChartLoading = true;
        var userId = (_.isNull(user_id) || _.isEmpty(user_id)) ? $cookies.client_user_id : user_id;
        var params = { campaign_filter: $scope.campaignFilter, channel_filter: $scope.channelFilter, filter_by: $scope.filterBy,user_id: parseInt(userId)};
        $http.post( baseURL + '/listen_v2/stats/stats/reach',params).success(function(data) {
            $scope.chartData = data.data;
            $scope.isChartLoading = false;
        });
    };

    /* Planner Details */
    $scope.scheduledCount = 0;
    $scope.reviewCount = 0;
    $scope.revisionCount = 0;
    $scope.eventSources = [];
    $scope.isPlannerLoading = false;

    $scope.plannerEvents = function(date){
        $scope.currentDate = date.toDateString();

        var calendar = uiCalendarConfig.calendars.visitCal;

        $scope.isPlannerLoading = true;
        angular.element('.fc-view').css('z-index', '0');
        angular.element('.fc-day-grid').css('position', 'relative').css('z-index', '0');

        var config = {
            headers:  {
                'X-CSRF-Token': $('meta[name=csrf-token]').attr('content'),
                'Content-Type': 'application/json'
            },
            current_date: $scope.currentDate,
            time_zone: Intl.DateTimeFormat().resolvedOptions().timeZone
        };
        $http.post('/dashboard/planner_details',config).success(function(data) {
            $scope.scheduledCount = data.scheduled_count;
            $scope.reviewCount = data.review_count;
            $scope.revisionCount = data.revision_count;
            $scope.eventSources.splice(0, $scope.eventSources.length);

            angular.forEach(data.event_source, function (event) {
                $scope.eventSources.push({
                    "color": event.color,
                    "textColor": event.textColor,
                    "events": event.events
                });
            });
            calendar.fullCalendar('refetchEvents');
            $scope.isServiceUser = data.is_service_user;
            $scope.isPlannerLoading = false;
        });
    };

    $scope.refreshPlanner = function(view){
        var date = new Date(view.calendar.getDate());
        $scope.plannerEvents(date);
    };

    $scope.uiConfig = {
        calendar:{
            height: 390,
            editable: false,
            header:{
                left: 'prev',
                center: 'title',
                right: 'next'
            },
            viewRender: $scope.refreshPlanner
        }
    };

    /* Pipeline Details */

    $scope.pipelineFilterVal = 'sales';
    $scope.pipelineDetailLoading = false;

    $scope.fetchPipelineDetails = function(client_id){
        $scope.pipelineDetailLoading = true;
        var config = {
            headers:  {
                'X-CSRF-Token': $('meta[name=csrf-token]').attr('content'),
                'Content-Type': 'application/json'
            },
            user_id: parseInt(client_id),
            type: $scope.pipelineFilterVal
        };
        /*$http.post( baseURL + '/pipeline/stats',config).success(function(data) {
            $scope.pipeLineGraphData = data;
            $scope.pipelineDetailLoading = false;
        });*///this block raising console error
         //working code by lakshmi
       $http({
       method : 'GET',
       url: baseURL + '/pipeline2/stats',
       headers: {
        'X-CSRF-Token': $('meta[name=csrf-token]').attr('content'),
        'Content-Type': 'application/json',
        'Accept': 'application/json'
       },
       }).then(function successCallback(response) {
         //console.log(response);
            $scope.pipeLineGraphData = response;
            $scope.pipelineDetailLoading = false;
       }, function errorCallback(response) {
        console.log(response);
        });
    };

    $scope.pipelineFilter = function(){
        $scope.fetchPipelineDetails($scope.clientId);
    };

    /* Post Reviews */

    $scope.poffset = 0;
    $scope.plimit = 10;
    $scope.ptotal = 0;
    $scope.reviewCampaigns = [];
    $scope.isPBusy = false;
    $scope.loadReview = true;
    $scope.reviewFilter = 'ALL';
    $scope.isPostReviewLoading = false;
    var rLists;
    $scope.reviewPosts= function(){
        $scope.isPostReviewLoading = true;
        if($scope.isPBusy === true) return;
        $scope.isPBusy= true;
        $http.get('/dashboard/post_reviews?offset='+$scope.poffset+'&limit='+$scope.plimit+'&filter_by='+$scope.reviewFilter)
            .success(function(data){
                rLists = data;
                if( rLists.length > 0 ){
                    for(var x=0; x< rLists.length; x++){
                        $scope.reviewCampaigns.push(rLists[x]);
                    }
                    $scope.poffset += rLists.length;
                }
                $scope.ptotal += rLists.length;
                $scope.loadReview = false;
                $scope.isPBusy = false;
                $scope.isPostReviewLoading = false;
        });
    };

    $scope.filterReviewPosts = function(condition){
        $scope.reviewFilter = condition || 'ALL';
        var section = _.isUndefined($scope.reviewSelection) ? 'POST' : $scope.reviewSelection;
        if( section == 'POST'){
            $scope.poffset = 0;
            $scope.reviewCampaigns = [];
            $scope.reviewPosts()
        }else{
            $scope.roffset = 0;
            $scope.revisionCampaigns = [];
            $scope.loadRevisions();
        }
    };

    /* Alert Details */
    $scope.loadAlert = false;
    $scope.aoffset = 0;
    $scope.alimit = 10;
    $scope.atotal = 0;
    $scope.isABusy = false;
    $scope.alertPosts = [];
    var aLists;

    $scope.alertDetails = function(){
        if($scope.isABusy === true) return;
        $scope.isABusy = true;
        $scope.loadAlert = true;
        var url = '/dashboard/alerts?offset='+$scope.aoffset+'&limit='+$scope.alimit;
        $http.get(url).success(function(data) {
            $scope.loadAlert = false;
            aLists = data.alerts;
            if( aLists.length > 0 ){
                for(var x=0; x< aLists.length; x++){
                    $scope.alertPosts.push(aLists[x]);
                }
                $scope.aoffset += aLists.length;
            }
            $scope.atotal += aLists.length;
            $scope.loadQueue = false;
            $scope.isQBusy = false;
            $scope.alertCount = data.alert_count;
            $scope.filterAlerts();
        });
    };

    // WebSocket Channel

    var channel = dispatcher.subscribe('posts');
    channel.bind('posts', function(post) {
        if (post.user_id == $("#socket-id").val()){
            $scope.alertCount += 1;
            $scope.alertFeeds.splice(0, 0, post);
        }
    });


    $scope.filterAlerts = function(){
        if($scope.filterOption != 'all'){
            $scope.alertFeeds = _.where($scope.alertPosts, { alert_type: $scope.filterOption });
        }else{
            $scope.alertFeeds = $scope.alertPosts;
        }
    };

    $scope.redirectCampaigns = function(campaign_id){
        $state.transitionTo('campaigns.campaign-builder',{'campaign_id':campaign_id});
        $location.path("/campaigns/campaign_builder");
    };

    $scope.plannerRoutes = function(section){
      if(section == 'scheduled_post'){
          $state.go('campaigns.index');
          $location.path("/campaigns/index");
      }else if(section == 'review'){
          $(window).scrollBottom(50);
          $scope.changeReviewTab('POST');
      }else{
          $(window).scrollBottom(50);
          $scope.changeReviewTab('REVISION');
      }
    };

    $.fn.scrollBottom = function(scroll){
        if(typeof scroll === 'number'){
            window.scrollTo(0,$(document).height() - $(window).height() - scroll);
            return $(document).height() - $(window).height() - scroll;
        } else {
            return $(document).height() - $(window).height() - $(window).scrollTop();
        }
    };

    $scope.closeAlert = function(index) {
        $scope.alerts.splice(index, 1);
    };

    /* Revision */

    $scope.changeReviewTab = function(section){
        $scope.reviewSelection = section;
        $(window).scrollBottom(50);
        if(section == 'POST'){
            $scope.poffset = 0;
            $scope.reviewCampaigns = [];
            $scope.reviewPosts()
        }else{
            $scope.roffset = 0;
            $scope.revisionCampaigns = [];
            $scope.loadRevisions();
        }
    };

    $scope.isPostRevisionLoading = false;
    $scope.roffset = 0;
    $scope.rlimit = 10;
    $scope.rtotal = 0;
    $scope.revisionCampaigns = [];
    $scope.isRBusy = false;
    $scope.loadRevision = true;
    $scope.reviewFilter = 'ALL';
    var reLists;
    $scope.loadRevisions= function(){
        $scope.isPostRevisionLoading = true;
        if($scope.isRBusy === true) return;
        $scope.isRBusy= true;
        $http.get('/dashboard/post_revision?offset='+$scope.roffset+'&limit='+$scope.rlimit+'&filter_by='+$scope.reviewFilter)
            .success(function(data){
                reLists = data;
                if( reLists.length > 0 ){
                    for(var x=0; x< reLists.length; x++){
                        $scope.revisionCampaigns.push(reLists[x]);
                    }
                    $scope.roffset += reLists.length;
                }
                $scope.rtotal += reLists.length;
                $scope.loadRevision = false;
                $scope.isRBusy = false;
                $scope.isPostRevisionLoading = false;
            });
    };

    $scope.checkRevision = function(campaign_id){
        $http.post('/dashboard/get_revision_info',{campaign_id: campaign_id}).success(function(data) {
            $scope.notes = data;
            $modal.open({
                templateUrl: '/ng-app/templates/command-center/revision-notes-dialog.html',
                controller: 'postRevisionCtrl',
                size:'md',
                scope: $scope,
                backdrop : 'static',
                resolve: {}
            });
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

    $scope.viewPostRedirect = function(logId,alertType,callBakeUrl){
        var log = _.findWhere($scope.alertPosts, {id: parseInt(logId) });
        if(!log.is_viewed){
            $scope.alertCount = $scope.alertCount - 1;
            var logs = { id: logId };
            $http.post('/alert_config/update_view_status',logs).success(function(data) {
                window.open(callBakeUrl, "_self");
                $scope.getAlerts();
                $scope.isOpen = false;
            });
        }else{
            window.open(callBakeUrl, "_self");
            $scope.isOpen = false;
        }
    };

    $scope.downloadReport = function(){
        var reportUrl = baseURL + '/listen_v2/stats/stats/report?user_id=' + $scope.clientId;
        window.open(reportUrl, "_blank");
    };
});

InquirlyApp.controller('ChooseBusinessCtrl', function($scope,$http,$modalInstance,$cookies) {
    $scope.tenants = [];
    $scope.users = [];

    $scope.checkTenantUserCount = function(){
        angular.forEach($scope.businesses, function (biz) {
            if(biz.id == $scope.user.mapped_business){  $scope.mappedBusiness = biz; }
        });

        if($scope.user.is_tenant_user == 'true' && $scope.mappedBusiness.tenant_count > 0){
            $scope.loadTenants();
        }else if($scope.mappedBusiness.tenant_count == 0){
            $scope.loadTenantUser();
        }
    };

    $scope.loadTenants = function(){
        $scope.users = [];
        if($scope.user.is_tenant_user == 'true'){
            $http.post('/dashboard/get_businesses_info',{type: 'tenants', company_id: $scope.user.mapped_business }).success(function(data) {
                $scope.tenants = data;
            });
        }else{
            $scope.user.mapped_tenant = '';
            $scope.loadTenantUser();
        }
    };

    $scope.loadTenantUser = function(){
        $http.post('/dashboard/get_businesses_info',{type: 'users', tenant_id: $scope.user.mapped_tenant, company_id: $scope.user.mapped_business}).success(function(data) {
            $scope.users = data;
        });
    };

    $scope.switchUser = function(){
        $scope.loadUserDetails($scope.user.mapped_user);
        $modalInstance.close();
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('postRevisionCtrl', function($scope,$http,$modalInstance) {

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    }
});
