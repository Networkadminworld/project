InquirlyApp.controller('PowerShareController', function($scope,$http,$modal,$state,Onboarding) {
    Onboarding.update_status($scope);
});

InquirlyApp.controller('HomeController', function($scope,$location,$http,$modal,$timeout,$parse,$cookies,$state,$rootScope,$stateParams,$document,Upload,fileReader,Onboarding,Session) {
    $scope.power = {};
    $scope.power.content = '';
    $scope.ogmetaData = {};
    $scope.tmetaData = {};
    $scope.form = {};
    $scope.form.shareForm = {};
    $scope.metaData = false;
    $scope.metaLoad = false;
    $scope.fbAccounts = [];
    $scope.twAccounts = [];
    $scope.lnAccounts = [];
    $scope.smsGroups = [];
    $scope.emailGroups = [];
    $scope.opinifyGroups = [];
    $scope.beacons = [];
    $scope.qrcodes = [];
    $scope.isLoading = true;

    $scope.powerShareOptionsView = 'queue';

    //recommendations code

    var recommendationUrl = document.getElementById('v2_reccos').value;
    $scope.page_num = 1;
    $scope.contents = null;
    $scope.page_size = 6;
    $scope.total = 0;
    $scope.first = 1;
    $scope.last = 6;
    var industry = Session.data.industry;
    var lastUpdate = 'x';
    var lengthOfResults = 0;
    $scope.articlesPerpage = [];

    $scope.fetchArticles = function(lastUpdate,industry){
        url = recommendationUrl + "articles/recommendation_articles/";
        sent_data = {"tag":industry,"lastupdate":lastUpdate};

        if (lastUpdate == 'x'){
            $scope.articlesPerpage = [];
        }

        $http.post(url,sent_data)
            .success(function(data,status,statusText) {
                $scope.contents = data;
                if ($scope.contents['results'] && $scope.contents['results'].length > 0 ){
                    $scope.articlesPerpage.push($scope.contents['results']);
                    $scope.total = $scope.contents['results'][0][8];
                    if ($scope.total < 6){
                        $scope.last = $scope.total;
                        $scope.first = 1;
                    }
                }
            })
            .error(function(data,status,error,config){
                $scope.contents = [{heading:"Error",description:"Could not load json data"}];
            });
    };

    $scope.fetchArticles(lastUpdate,industry);

    $scope.copyArticleUrl = function(url){
        $scope.power.content = url;
    };

    $scope.next = function (){
        if ($scope.page_num * $scope.page_size >= $scope.total){
            return
        }

        $scope.page_num = $scope.page_num + 1;
        if ($scope.page_num <= ($scope.articlesPerpage).length){
            $scope.contents = {'results':$scope.articlesPerpage[$scope.page_num-1]};
            $scope.first = $scope.first + 6;
            $scope.last = $scope.first + 5;
            if($scope.last > $scope.total){
                $scope.last = $scope.total;
            }

        }

        else{
            lengthOfResults = ($scope.contents['results']).length;
            lastUpdate = $scope.contents['results'][lengthOfResults-1][7];
            $scope.fetchArticles(lastUpdate,industry);
            $scope.first = $scope.first + 6;
            $scope.last = $scope.first + 5;
            if($scope.last > $scope.total){
                $scope.last = $scope.total;
            }
        }


    };

    $scope.prev = function (){
        if ($scope.page_num  <= 1){
            return
        }
        $scope.page_num = $scope.page_num - 1;
        if ($scope.page_num <= ($scope.articlesPerpage).length){
            $scope.contents = {'results':$scope.articlesPerpage[$scope.page_num-1]};
            $scope.first = $scope.first - 6;
            $scope.last = $scope.first + 5;
        }
        else{
            lengthOfResults = ($scope.contents['results']).length;
            lastUpdate = $scope.contents['results'][lengthOfResults-1][7];
            $scope.fetchArticles(lastUpdate,industry);
            $scope.first = $scope.first - 6;
            $scope.last = $scope.first + 5;
        }
    };

    $scope.onActivateView = function(viewName) {
        $scope.powerShareOptionsView = viewName;
        industry = Session.data.industry;
         if (viewName == 'recos') {
               $scope.fetchArticles(lastUpdate,industry);
        }
    };


    /* Channel Configuration */

    $scope.channelInit = function(){
        $scope.addedSocialAccount = [];
        $scope.addedMobileAccount = [];
        $scope.addedLocationAccount = [];
        $scope.twitterList = [];
        $scope.facebookList = [];
        $scope.linkedinList = [];
        $scope.smsList = [];
        $scope.emailList = [];
        $scope.opinifyList = [];
        $scope.beaconsList = [];
        $scope.qrcodesList = [];
    };
    $scope.channelInit();


    /* Load Social Accounts Begin */

    $http.get('/power_share/social_accounts.json').success(function(data, status, headers, config) {
        $scope.socialAccounts =  data.social_accounts;
        $scope.mobileAccounts =  data.mobile_accounts;
        $scope.locationAccounts = data.in_location_accounts;
        $scope.company =  data.company;
        $scope.power.emailSender = data.sender_email;
        $scope.default_tags = data.default_tags;
        $scope.splitSocialChannels($scope.socialAccounts);
        $scope.splitMobileChannels($scope.mobileAccounts);
        $scope.splitLocationChannels($scope.locationAccounts);
        $scope.loadMoreQueue();
    });

    /* Load Social Accounts End */

    /* Tour Function Begin */

    $scope.tourCompleted = function(){
        if(!$cookies.page) { return false }
        var tourCookie = $cookies.page;
        tourCookie = JSON.parse(tourCookie);
        return !!(tourCookie.ps && tourCookie.ps == true)
    };

    $scope.tourComplete = function(){
        var tourCookie = $cookies.page;
        if(!tourCookie) {
            tourCookie = { ps: true };
        }else{
            tourCookie = JSON.parse(tourCookie);
            if(!tourCookie.ps) { tourCookie['ps'] = false; }
            tourCookie['ps'] = true;
        }
        $cookies.page =  JSON.stringify(tourCookie);
    };

    $scope.currentStep = $scope.tourCompleted() ?  -1 : (parseInt($cookies.step) || 0);

    $scope.exitTour = function(){
        $scope.currentStep = -1;
    };

    $scope.postStepCallback = function() {
        $cookies.step =  parseInt($scope.currentStep);
    };

    /* Tour Function End */

    /* Load Queue Function Begin */

    $scope.qoffset = 0;
    $scope.qlimit = 10;
    $scope.qtotal = 0;
    $scope.scheduledCampaigns = [];
    $scope.isQBusy = false;
    $scope.loadQueue = true;
    var qLists;
    $scope.loadMoreQueue = function(){
        if($scope.isQBusy === true) return;
        $scope.isQBusy = true;
        $http.get('/power_share/scheduled_campaigns?offset='+$scope.qoffset+'&limit='+$scope.qlimit)
            .success(function(data){
                qLists = data;
                if( qLists.length > 0 ){
                    for(var x=0; x< qLists.length; x++){
                        $scope.scheduledCampaigns.push(qLists[x]);
                    }
                    $scope.qoffset += qLists.length;
                }
                $scope.qtotal += qLists.length;
                $scope.loadQueue = false;
                $scope.isQBusy = false;
            });
    };

    var channel = dispatcher.subscribe('scheduled_campaigns');
    channel.bind('scheduled_campaigns', function(campaign) {
        if (campaign.user_id == $("#socket-id").val()){
            $scope.scheduledCampaigns  = _.without($scope.scheduledCampaigns , _.findWhere($scope.scheduledCampaigns , {campaign_id: campaign.campaign_id}));
        }
    });

    /* Load Queue Function End */

    $scope.change = function(event){
        if(event.keyCode == 32 || event.keyCode == 13){
            $scope.charCount = 140;
            if(_.isUndefined($scope.power.content)) {
                $scope.power.content = '';
                $scope.ogmetaData = {};
                $scope.tmetaData = {};
            }else if(!_.isEmpty($scope.form.shareForm.content)){
                $scope.form.shareForm.content.$error.clientMessage = '';
                if(!_.isEmpty($scope.ogmetaData.image)) { $scope.charCount = $scope.charCount - 23;}
                $scope.charCount = $scope.charCount - $scope.power.content.length;
            }
            if($scope.isEmptyObject($scope.ogmetaData)) { $scope.metaData = false; }
            $scope.livePreview($scope.power.content);
        }
    };

    $scope.longUrls = [];
    $scope.livePreview = function(value){
        if(value && value.match(/(?:(ftp|http|https):\/\/)(\w*:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&&#37;@!\-\/]))?/g)){
            var previewUrl = value.match(/(?:(ftp|http|https):\/\/)(\w*:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&&#37;@!\-\/]))?/g);
            var powerShare = {};
            powerShare["power_share"] = {};
            $scope.previewUrl = powerShare["power_share"]["url"] = _.last(previewUrl);
            $scope.metaLoad = true;
            if($scope.previewUrl != "http://inquir.ly/1HFSuj7"){
                $scope.share_url = $scope.previewUrl;
                $http.post('/power_share/fetch_meta_data', powerShare).success(function(data, status, headers, config) {
                    $scope.tmetaData = data.twitter;
                    $scope.ogmetaData = data.open_graph;
                    $scope.longUrls.push(data.long_url);
                    if(!_.isEmpty($scope.ogmetaData) || !_.isEmpty($scope.tmetaData)) { $scope.metaData = true; }
                    $scope.metaLoad = false;
                    if(!_.isUndefined(data.open_graph.title)){
                        $scope.power.content = data.open_graph.title +' '+ $scope.power.content.replace($scope.previewUrl, "http://inquir.ly/1HFSuj7");
                    }else{
                        $scope.power.content = $scope.power.content.replace($scope.previewUrl, "http://inquir.ly/1HFSuj7");
                    }
                    if(_.isUndefined($scope.power.emailSubject) || _.isEmpty($scope.power.emailSubject)){ $scope.power.emailSubject = $scope.metaData ? $scope.ogmetaData.title  : 'Power Share'; }
                });
            }else{
                $scope.metaLoad = false;
                $scope.metaData = true;
            }
        }
        if(_.isEmpty(value)){ $scope.uploadPhoto = false }
    };

    $scope.closeMetaPreview = function(){
        $scope.metaData = false;
        $scope.ogmetaData = {};
        $scope.tmetaData = {};
    };

    /* Add Dummy short URL */
    function addShortUrl(value){
        var urlPattern = /(http|ftp|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?/gi;
        if(!_.isUndefined(value) && !_.isNull(value)){
            var urls = value.match(urlPattern);
            var lastUrl = _.last(urls);
            return value.replace(lastUrl, 'http://inquir.ly/1HFSuj7');
        }else{
            return value;
        }
    }

    /* Add Photo */
    $scope.uploadPhoto = false;
    $scope.onFileSelect = function(files) {
        var file = files[0];
        $scope.image_file = file;
        if(file && file.type.match(/^image\/.*/)){
            if (file.size> 3000000) {
                $scope.alerts = [{ type: 'danger', msg: "Filesize has exceeded it max limit of 3MB.Please upload a smaller file." }];
                return true;
            }
            fileReader.readAsDataUrl(file, $scope)
                .then(function(result) {
                    $scope.tmetaData.image = result;
                    $scope.ogmetaData.image = result;
                    $scope.uploadPhoto = true;
                    $scope.metaData= false;
                    $scope.charCount = $scope.charCount - 23;
            });
        }
    };

    /* Remove Photo */
    $scope.removeImage = function(){
        $scope.uploadPhoto = false;
        $scope.ogmetaData.image = null;
        $scope.tmetaData.image = null;
    };

    /* Preview */

    $scope.previewShare = function(data) {
        if($scope.allRemoved) { return; }
        $scope.previewContent = data;
        $scope.previewContent = addShortUrl($scope.previewContent);
        if(_.isUndefined($scope.previewContent)){ $scope.previewContent = '' }
        if(_.isUndefined($scope.power.emailSubject) || _.isEmpty($scope.power.emailSubject)){ $scope.power.emailSubject = $scope.metaData ? $scope.ogmetaData.title  : 'Power Share'; }

        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/home/previewDialog.html',
            controller: 'powerSharePreviewCtrl',
            scope: $scope,
            size: 'lg',
            resolve: {
                accounts: function(){
                    return  $scope.socialAccounts;
                }
            }
        });
        modalInstance.result.then(function (selectedItem) {
            $scope.selected = selectedItem;
        });
    };

    /* Preview on Queue and History */

    $scope.checkOnlyBeaconShared = function(location){
        var beacon = _.findWhere(location, {channel: "beacon"});
        return _.isUndefined(beacon) ? [] : beacon;
    };

    $scope.previewOnQueue = function(data,mobile_accounts,social_accounts,location_accounts){
        $scope.sms_contents = [];
        $scope.campaignData = data;
        $scope.content =  $scope.campaignData.share_content;
        if (!_.isUndefined($scope.campaignData.sms_content)){
             $scope.campaignData.sms_content.length > 160 ? $scope.sms_contents = $scope.campaignData.sms_content.match(/.{1,160}/g) : $scope.sms_contents.push($scope.campaignData.sms_content)
        }
        $scope.content = addShortUrl($scope.content);
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
        angular.forEach(mobile_accounts, function (accounts) {
            if(accounts.channel == 'sms')
                $scope.smsAccounts.push(accounts.id);
            else if(accounts.channel == 'email')
                $scope.emailAccounts.push(accounts.id);
        });

        $scope.beaconAccounts = [];
        $scope.qrCodeAccounts = [];
        angular.forEach(location_accounts, function (accounts) {
            if(accounts.channel == 'beacon')
                $scope.beaconAccounts.push(accounts.id);
            else if(accounts.channel == 'qrcode') {
                $scope.qrCodeAccounts.push(accounts.id);
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

    /* Inspire Me */
    $scope.inspireMe = function(){
        $scope.tags = $scope.default_tags;
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/home/flickDialog.html',
            controller: 'flickrCtrl',
            size: 'fs',
            resolve: {
                tags: function () {
                    return $scope.tags;
                }
            }
        });
        modalInstance.result.then(function (img_src) {
            $scope.tmetaData.image = img_src;
            $scope.ogmetaData.image = img_src;
            $scope.uploadPhoto = true;
            $scope.charCount = $scope.charCount - 23;
        }, function () {
        });
    };

    /* Remove queued List */
    $scope.clearQueue = function(){
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/home/clearQueueDialog.html',
            controller: 'queueCtrl',
            scope: $scope,
            resolve: {
                socials: function(){
                    return  $scope.socials;
                }
            }
        });
        modalInstance.result.then(function () {});
    };

    /* Load Social Accounts */

    $scope.splitSocialChannels = function(social_accounts){
        angular.forEach(social_accounts, function (account) {
            if (account.channel == "facebook")
                $scope.fbAccounts.push(account);
            else if(account.channel == "twitter")
                $scope.twAccounts.push(account);
            else if(account.channel == "linkedin")
                $scope.lnAccounts.push(account);
        });
        $scope.isLoading = false;
    };

    $scope.hideTwitter = function(){
        $scope.twOpened = false;
    };

    $scope.hideFacebook = function(){
        $scope.fbOpened = false;
    };

    $scope.hideLinkedin = function(){
        $scope.lnOpened = false;
    };

    $scope.hideEmail = function(){
        $scope.emailOpened = false;
    };

    $scope.hideSms = function(){
        $scope.smsOpened = false;
    };

    $scope.hideBeacon = function(){
        $scope.beaconOpened = false;
    };

    $scope.hideQrCode = function(){
        $scope.qrcodeOpened = false;
    };

    $scope.hideOpinify = function(){
        $scope.opinifyOpened = false;
    };
    // Facebook

    $scope.fbNames = [];

    $scope.fbOpened = false;
    $scope.setFbActive = function(slection, $event){
        $scope.twOpened = false;
        $scope.lnOpened= false;
        $scope.fbOpened = slection ? false : true;
    };

    $scope.isFbSelected = function(){
        if($scope.fbOpened){
            return 'active'
        }
        return false;
    };

    $scope.isFBChecked = function (id) {
        if (_.contains($scope.facebookList, id)) {
            return 'fa fa-check pull-right';
        }
        return false;
    };

    $scope.selectAllFacebook = function(){
        angular.forEach($scope.fbAccounts, function (account) {
            if(!_.contains($scope.facebookList, account.id)){
                $scope.addAccount(account);
            }
        });
        getReach();
    };

    $scope.removeAllFacebook = function(){
        $scope.facebookList = [];
        $scope.fbNames = [];
        $scope.checkAllAccountRemoved();
        getReach();
    };

    // Twitter

    $scope.twNames = [];
    $scope.twOpened = false;
    $scope.setTwActive = function(slection, $event){
        $scope.fbOpened = false;
        $scope.lnOpened= false;
        $scope.twOpened = slection ? false : true;
    };

    $scope.isTwSelected = function(){
        if($scope.twOpened){
            return 'active'
        }
        return false;
    };

    $scope.isTWChecked = function (id) {
        if (_.contains($scope.twitterList, id)) {
            return 'fa fa-check pull-right';
        }
        return false;
    };

    $scope.selectAllTwitter = function(){
        angular.forEach($scope.twAccounts, function (account) {
            if(!_.contains($scope.twitterList, account.id)){
                $scope.addAccount(account);
            }
        });
        getReach();
    };

    $scope.removeAllTwitter = function(){
        $scope.twitterList = [];
        $scope.twNames = [];
        $scope.checkAllAccountRemoved();
        getReach();
    };

    // LinkedIn


    $scope.lnNames = [];
    $scope.lnOpened = false;
    $scope.setLnActive = function(slection, $event){
        $scope.fbOpened = false;
        $scope.twOpened = false;
        $scope.lnOpened = slection ? false : true;
    };

    $scope.isLnSelected = function(){
        if($scope.lnOpened){
            return 'active'
        }
        return false;
    };

    $scope.isLnChecked = function (id) {
        if (_.contains($scope.linkedinList, id)) {
            return 'fa fa-check pull-right';
        }
        return false;
    };

    $scope.selectAllLinkedIn = function(){
        angular.forEach($scope.lnAccounts, function (account) {
            if(!_.contains($scope.linkedinList, account.id)){
                $scope.addAccount(account);
            }
        });
        getReach();
    };

    $scope.removeAllLinkedIn = function(){
        $scope.linkedinList = [];
        $scope.lnNames = [];
        $scope.checkAllAccountRemoved();
        getReach();
    };


    // Load Mobile Accounts
    $scope.defaultSmsGroup = 0;
    $scope.defaultEmailGroup = 0;
    $scope.defaultOpinifyGroup = 0;
    $scope.splitMobileChannels = function(mobile_accounts){
        angular.forEach(mobile_accounts, function (account) {
            if (account.channel == "sms"){
                if(account.name == 'All Customers'){ $scope.defaultSmsGroup = account.id }
                $scope.smsGroups.push(account);
            }else if(account.channel == "email"){
                if(account.name == 'All Customers'){ $scope.defaultEmailGroup = account.id }
                $scope.emailGroups.push(account);
            }else if(account.channel == "opinify"){
                if(account.name == 'All Customers'){ $scope.defaultOpinifyGroup = account.id }
                $scope.opinifyGroups.push(account);
            }
        });
    };

    // Email

    $scope.emailGroupNames = [];

    $scope.emailOpened = false;
    $scope.setEmailActive = function(slection, $event){
        $scope.twOpened = false;
        $scope.lnOpened= false;
        $scope.fbOpened= false;
        $scope.opinifyOpened = false;
        $scope.emailOpened = slection ? false : true;
    };

    $scope.isEmailSelected = function(){
        if($scope.emailOpened){
            return 'active'
        }
        return false;
    };

    $scope.isEmailChecked = function (id) {
        if (_.contains($scope.emailList, id)) {
            return 'fa fa-check pull-right';
        }
        return false;
    };

    $scope.unCheckEmailAll = function(id) {
        if (_.contains($scope.emailList, $scope.defaultEmailGroup)) {
            $scope.emailList = [];
            $scope.emailList.push($scope.defaultEmailGroup);
            return 'fa fa-check pull-right';
        }
        return false;
    };

    $scope.selectAllEmailGroup = function(){
        var allCustomers = _.findWhere($scope.emailGroups, {id: $scope.defaultEmailGroup});
        $scope.addAccount(allCustomers);
        getReach();
    };

    $scope.removeAllEmailGroup = function(){
        $scope.emailList = [];
        $scope.emailGroupNames = [];
        $scope.checkAllAccountRemoved();
        getReach();
    };

    // SMS

    $scope.smsGroupNames = [];

    $scope.smsOpened = false;
    $scope.setSmsActive = function(slection, $event){
        $scope.twOpened = false;
        $scope.lnOpened= false;
        $scope.fbOpened= false;
        $scope.emailOpened = false;
        $scope.opinifyOpened = false;
        $scope.smsOpened = slection ? false : true;
    };

    $scope.isSmsSelected = function(){
        if($scope.smsOpened){
            return 'active'
        }
        return false;
    };

    $scope.isSmsChecked = function (id) {
        if (_.contains($scope.smsList, id)) {
            return 'fa fa-check pull-right';
        }
        return false;
    };

    $scope.unCheckSmsAll = function(id) {
        if (_.contains($scope.smsList, $scope.defaultSmsGroup)) {
            $scope.smsList = [];
            $scope.smsList.push($scope.defaultSmsGroup);
            return 'fa fa-check pull-right';
        }
        return false;
    };

    $scope.selectAllSmsGroup = function(){
        var allCustomers = _.findWhere($scope.smsGroups, {id: $scope.defaultSmsGroup});
        $scope.addAccount(allCustomers);
        getReach();
    };

    $scope.removeAllSmsGroup = function(){
        $scope.smsList = [];
        $scope.smsGroupNames = [];
        $scope.checkAllAccountRemoved();
        getReach();
    };

    // Opinify Channel

    $scope.opinifyGroupNames = [];

    $scope.opinifyOpened = false;
    $scope.setOpinifyActive = function(slection, $event){
        $scope.twOpened = false;
        $scope.lnOpened= false;
        $scope.fbOpened= false;
        $scope.emailOpened = false;
        $scope.opinifyOpened = slection ? false : true;
    };

    $scope.isOpinifySelected = function(){
        if($scope.opinifyOpened){
            return 'active'
        }
        return false;
    };

    $scope.isOpinifyChecked = function (id) {
        if (_.contains($scope.opinifyList, id)) {
            return 'fa fa-check pull-right';
        }
        return false;
    };

    $scope.unCheckOpinifyAll = function(id) {
        if (_.contains($scope.opinifyList, $scope.defaultOpinifyGroup)) {
            $scope.opinifyList = [];
            $scope.opinifyList.push($scope.defaultOpinifyGroup);
            return 'fa fa-check pull-right';
        }
        return false;
    };

    $scope.selectAllOpinifyGroup = function(){
        var allCustomers = _.findWhere($scope.opinifyGroups, {id: $scope.defaultOpinifyGroup});
        $scope.addAccount(allCustomers);
        getReach();
    };

    $scope.removeAllOpinifyGroup = function(){
        $scope.opinifyList = [];
        $scope.opinifyGroupNames = [];
        $scope.checkAllAccountRemoved();
        getReach();
    };


    // Beacon channels

    $scope.beaconOpened = false;
    $scope.beaconNames = [];
    $scope.splitLocationChannels = function(location_accounts){
        angular.forEach(location_accounts, function (account) {
            if (account.channel == "beacon"){
                $scope.beacons.push(account);
            }else if(account.channel == "qrcode"){
                $scope.qrcodes.push(account);
            }
        });
    };

    $scope.setBeaconActive = function(slection, $event){
        $scope.fbOpened = false;
        $scope.twOpened = false;
        $scope.smsOpened= false;
        $scope.lnOpened = false;
        $scope.emailOpened = false;
        $scope.beaconOpened = slection ? false : true;
    };

    $scope.isBeaconSelected = function(){
        if($scope.beaconOpened){
            return 'active'
        }
        return false;
    };

    $scope.isBeaconChecked = function (id) {
        if (_.contains($scope.beaconsList, id)) {
            return 'fa fa-check pull-right';
        }
        return false;
    };

    $scope.selectAllBeacon = function(){
        angular.forEach($scope.beacons, function (account) {
            if(!_.contains($scope.beaconsList, account.id)){
                $scope.addAccount(account);
            }
        });
        getReach();
    };

    $scope.removeAllBeacon = function(){
        $scope.beaconsList = [];
        $scope.beaconNames = [];
        $scope.checkAllAccountRemoved();
        getReach();
    };

    // QR Code Channels

    $scope.qrcodeOpened = false;
    $scope.qrcodeNames = [];
    $scope.setQrCodeActive = function(slection, $event){
        $scope.fbOpened = false;
        $scope.twOpened = false;
        $scope.smsOpened= false;
        $scope.lnOpened = false;
        $scope.emailOpened = false;
        $scope.beaconOpened = false;
        $scope.qrcodeOpened = slection ? false : true;
    };

    $scope.isQrCodeSelected = function(){
        if($scope.qrcodeOpened){
            return 'active'
        }
        return false;
    };

    $scope.isQrCodeChecked = function (id) {
        if (_.contains($scope.qrcodesList, id)) {
            return 'fa fa-check pull-right';
        }
        return false;
    };

    $scope.selectAllQrCode = function(){
        angular.forEach($scope.qrcodes, function (account) {
            if(!_.contains($scope.qrcodesList, account.id)){
                $scope.addAccount(account);
            }
        });
        getReach();
    };

    $scope.removeAllQrCode = function(){
        $scope.qrcodesList = [];
        $scope.qrcodeNames = [];
        $scope.checkAllAccountRemoved();
        getReach();
    };


    $scope.checkAllAccountRemoved = function(){
        if($scope.twitterList.length == 0 && $scope.facebookList.length == 0 && $scope.linkedinList.length == 0
            && $scope.smsList.length == 0 && $scope.emailList.length == 0 && $scope.beaconsList.length == 0 &&
            $scope.qrcodesList.length == 0 && $scope.opinifyList.length == 0){
            $scope.addedSocialAccount = [];
            $scope.addedMobileAccount = [];
            $scope.addedLocationAccount = [];
            $scope.allRemoved = true;
        }
    };

    $scope.allRemoved = true;
    $scope.beaconOnlySelected = false;
    $scope.addAccount = function(account) {
        if(account.class_name == "UserSocialChannel"){
            var sIndex = $scope.addedSocialAccount.indexOf(account.id);
            if(sIndex == -1){
                $scope.addedSocialAccount.push(account.id);
            }else{
                $scope.addedSocialAccount.splice(sIndex, 1);
            }
            socialAccountSelection(account);
        }else if(account.class_name == "UserMobileChannel"){
            var mIndex = $scope.addedMobileAccount.indexOf(account.id);
            if(mIndex == -1){
                $scope.addedMobileAccount.push(account.id);
            }else{
                $scope.addedMobileAccount.splice(mIndex, 1);
            }
            mobileAccountSelection(account);
        }else{
            var lIndex = $scope.addedLocationAccount.indexOf(account.id);
            if(lIndex == -1){
                $scope.addedLocationAccount.push(account.id);
            }else{
                $scope.addedLocationAccount.splice(lIndex, 1);
            }
            locationAccountSelection(account);
        }
        if ($scope.addedSocialAccount.length >= 1 || $scope.addedMobileAccount.length >= 1 || $scope.addedLocationAccount.length >= 1) { $scope.allRemoved = false }

        function allAccountsRemoved(){
            return $scope.twitterList.length == 0 && $scope.facebookList.length == 0 &&  $scope.linkedinList.length == 0 && $scope.emailList.length == 0
            && $scope.smsList.length == 0 && $scope.qrcodesList.length == 0 && $scope.opinifyList.length == 0
        }

        if (allAccountsRemoved() && $scope.beaconsList.length == 0){
            $scope.allRemoved = true;
        }

        // Beacon Only Selected
        $scope.beaconOnlySelected = allAccountsRemoved() && $scope.beaconsList.length > 0 ? true : false
    };

    function socialAccountSelection(account){
        if(account.channel == 'twitter'){
            var tIndex = $scope.twitterList.indexOf(account.id);
            if( tIndex == -1){
                $scope.twitterList.push(account.id);
            }else{
                $scope.twitterList.splice(tIndex,1);
            }
            twNames(account)

        }else if(account.channel == 'facebook'){
            var fIndex = $scope.facebookList.indexOf(account.id);
            if( fIndex == -1){
                $scope.facebookList.push(account.id);
            }else{
                $scope.facebookList.splice(fIndex,1);
            }
            fbNames(account);

        }else if(account.channel == 'linkedin'){
            var lIndex = $scope.linkedinList.indexOf(account.id);
            if( lIndex == -1){
                $scope.linkedinList.push(account.id);
            }else{
                $scope.linkedinList.splice(lIndex,1);
            }
            lnNames(account);
        }

        getReach();
    }

    function fbNames(account) {
        if(!_.contains($scope.fbNames, account)){
            $scope.fbNames.push(account)
        }else{
            $scope.fbNames = _.without($scope.fbNames, _.findWhere($scope.fbNames, {id: account.id}));
        }
        var fb = _.last($scope.fbNames);
        if(!_.isUndefined(fb)){
            $scope.facebookName = fb.name;
            $scope.facebookProfile = fb.profile_image;
        }
    }

    function twNames(account) {
        if(!_.contains($scope.twNames, account)){
            $scope.twNames.push(account)
        }else{
            $scope.twNames = _.without($scope.twNames, _.findWhere($scope.twNames, {id: account.id}));
        }
        var tw = _.last($scope.twNames);
        if(!_.isUndefined(tw)){
            $scope.twitterName = tw.name;
            $scope.twitterProfile = tw.profile_image;
        }
    }

    function lnNames(account) {
        if(!_.contains($scope.lnNames, account)){
            $scope.lnNames.push(account)
        }else{
            $scope.lnNames = _.without($scope.lnNames, _.findWhere($scope.lnNames, {id: account.id}));
        }
        var ln = _.last($scope.lnNames);
        if(!_.isUndefined(ln)){
            $scope.linkedinName = ln.name;
            $scope.linkedinProfile = ln.profile_image;
        }
    }

    function mobileAccountSelection(account){
        if(account.channel == 'sms'){
            var tIndex = $scope.smsList.indexOf(account.id);
            if( tIndex == -1){
                $scope.smsList.push(account.id);
            }else{
                $scope.smsList.splice(tIndex,1);
            }
            smsNames(account);
            $scope.unCheckSmsAll();
        }else if(account.channel == 'email'){
            var fIndex = $scope.emailList.indexOf(account.id);
            if( fIndex == -1){
                $scope.emailList.push(account.id);
            }else{
                $scope.emailList.splice(fIndex,1);
            }
            emailNames(account);
            $scope.unCheckEmailAll();
        }else if(account.channel == 'opinify'){
            var oIndex = $scope.opinifyList.indexOf(account.id);
            if( oIndex == -1){
                $scope.opinifyList.push(account.id);
            }else{
                $scope.opinifyList.splice(oIndex,1);
            }
            opinifyNames(account);
            $scope.unCheckOpinifyAll();
        }
        getReach();
    }

    function emailNames(account) {
        if(!_.contains($scope.emailGroupNames, account)){
            $scope.emailGroupNames.push(account)
        }else{
            $scope.emailGroupNames = _.without($scope.emailGroupNames, _.findWhere($scope.emailGroupNames, {id: account.id}));
        }
        if(!_.isUndefined(_.findWhere($scope.emailGroupNames, {name: "All Customers"}))) {
            var obj = _.findWhere($scope.emailGroupNames, {name: "All Customers"});
            $scope.emailGroupNames = [];
            $scope.emailGroupNames.push(obj);
        }
    }

    function smsNames(account) {
        if(!_.contains($scope.smsGroupNames, account)){
            $scope.smsGroupNames.push(account)
        }else{
            $scope.smsGroupNames = _.without($scope.smsGroupNames, _.findWhere($scope.smsGroupNames, {id: account.id}));
        }
        if(!_.isUndefined(_.findWhere($scope.smsGroupNames, {name: "All Customers"}))) {
            var obj = _.findWhere($scope.smsGroupNames, {name: "All Customers"});
            $scope.smsGroupNames = [];
            $scope.smsGroupNames.push(obj);
        }
    }

    function opinifyNames(account){
        if(!_.contains($scope.opinifyGroupNames, account)){
            $scope.opinifyGroupNames.push(account)
        }else{
            $scope.opinifyGroupNames = _.without($scope.opinifyGroupNames, _.findWhere($scope.opinifyGroupNames, {id: account.id}));
        }
        if(!_.isUndefined(_.findWhere($scope.opinifyGroupNames, {name: "All Customers"}))) {
            var obj = _.findWhere($scope.opinifyGroupNames, {name: "All Customers"});
            $scope.opinifyGroupNames = [];
            $scope.opinifyGroupNames.push(obj);
        }
    }

    function locationAccountSelection(account){
        if(account.channel == 'beacon'){
            var tIndex = $scope.beaconsList.indexOf(account.id);
            if( tIndex == -1){
                $scope.beaconsList.push(account.id);
            }else{
                $scope.beaconsList.splice(tIndex,1);
            }
            beaconNames(account);
        }else if(account.channel == 'qrcode'){
            var qIndex = $scope.qrcodesList.indexOf(account.id);
            if( qIndex == -1){
                $scope.qrcodesList.push(account.id);
            }else{
                $scope.qrcodesList.splice(qIndex,1);
            }
            qrcodesNames(account);
        }
        getReach();
    }

    function beaconNames(account) {
        if(!_.contains($scope.beaconNames, account)){
            $scope.beaconNames.push(account)
        }else{
            $scope.beaconNames = _.without($scope.beaconNames, _.findWhere($scope.beaconNames, {id: account.id}));
        }
    }

    function qrcodesNames(account) {
        if(!_.contains($scope.qrcodeNames, account)){
            $scope.qrcodeNames.push(account)
        }else{
            $scope.qrcodeNames = _.without($scope.qrcodeNames, _.findWhere($scope.qrcodeNames, {id: account.id}));
        }
        var qr_code = _.last($scope.qrcodeNames);
        if(!_.isUndefined(qr_code)){
            $scope.qrCodeImage = qr_code.image;
        }
    }

    /* Re-Post Function Begin */

    $scope.updatePostInfo = function(post){
        if(!_.isUndefined(post) && !_.isNull(post)){
            var postInfo = post.post_info;
            $scope.power.content = addShortUrl(postInfo.campaign_data.share_content);
            if(!_.isEmpty(postInfo.campaign_data.og_meta_data)){
                $scope.ogmetaData = postInfo.campaign_data.og_meta_data;
                $scope.metaData = true;
                $scope.share_url = postInfo.campaign_data.og_meta_data.url;
            }
            if(!_.isEmpty(postInfo.campaign_data.tw_meta_data)){
                $scope.tmetaData = postInfo.campaign_data.tw_meta_data;
                $scope.metaData = true;
            }

            if(!_.isEmpty(postInfo.campaign_data.campaign_media_url)){
                $scope.tmetaData.image = postInfo.campaign_data.campaign_media_url;
                $scope.ogmetaData.image = postInfo.campaign_data.campaign_media_url;
                $scope.uploadPhoto = true;
                $scope.metaData = false;
            }

            angular.forEach(postInfo.mobile_accounts, function (account) {
                $scope.addAccount(account);
            });

            angular.forEach(postInfo.social_accounts, function (account) {
                $scope.addAccount(account);
            });
        }
    };

    var postParams = $stateParams.postParams;
    $scope.updatePostInfo(postParams);

    /* Re-Post Function End */


    /* Edit Post Function Begin */

    $scope.editScheduledPost = function(post){
        $("html, body").animate({ scrollTop: "10px" });
        var scheduledPost = {post_info: post };
        $scope.updatePostInfo(scheduledPost);
    };

    /* Edit Post Function End */

    /* Schedule */
    $scope.dateTimeNow = function() {
        $scope.date = new Date();
    };
    $scope.dateTimeNow();

    $scope.toggleMinDate = function() {
        $scope.minDate = $scope.minDate ? null : new Date();
    };

    $scope.maxDate = new Date('2014-06-22');
    $scope.toggleMinDate();

    $scope.dateOptions = {
        startingDay: 1,
        showWeeks: false
    };

    // Disable weekend selection
    $scope.disabled = function(calendarDate, mode) {
        return mode === 'day' && ( calendarDate.getDay() === 0 || calendarDate.getDay() === 6 );
    };

    $scope.hourStep = 1;
    $scope.minuteStep = 15;

    $scope.timeOptions = {
        hourStep: [1, 2, 3],
        minuteStep: [1, 5, 10, 15, 25, 30]
    };

    $scope.showMeridian = true;
    $scope.timeToggleMode = function() {
        $scope.showMeridian = !$scope.showMeridian;
    };

    $scope.$watch("date", function(value) {
    }, true);

    $scope.resetHours = function() {
        $scope.date.setHours(1);
    };
    $scope.addQueue = false;
    $scope.addToQueue = function(date){
        $scope.addQueue = true;
        $scope.powerShare(date,false);
    };

    /* Power Share */
    $scope.isProcessing = false;
    $scope.shareButton = "POWERSHARE IT!";
    $scope.powerShare = function(date,share_now){
        $scope.scheduleOn = date.toUTCString();
        var clientResponse = {};
        $scope.valid = !_.isEmpty($scope.power.content) || !_.isEmpty($scope.ogmetaData.image);
        $scope.invalid = _.isEmpty($scope.power.content) && _.isEmpty($scope.ogmetaData.image);
        $scope.noAccounts = $scope.socialAccounts.length == 0 && $scope.mobileAccounts.length == 0 && $scope.locationAccounts.length == 0;
        if($scope.invalid){
            clientResponse.content = 'Please enter content or add image for your post';
        }else if($scope.valid && $scope.isinValidDate){
            clientResponse.content = 'Please enter a valid date';
        }else if($scope.valid && $scope.noAccounts){
            clientResponse.content = 'Please configure your social/mobile account(s)';
        }else if($scope.valid && $scope.allRemoved){
            clientResponse.content = 'You should select at-least one social/mobile account(s)';
        }
        else{
            clientResponse.content =  'VALID';
        }

        for (var fieldName in clientResponse) {
            var message = clientResponse[fieldName];
            var clientMessage = $parse('form.shareForm.'+fieldName+'.$error.clientMessage');
            if (message == "VALID") {
                $scope.isProcessing = true;
                $scope.shareButton = "SHARING ";
                $scope.form.shareForm.$setValidity(fieldName, true, $scope.form.shareForm);
                clientMessage.assign($scope, undefined);
                $scope.onShare = true;
                var share_details = {};
                share_details["content"] = $scope.power.content;
                share_details["og_meta_data"] = $scope.ogmetaData;
                share_details["tw_meta_data"] = $scope.tmetaData;
                share_details["share_url"] = $scope.share_url;
                share_details["social_channels"] = socialList();
                share_details["mobile_channels"] = mobileList();
                share_details["location_channels"] = locationList();
                share_details["campaign_type"] = "powershare";
                share_details["schedule_on"] = $scope.scheduleOn;
                share_details["is_upload_image"] = $scope.uploadPhoto;
                share_details["email_subject"] = $scope.power.emailSubject;
                share_details["email_sender"] = $scope.power.emailSender;
                share_details["add_to_queue"] = $scope.addQueue;
                share_details["share_now"] = share_now;
                if($scope.image_file){
                    var file = $scope.image_file;
                    var blob = new Blob([file], {type: 'image/png'});
                    var uploadFile = new File([blob], file.name);

                    $scope.upload = Upload.upload({
                        url: '/power_share/share_content',
                        method: 'POST',
                        headers: {
                            'X-CSRF-Token': $('meta[name=csrf-token]').attr('content'),
                            'Content-Type': file.type
                        },
                        withCredentials: true,
                        fields: {
                            'power_share[content]': $scope.power.content,
                            'power_share[og_meta_data]': '',
                            'power_share[tw_meta_data]': '',
                            'power_share[share_url]': $scope.share_url,
                            'power_share[social_channels]': socialList(),
                            'power_share[mobile_channels]': mobileList(),
                            'power_share[location_channels]': locationList(),
                            'power_share[campaign_type]': 'powershare',
                            'power_share[schedule_on]': $scope.scheduleOn,
                            'power_share[is_upload_image]': $scope.uploadPhoto,
                            'power_share[email_subject]': $scope.power.emailSubject,
                            'power_share[email_sender]': $scope.power.emailSender,
                            'power_share[add_to_queue]': $scope.addQueue,
                            'power_share[share_now]': share_now
                        },
                        file: uploadFile,
                        fileFormDataName: 'power_share[image_path]'
                    }).success(function (data, status, headers, config) {
                            successResponse(data);
                        });
                }else{
                    $http.post('/power_share/share_content', share_details).
                        success(function(data, status, headers, config) {
                            successResponse(data);
                        })
                }
            }
            else {
                $scope.form.shareForm.$setValidity(fieldName, false, $scope.form.shareForm);
                clientMessage.assign($scope, clientResponse[fieldName]);
            }
        }

        function socialList(){
            $scope.socialList = [];
            if($scope.twitterList.length > 0){ $scope.socialList = $scope.socialList.concat.apply($scope.socialList,$scope.twitterList); }
            if($scope.facebookList.length > 0){ $scope.socialList = $scope.socialList.concat.apply($scope.socialList,$scope.facebookList); }
            if($scope.linkedinList.length > 0){ $scope.socialList =  $scope.socialList.concat.apply($scope.socialList,$scope.linkedinList); }
            return $scope.socialList;
        }

        function mobileList(){
            $scope.mobileList = [];
            if($scope.smsList.length > 0){ $scope.mobileList = $scope.mobileList.concat.apply($scope.mobileList,$scope.smsList); }
            if($scope.emailList.length > 0){ $scope.mobileList = $scope.mobileList.concat.apply($scope.mobileList,$scope.emailList); }
            if($scope.opinifyList.length > 0) { $scope.mobileList = $scope.mobileList.concat.apply($scope.mobileList,$scope.opinifyList); }
            return $scope.mobileList;
        }

        function locationList(){
            $scope.locationList = [];
            if($scope.beaconsList.length > 0){ $scope.locationList = $scope.locationList.concat.apply($scope.locationList,$scope.beaconsList); }
            if($scope.qrcodesList.length > 0){ $scope.locationList = $scope.locationList.concat.apply($scope.locationList,$scope.qrcodesList); }
            return $scope.locationList;
        }
    };

    function successResponse(data){
        if(data.status == 200) { $scope.alerts = [{ type: 'success', msg: data["success"] }]; }
        if(data.status == 400) { $scope.alerts = [{ type: 'danger', msg: "Unable to share your post." }];}
        $scope.image_file = '';
        $scope.isProcessing = false;
        $scope.uploadPhoto = false;
        $scope.shareButton = "POWERSHARE IT!";
        $scope.power.content =  '';
        $scope.power.emailSubject = '';
        $scope.ogmetaData = {};
        $scope.tmetaData = {};
        $scope.onShare = false;
        $scope.metaData = false;
        $scope.share_url = null;
        $scope.channelInit();
        $scope.allRemoved = true;
        getReach();
        Onboarding.update_status($scope);
    }

    $scope.closeAlert = function(index) {
        $scope.alerts.splice(index, 1);
    };

    $scope.ReShare = false;
    $scope.sharedPost = 0;
    $scope.shareNowBtn = "Share Now";
    $scope.reShareNow = function(campaign_id,date,share_now){
        if(share_now){
            $scope.sharedPost = campaign_id;
        }
        $scope.scheduleOn = date.toUTCString();
        $scope.ReShare = true;
        var share_details = {};
        share_details["id"] = campaign_id;
        share_details["schedule_on"] = $scope.scheduleOn;
        share_details["share_now"] = share_now;
        $http.post('/power_share/reschedule_share', share_details).
            success(function(data, status, headers, config) {
                $scope.sharedPost = 0;
                if(data.is_shared){
                    $scope.scheduledCampaigns = _.without($scope.scheduledCampaigns, _.findWhere($scope.scheduledCampaigns, {campaign_id: campaign_id }));
                }else{
                    $scope.scheduledCampaigns = data.campaigns_list;
                }
                $scope.shareNowBtn = "Share Now";
                $scope.ReShare = false;
        })
    };

    $scope.isQueueShared = function(campaign_id){
        if ($scope.sharedPost ==  campaign_id) {
            $scope.shareNowBtn = "Sharing...";
            return 'fa fa-refresh fa-spin';
        }else{
            $scope.shareNowBtn = "Share Now";
        }
        return false;
    };

    $scope.schedule = function(campaign_id){
        $scope.dateTimeNow();
        $scope.campaign_id = campaign_id;
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/home/schedule.html',
            controller: 'scheduleCtrl',
            scope: $scope,
            size: 'lg',
            resolve: {
                campaign_id: function () {
                    return $scope.campaign_id;
                },
                share_form: function () {
                    return $scope.form.shareForm;
                }
            }
        });
        modalInstance.result.then(function (id) {
        }, function () {
        });
    };

    /* Remove Post */

    $scope.removePost = function(campaign_id){
        $scope.campaign_id = campaign_id;
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/home/removePost.html',
            controller: 'removeQueueCtrl',
            scope: $scope,
            resolve: {
                campaign_id: function(){
                    return  $scope.campaign_id;
                }
            }
        });
        modalInstance.result.then(function (result) {
            $scope.scheduledCampaigns = _.without($scope.scheduledCampaigns, _.findWhere($scope.scheduledCampaigns, {campaign_id: result }));
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

    /* Get Reach */
    $scope.chartData = {};
    $scope.reaches = [];

    function getReach(){
       var channels = {};
       channels["fb_accounts"] =  $scope.facebookList;
       channels["tw_accounts"] =  $scope.twitterList;
       channels["ln_accounts"] =  $scope.linkedinList;
       channels["email_accounts"] =  $scope.emailList;
       channels["sms_accounts"] =  $scope.smsList;
       channels["beacon_accounts"] =  $scope.beaconsList;
       channels["qrcode_accounts"] = $scope.qrcodesList;
       channels["opinify_accounts"] = $scope.opinifyList;
       $http.post("/power_share/get_reach", channels).success(function(data, status, headers, config) {
            if (data.current_reach['sms'] == "0" && data.current_reach['email'] == "0"
                && data.current_reach['tw'] == "0" && data.current_reach['fb'] == "0" && data.current_reach['ln'] == "0" && data.current_reach['op'] == "0"){
                $scope.chartData = {};
            }else{
                $scope.chartData = {
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
                        },
                        {
                            "label":"Opinify",
                            "color":"#82C7CA",
                            "reach": data.current_reach['op']
                        }
                    ]
                }
            }
           totalReach(data.reaches)
        });
    }

    function totalReach(reaches){
        $scope.totalReach = 0;
        angular.forEach(reaches, function (obj) { $scope.totalReach += obj.value;});
        $scope.reaches = reaches;
    }

    $scope.isEmptyObject = function(obj) {
        return angular.equals({}, obj);
    };

    $scope.home_location = $location;
    $scope.$watch('home_location.search()', function(search) {
        if(!_.isEmpty(search) && !_.isUndefined(search.post_id) && !_.isNull(search.post_id)){
            $scope.postNotify(search.post_id);
        }
    });

    $scope.postNotify = function(post_id){
        $http.post('/power_share/post_info',{post_id: post_id}).success(function(data) {
            $scope.postCount = data.length;
            $scope.postCampaign = data[0];
            if( $location.path() == '/home/index'){
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
});

InquirlyApp.controller('powerSharePreviewCtrl', function($scope,$http,$modalInstance,accounts) {
    $scope.smsContents= [];
    var dummyLink = 'http://inquir.ly/1HFSuj7';
    $scope.previewContent.length > 160 ? $scope.smsContents = $scope.previewContent.match(/.{1,160}/g) : $scope.smsContents.push($scope.previewContent);
    $scope.smsContents = _.filter($scope.smsContents, function(content){ return content != ''; });
    var content;
    if(!$scope.metaData && $scope.ogmetaData.image && _.isEmpty($scope.previewContent)){
        $scope.smsContents.push(dummyLink)
    }else if(!$scope.metaData && $scope.ogmetaData.image && !_.isEmpty($scope.previewContent)){
        $scope.smsContents = [];
        content = $scope.previewContent + ' ' + dummyLink;
        $scope.smsContents.push(content)
    }else if($scope.metaData && !_.isEmpty($scope.previewContent)){
        $scope.smsContents = [];
        if($scope.previewContent == dummyLink){
            content = $scope.ogmetaData.title + ' ' + dummyLink;
        }else{
            content = $scope.previewContent;
        }
        $scope.smsContents.push(content);
    }

    defaultState();

    $scope.showPreview = function(channel){
        $scope.state = channel;
    };
    $scope.ok = function () {
        $modalInstance.close($scope.selected.item);
    };
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };

    function defaultState(){
        $scope.state = "facebook";
        if($scope.facebookList.length == 0 && $scope.twitterList.length == 0 && $scope.linkedinList.length == 0 && $scope.smsList.length == 0 && $scope.emailList.length > 0)
            $scope.state = "email";
        else if($scope.facebookList.length == 0 && $scope.twitterList.length == 0 && $scope.linkedinList.length == 0 && ($scope.smsList.length > 0 && $scope.emailList.length > 0) || $scope.smsList.length > 0 && $scope.emailList.length == 0)
            $scope.state = "sms";
        else if($scope.facebookList.length == 0 && $scope.twitterList.length == 0 && $scope.linkedinList.length > 0)
            $scope.state = "LinkedIn";
        else if($scope.facebookList.length == 0 && $scope.twitterList.length > 0 && ($scope.linkedinList.length == 0 || $scope.linkedinList.length > 0))
            $scope.state = "twitter";
        else if($scope.facebookList.length == 0 && $scope.twitterList.length == 0 && $scope.linkedinList.length == 0 && $scope.qrcodesList.length > 0)
            $scope.state = "qrcode";

    }
});

InquirlyApp.controller('queueCtrl', function($scope,$http,$modalInstance) {
    $scope.yes = function () {
        $http.post('/power_share/clear_queue').success(function(data, status, headers, config) {
            $scope.loadMoreQueue();
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

InquirlyApp.controller('scheduleCtrl', function($scope,$http,$modalInstance,campaign_id,share_form) {
    $scope.id = campaign_id;
    $scope.shareNow = function (id,date){
        $scope.isInvalid = date.getTime() < new Date().getTime();
        if($scope.isInvalid) { return; }
        if(id == 0){
            $scope.powerShare(date,false);
        }else{
            $scope.reShareNow(id,date,false);
        }
        $modalInstance.close();
    };
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('removeQueueCtrl', function($scope,$http,$modalInstance,campaign_id) {
    $scope.id = campaign_id;
    $scope.yes = function (id) {
        $http.post('/power_share/remove_post', {campaign_id: $scope.id }).success(function() {
            $scope.scheduledCampaigns = _.without($scope.scheduledCampaigns, _.findWhere($scope.scheduledCampaigns, {campaign_id: $scope.id}));
            $modalInstance.close($scope.id);
        });
    };
    $scope.no = function () {
        $modalInstance.dismiss('cancel');
    };
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