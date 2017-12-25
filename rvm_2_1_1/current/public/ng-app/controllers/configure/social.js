InquirlyApp.controller('ConfigureController', function($scope, $http, $modal,Onboarding) {
    $scope.profileData = { myData: [] };
    Onboarding.update_status($scope.profileData);
});

InquirlyApp.controller('SocialController', function($scope, $http, $modal,$location,$cookies) {
 
    if($cookies.error_message != null){
        var cookies_message =  JSON.parse($cookies.error_message);
        $scope.cookiesVaue = cookies_message.message.replace(/\+/g, ' ');
        if(cookies_message.message_type == "success"){
           $scope.alerts = [{ type: 'success', msg:  $scope.cookiesVaue }]
        }else{
            $scope.alerts = [{ type: 'danger', msg:  $scope.cookiesVaue }]
        }
    }

    $scope.getSocialAccounts = function(){
        $http.get('/configurations/social_configure.json').success(function(data) {
            $scope.socials = data;
        });
    };
    $scope.getSocialAccounts();

    $scope.closeAlert = function(index) {
        $scope.alerts.splice(index, 1);
        delete $cookies["error_message"]
    };

	$scope.remove = function(item) {
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/configure/socialModalContent.html',
            controller: 'ModalInstanceCtrl',
            scope: $scope,
            resolve: {
                socials: function(){
                  return  $scope.socials;
                },
                removeItem: function () {
                    return item;
                }
            }
        });
        modalInstance.result.then(function (selectedItem) {
            $scope.selected = selectedItem;
        });
	};

    $scope.accountChoose = function() {
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/configure/fbAccountSelectDialog.html',
            controller: 'AccountSelectCtrl',
            scope: $scope,
            backdrop : 'static',
            size: 'lg',
            resolve: {}
        });
    };

    if($location.search() && $location.search().page == "true"){
        if($location.search().source == "facebook"){
            $scope.pages = [];
            $scope.accounts = [];

            $http.get('/users/fb_pages').success(function(data) {
                $scope.pages = data[0];
                $scope.accounts = data[1];
                if(!_.isEmpty($scope.pages) || !_.isEmpty($scope.accounts)){
                    $scope.accountChoose();
                }else{
                    $location.search('page', null);
                    $location.search('source', null)
                }
            });
        }
        else if($location.search().source == "linkedin"){
            $scope.linkedin_page = [];
            $scope.linkedin_accounts = [];

            $http.get('/users/linkedin_pages').success(function(data) {
                $scope.linkedin_page = data[0];
                $scope.linkedin_accounts = data[1];
                if(!_.isEmpty($scope.linkedin_page) || !_.isEmpty($scope.linkedin_accounts)){
                    $scope.linkedinAccountChoose();
                }else{
                    $location.search('page', null);
                    $location.search('source', null);
                }
            });
        }
    }

    $scope.linkedinAccountChoose = function(){
        var modalInstance = $modal.open({
            templateUrl: '/ng-app/templates/configure/linkedinAccountSelectDialog.html',
            controller: 'linkedinAccountSelectCtrl',
            scope: $scope,
            backdrop : 'static',
            size: 'lg',
            resolve: {}
        })
    };
});

InquirlyApp.controller('ModalInstanceCtrl', function ($scope,$http, $modalInstance, removeItem,socials,Onboarding) {
    $scope.info = removeItem;
    $scope.socials = socials;
    $scope.yes = function () {
		var index = $scope.socials.indexOf(removeItem);
		$scope.socials.splice(index, 1);
        $http.post('/customers/remove_social_account', {id: removeItem.id}).success(function(data, status, headers, config) {
                $modalInstance.close();
                Onboarding.update_status($scope.$parent.profileData);
        })
    };
    $scope.no = function () {
        $modalInstance.dismiss('cancel');
    };
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});

