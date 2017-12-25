InquirlyApp.controller('CampaignsController', function($scope,$modal,$http,$state) {

    $scope.loadCampaigns = function(){
        $http.get("/campaigns/list_all").success(function(data, status, headers, config) {
                $scope.salesCampaigns = data.sales;
                $scope.engageCampaigns = data.engage;
                $scope.opinionCampaigns = data.opinions;
                $scope.campaignTypes = data.campaign_types;
        })
    };
    $scope.loadCampaigns();

    $scope.createCampaign = function(type) {
        $scope.campaigns_type = type;
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/campaigns/campaignDialog.html',
            controller: 'createCampaignsCtrl',
            scope: $scope,
            resolve: {
                campaignsType: function(){
                    return  $scope.campaigns_type;
                }
            }
        });
        modalInstance.result.then(function (selectedItem) {
            $scope.selected = selectedItem;
        });
    };

    $scope.navSharePage = function(id,ctype,channel){
        $http.get('/campaigns/'+id).success(function(data, status, headers, config) {
            $scope.campaigns = data;
            $scope.reshare = true;
            $scope.createCampaign(ctype);
        });
    };
});

InquirlyApp.controller('createCampaignsCtrl', function ($scope,$http, $parse,$modalInstance,$state,campaignsType) {
    $scope.campaignType = campaignsType;
    angular.forEach($scope.campaignTypes, function (type) {
        if(angular.lowercase(type.name) == $scope.campaignType) $scope.campaignTypeId = type.id;
    });
    if(!$scope.reshare){
        $scope.campaign_exp_dates = [{"name": "10 days", "value": "10"},{"name": "20 days", "value": "20"},{"name": "30 days", "value": "30"}];
        $scope.campaigns = [];
        $scope.campaigns.label = '';
        $scope.createQuestion = function(ctype,channel){
            $scope.campaigns.hash_tag =  $scope.campaigns.label.replace(/\s+/g, '').toLowerCase();
            var campaignParams = {};
            campaignParams["campaign"] = {};
            campaignParams["campaign"]["label"] = $scope.campaigns.label;
            campaignParams["campaign"]["hash_tag"] = $scope.campaigns.hash_tag;
            campaignParams["campaign"]["exp_date"] = $scope.campaigns.exp_date;
            campaignParams["campaign"]["campaign_end_url"] = $scope.campaigns.campaign_end_url;
            campaignParams["campaign"]["campaign_type_id"] = $scope.campaignTypeId;
            campaignParams["campaign"]["two_way_campaign"] = true;
            campaignParams["campaign"]["is_active"] = false;
            $http.post('/campaigns', campaignParams).
                success(function(data, status, headers, config) {
                    if(ctype == "sales") $state.transitionTo('campaigns.sales',{ id: data.id, c_type: ctype, channel: channel});
                    else if(ctype == "engage") $state.transitionTo('campaigns.engage',{ id: data.id, c_type: ctype, channel: channel});
                    else $state.transitionTo('campaigns.opinion',{ id: data.id, c_type: ctype, channel: channel});
                    $modalInstance.close('closed');
            }).
            error(function(data, status, headers, config) {
                    // log error
            });
        };
    }else{
        $scope.createQuestion = function(ctype,channel){
            angular.forEach($scope.campaignTypes, function (type) { if(type.id == ctype) $scope.c_type = angular.lowercase(type.name); });
            if(ctype == "sales") $state.transitionTo('campaigns.sales',{ id: ctype, c_type: $scope.c_type, channel: channel});
            else if(ctype == "engage") $state.transitionTo('campaigns.engage',{ id: ctype, c_type: $scope.c_type, channel: channel});
            else $state.transitionTo('campaigns.opinion',{ id: ctype, c_type: $scope.c_type, channel: channel});
            $modalInstance.close('closed');
        }
    }

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.filter('removeSpacesThenLowercase', function () {
    return function (text) {
        var str = text.replace(/\s+/g, '');
        return str.toLowerCase();
    };
});

InquirlyApp.controller('CampaignSocialController', function ($scope,$http,$state,$stateParams) {
    $scope.campaign = [];
    var url = '/campaigns/campaign_details?id='+ $stateParams.id;
    $http.get(url).
        success(function(data, status, headers, config) {
            var campaign = JSON.parse(data.campaign);
            $scope.campaign.label = campaign.label;
            $scope.campaign.hash_tag = campaign.hash_tag;
            $scope.campaign.campaign_end_url = campaign.campaign_end_url;
            $scope.checked = campaign.two_way_campaign;
            $scope.socials = JSON.parse(data.social_info);
            angular.forEach($scope.socials, function (social) {
                if (social.provider == 'facebook'){
                    $scope.default_fb_name = social.user_name;
                    $scope.default_fb_logo = social.user_profile_image;
                }else if(social.provider == 'twitter'){
                    $scope.default_tw_name = social.user_name;
                    $scope.default_tw_logo = social.user_profile_image;
                }else{
                    $scope.default_ln_name = social.user_name;
                    $scope.default_ln_logo = social.user_profile_image;
                }
            });
            $scope.date = new Date();
        }).
        error(function(data, status, headers, config) {
            // log error
    });
});