InquirlyApp.controller('AccountSelectCtrl', function ($scope,$http, $modalInstance,$location,Onboarding) {

    $scope.selectedPage = [];
    $scope.selectedAccount = [];
    $scope.setSelected = function (id) {
        if (_.contains($scope.selectedPage, id)) {
            $scope.selectedPage = _.without($scope.selectedPage, id);
        } else {
            $scope.selectedPage.push(id);
        }

        return false;
    };

    $scope.isSelected = function (id) {
        if (_.contains($scope.selectedPage, id)) {
            return 'fa fa-check-square-o select-icon';
        }else{
            return 'fa fa-square-o select-icon';
        }
    };

    $scope.setAccountSelected = function (id) {
        if (_.contains($scope.selectedAccount, id)) {
            $scope.selectedAccount = _.without($scope.selectedAccount, id);
        } else {
            $scope.selectedAccount.push(id);
        }

        return false;
    };

    $scope.isAccountSelected = function (id) {
        if (_.contains($scope.selectedAccount, id)) {
            return 'fa fa-check-square-o select-icon';
        }else{
            return 'fa fa-square-o select-icon';
        }
    };

    $scope.connectPages = function(){
        var pages = { pages: $scope.selectedPage, account: $scope.selectedAccount };
        $http.post('/users/save_fb_pages',pages).success(function() {
            $location.search('page', null);
            $modalInstance.close();
            Onboarding.update_status($scope.$parent.profileData);
            $scope.getSocialAccounts();
        })
    };

    $scope.removeFbSession = function(){
        $location.search('page', null);
        $http.get('/users/remove_fb_session').success(function() {
            $modalInstance.dismiss('cancel');
        });
    };
    $scope.cancelConnect = function(){
        $scope.removeFbSession();
    };

    $scope.cancel = function () {
        $scope.removeFbSession();
    };

});

InquirlyApp.controller('linkedinAccountSelectCtrl', function ($scope,$http, $modalInstance,$location,Onboarding) {

    $scope.lnSelectedPage = [];
    $scope.lnSelectedAccount = [];

    $scope.setSelected = function (id) {
        if (_.contains($scope.lnSelectedPage, id)) {
            $scope.lnSelectedPage = _.without($scope.lnSelectedPage, id);
        } else {
            $scope.lnSelectedPage.push(id);
        }

        return false;
    };

    $scope.isSelected = function (id) {
        if (_.contains($scope.lnSelectedPage, id)) {
            return 'fa fa-check-square-o select-icon';
        }else{
            return 'fa fa-square-o select-icon';
        }
    };

    $scope.setAccountSelected = function (id) {
        if (_.contains($scope.lnSelectedAccount, id)) {
            $scope.lnSelectedAccount = _.without($scope.lnSelectedAccount, id);
        } else {
            $scope.lnSelectedAccount.push(id);
        }

        return false;
    };

    $scope.isAccountSelected = function (id) {
        if (_.contains($scope.lnSelectedAccount, id)) {
            return 'fa fa-check-square-o select-icon';
        }else{
            return 'fa fa-square-o select-icon';
        }
    };


    $scope.connectLinkedinPages = function(){
        var pages = { pages: $scope.lnSelectedPage, account: $scope.lnSelectedAccount };
        $http.post('/users/save_linkedin_pages',pages).success(function() {
            $location.search('page',null);
            $location.search('source',null);
            $modalInstance.close();
            Onboarding.update_status($scope.$parent.profileData);
            $scope.getSocialAccounts();
        })
    };

    $scope.removeLinkedinSession = function(){
        $location.search('page',null);
        $location.search('source',null);
        $http.get('/users/remove_linkedin_session').success(function() {
            $modalInstance.dismiss('cancel');
        });
    };

    $scope.cancelConnect = function(){
        $scope.removeLinkedinSession();
    };

    $scope.cancel = function () {
        $scope.removeLinkedinSession();
    };
});

InquirlyApp.filter('linkAccount', function () {
    return function (account) {
        var link;
         if(account.channel == 'twitter'){
             link = 'https://twitter.com/' + account.name;
         }else if(account.channel == 'facebook'){
             link = 'https://www.facebook.com/' + account.social_id;
        }else if(account.channel == 'google_oauth2'){
            link = account.social_id;
        }else{
             link = 'https://www.linkedin.com/';
         }
        return link;
    };
});