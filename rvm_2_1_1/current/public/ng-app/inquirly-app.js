/* Initialize */
var pipelineURL = document.getElementById('v2_pipeline').value;
var pipelineWsUrl =  document.getElementById('v2_pipeline_ws').value;
var baseURL = document.getElementById('v2-listen').value;
var InquirlyApp = angular.module('InquirlyApp', ['ui.router', 'ui.calendar','colorpicker.module', 'ui.bootstrap','ngFileUpload','ngTagsInput','uiSwitch','ui.bootstrap.datetimepicker',
    'ngSanitize','akoenig.deckgrid','angular-tour','timepickerPop','ngCookies','angular-google-analytics','infinite-scroll','ngAnimate',
    'ngDraggable','listenController','listenFilters','campaigns','pipelineStatusFilters','ngCsv','rzModule','textAngular','angularSpectrumColorpicker','ui.bootstrap.dropdownToggle', 'ui.codemirror','pipelines']);
var dispatcher;
dispatcher = new WebSocketRails($('#local-server').data('uri'), true);

InquirlyApp.config(["$httpProvider", function($httpProvider) {
    $httpProvider.defaults.useXDomain = true;
    delete $httpProvider.defaults.headers.common['X-Requested-With'];
  }
]);

InquirlyApp.config(function ($provide, $httpProvider) {

    // Intercept http calls.
    $provide.factory('InqInterceptor', function ($q) {
        return {

            // On request success
            request: function (config) {
                return config || $q.when(config);
            },

            // On request failure
            requestError: function (rejection) {
                return $q.reject(rejection);
            },

            // On response success
            response: function (response) {
                if(response.data && response.data.header && response.data.header.status == 401){
                    window.location.reload();
                }
                return response || $q.when(response);
            },

            // On response failure
            responseError: function (rejection) {
                return $q.reject(rejection);
            }
        };
    });

    // Add the interceptor to the $httpProvider.
    $httpProvider.interceptors.push('InqInterceptor');

    // textAngular Dependency

    $provide.decorator('taOptions', ['taRegisterTool', '$delegate', function(taRegisterTool, taOptions){
        // $delegate is the taOptions we are decorating
        // register the tool with textAngular

        taOptions.forceTextAngularSanitize = false;

        taRegisterTool('backgroundColor', {
            display: "<div spectrum-colorpicker ng-model='color' on-change='!!color && action(color)' format='\"hex\"' options='options'></div>",
            action: function (color) {
                var me = this;
                if (!this.$editor().wrapSelection) {
                    setTimeout(function () {
                        me.action(color);
                    }, 100)
                } else {
                    return this.$editor().wrapSelection('backColor', color);
                }
            },
            options: {
                replacerClassName: 'fa fa-paint-brush', showButtons: true, showInput: true, showAlpha: false
            },
            color: "#fff"
        });

        taRegisterTool('fontColor', {
            display:"<div spectrum-colorpicker trigger-id='{{trigger}}' ng-model='color' on-change='!!color && action(color)' format='\"hex\"' options='options'></div>",
            action: function (color) {
                var me = this;
                if (!this.$editor().wrapSelection) {
                    setTimeout(function () {
                        me.action(color);
                    }, 100)
                } else {
                    return this.$editor().wrapSelection('foreColor', color);
                }
            },
            options: {
                replacerClassName: 'fa fa-font', showButtons: true, showInput: true, showAlpha: false
            },
            color: "#000"
        });


        taRegisterTool('fontName', {
            display: "<span class='bar-btn-dropdown dropdown'>" +
                "<button class='btn btn-blue dropdown-toggle' type='button' ng-disabled='showHtml()' style='padding-top: 4px'><i class='fa fa-font'></i><i class='fa fa-caret-down'></i></button>" +
                "<ul class='dropdown-menu'><li ng-repeat='o in options'><button class='btn btn-blue checked-dropdown' style='font-family: {{o.css}}; width: 100%' type='button' ng-click='action($event, o.css)'><i ng-if='o.active' class='fa fa-check'></i>{{o.name}}</button></li></ul></span>",
            action: function (event, font) {
                //Ask if event is really an event.
                if (!!event.stopPropagation) {
                    //With this, you stop the event of textAngular.
                    event.stopPropagation();
                    //Then click in the body to close the dropdown.
                    $("body").trigger("click");
                }
                return this.$editor().wrapSelection('fontName', font);
            },
            options: [
                { name: 'Sans-Serif', css: 'Arial, Helvetica, sans-serif' },
                { name: 'Serif', css: "'times new roman', serif" },
                { name: 'Wide', css: "'arial black', sans-serif" },
                { name: 'Narrow', css: "'arial narrow', sans-serif" },
                { name: 'Comic Sans MS', css: "'comic sans ms', sans-serif" },
                { name: 'Courier New', css: "'courier new', monospace" },
                { name: 'Garamond', css: 'garamond, serif' },
                { name: 'Georgia', css: 'georgia, serif' },
                { name: 'Tahoma', css: 'tahoma, sans-serif' },
                { name: 'Trebuchet MS', css: "'trebuchet ms', sans-serif" },
                { name: "Helvetica", css: "'Helvetica Neue', Helvetica, Arial, sans-serif" },
                { name: 'Verdana', css: 'verdana, sans-serif' },
                { name: 'Proxima Nova', css: 'proxima_nova_rgregular' }
            ]
        });


        taRegisterTool('fontSize', {
            display: "<span class='bar-btn-dropdown dropdown'>" +
                "<div class='dropdown-toggle' type='button' ng-disabled='showHtml()' style='padding-top: 4px'><i class='fa fa-text-height'></i><i class='fa fa-caret-down'></i></div>" +
                "<ul class='dropdown-menu'><li ng-repeat='o in options'><div class='checked-dropdown' style='font-size: {{o.css}}; width: 100%' type='button' ng-click='action($event, o.value)'><i ng-if='o.active' class='fa fa-check'></i> {{o.name}}</div></li></ul>" +
                "</span>",
            action: function (event, size) {
                //Ask if event is really an event.
                if (!!event.stopPropagation) {
                    //With this, you stop the event of textAngular.
                    event.stopPropagation();
                    //Then click in the body to close the dropdown.
                    $("body").trigger("click");
                }
                return this.$editor().wrapSelection('fontSize', parseInt(size));
            },
            options: [
                { name: 'xx-small', css: 'xx-small', value: 1 },
                { name: 'x-small', css: 'x-small', value: 2 },
                { name: 'small', css: 'small', value: 3 },
                { name: 'medium', css: 'medium', value: 4 },
                { name: 'large', css: 'large', value: 5 },
                { name: 'x-large', css: 'x-large', value: 6 },
                { name: 'xx-large', css: 'xx-large', value: 7 }

            ]
        });


        // add the button to the default toolbar definition
        taOptions.toolbar[1].push('backgroundColor','fontColor','fontName','fontSize');
        return taOptions;
    }]);
});

InquirlyApp.run(['$rootScope', '$state', '$anchorScroll', '$stateParams','$location','Session','layerService','chatGoService','$http','$cookieStore','messageListener','pipelineService','$timeout',
    function ($rootScope,$state,$anchorScroll,$stateParams,$location,Session,layerService,chatGoService,$http) {

        $rootScope.$state = $state;
        $rootScope.$stateParams = $stateParams;
        $rootScope.session = Session;

        $rootScope.getPermissions = function(){
            $http.get('/account/user_permissions').success(function(data) {
                Session.data.permissions = data;
                sessionStorage.permissions = JSON.stringify(data);
            })
        };

        $rootScope.isPermitted = true;
        if(_.isEmpty(sessionStorage)){
            $rootScope.getPermissions();
        }

        $rootScope.$on("$stateChangeSuccess", function (event, toState, toParams, fromState, fromParams) {
            var permissions;

            if(!_.isEmpty(sessionStorage) && sessionStorage.permissions != "null"){
                permissions = JSON.parse(sessionStorage.permissions);
            }else{
                $rootScope.getPermissions();
                permissions = JSON.parse(sessionStorage.permissions);
            }

           if(permissions && permissions.campaigns) {
               permissions.configure_catalogue= true;
           }
           console.log(toParams);
           if(permissions && permissions[toParams.feature]){
               $rootScope.isPermitted = true;
               $state.go(toState.name);
               var baseRoute = toState.name.split(".")[0];
               if( baseRoute == "listen" || baseRoute == "alerts"  || baseRoute == "justbake" || baseRoute == "jbsearch" ||
                   baseRoute == "jb_tenant_account" || baseRoute == "jb_admin_account" || baseRoute == "pipelines"){
                   $location.path(toState.url);
               }else{
                   $location.path(baseRoute+toState.url);
               }
           }else{
               console.log('else');
               $state.go('command-center.index');
               $location.path("/command-center/index");
               $rootScope.isPermitted = false;
               $rootScope.alerts = [{ type: 'danger', msg: 'You are not authorized for this operation.' }];
           }
           $anchorScroll();
        });

        //For Piwik
        $rootScope.$on('$viewContentLoaded', function(event) {
            try {
                window._paq.push(['trackPageView', document.title]);
            } catch(err) { }
        });
    }]);

InquirlyApp.config(function(AnalyticsProvider) {
    // Set analytics account
    AnalyticsProvider.setAccount('UA-50607839-3');

    // Track all routes (or not)
    AnalyticsProvider.trackPages(true);

    // Track all URL query params (default is false)
    AnalyticsProvider.trackUrlParams(true);

    // Use analytics.js instead of ga.js
    AnalyticsProvider.useAnalytics(true);

    // Enable enhanced link attribution
    AnalyticsProvider.useEnhancedLinkAttribution(true);

    AnalyticsProvider.setPageEvent('$stateChangeSuccess');

}).run(function(Analytics) { });

/* Left Navigation Routes */
InquirlyApp.config(function($stateProvider,$urlRouterProvider) {
    $urlRouterProvider.otherwise("/command-center/index");
    $urlRouterProvider.when("/configure", "/configure/social");
    $urlRouterProvider.when("/account", "/account/settings");

    $stateProvider
      .state('command-center', {
        url: "/command-center",
        abstract:true,
        template: '<div ui-view></div>',
        controller: 'DashboardController'
      }).state('command-center.index', {
            url: "/index",
            templateUrl: '/ng-app/templates/command-center/index.html',
            controller: 'CommandCenterController',
            params: {postParams: null, feature: "power_share"},
            reloadOnSearch: false,
            data: {
                pageTitle: 'Command-Center | Inquirly'
            }
        })
      .state('home', {
            url: "/home",
            abstract:true,
            template: '<div ui-view></div>',
            controller: 'PowerShareController'
        }).state('home.index', {
            url: "/index",
            templateUrl: '/ng-app/templates/home/index.html',
            controller: 'HomeController',
            params: {postParams: null, feature: "power_share"},
            reloadOnSearch: false,
            data: {
                pageTitle: 'PowerShare | Inquirly'
            }
        })
        .state('home.history', {
            url: "/history",
            templateUrl: '/ng-app/templates/home/postingHistory.html',
            controller: 'HistoryController',
            params: {feature: "power_share"},
            reloadOnSearch: false,
            data: {
                pageTitle: 'Posting History | Inquirly'
            }
        })
      .state('campaigns', {
        url: "/campaigns",
        abstract:true,
        template: '<div ui-view></div>'
      }).state('campaigns.index', {
            url: "/index",
            templateUrl: baseURL +'/campaigns/new_campaign',
            controller: "NewCampaignCtrl",
            params: {feature: "campaigns"},
            reloadOnSearch: false,
            data: {
                pageTitle: "Campaigns | Inquirly"
            }
        }).state('campaigns.campaign-builder', {
            url: '/campaign_builder',
            templateUrl: baseURL + "/campaigns/campaigns_builder",
            controller: "campaignBuilderCtrl",
            params: {'campaign':null,campaign_id:null,feature: "campaigns",mode: null},
            reloadOnSearch: false,
            data: {
                pageTitle: "Campaigns | Campaign Builder | Inquirly"
            }
        }).state("campaigns.drafts", {
            url: "/drafts",
            templateUrl: baseURL + '/campaigns/drafts',
            controller: "CampaignDraftsCtrl",
            params: {feature: "campaigns", campaign: null},
            reloadOnSearch: false,
            data: {
                pageTitle: "Campaigns | Campaign Builder | Inquirly"
            }
        }).state("campaigns.preview", {
            url: "/preview",
            templateUrl: baseURL +'/campaigns/preview',
            params: {'campaign_id':null,feature: "campaigns"},
            controller: "CampaignPreviewCtrl",
            reloadOnSearch: false,
            data: {
                pageTitle: "Campaigns | Campaign Preview | Inquirly"
            }
        }).state("campaigns.expired", {
            url: "/expired",
            templateUrl: baseURL + '/campaigns/expired',
            params: {feature: "campaigns", campaign: null},
            controller: "expiredCampaignsCtrl",
            reloadOnSearch: false,
            data: {
                pageTitle: "Campaigns | Campaign Expired | Inquirly"
            }
        }).state("campaigns.queued", {
            url: "/queued",
            templateUrl: baseURL + '/campaigns/queued',
            params: {feature: "campaigns",campaign: null},
            controller: "queuedCampaignsCtrl",
            reloadOnSearch: false,
            data: {
                pageTitle: "Campaigns | Campaign Queued | Inquirly"
            }
        }).state("campaigns.rejected", {
            url: "/rejected",
            templateUrl: baseURL + '/campaigns/rejected',
            params: {feature: "campaigns"},
            controller: "CampaignRejectedCtrl",
            reloadOnSearch: false,
            data: {
                pageTitle: "Campaigns | Campaign Rejected | Inquirly"
            }
        }).state("campaigns.archives", {
            url: "/archives",
            templateUrl: baseURL + '/campaigns/archives',
            params: {feature: "campaigns"},
            controller: "CampaignArchivesCtrl",
            reloadOnSearch: false,
            data: {
                pageTitle: "Campaigns | Campaign Archived | Inquirly"
            }
        }).state("campaigns.stats", {
            url: "/stats",
            templateUrl: '/campaigns/stats',
            params: {'campaign':null,feature: "campaigns"},
            controller: "CampaignStatsCtrl",
            reloadOnSearch: false,
            data: {
                pageTitle: "Campaigns | Campaign Stats | Inquirly"
            }
        }).state("campaigns.search", {
            url: "/search",
            templateUrl: baseURL + '/campaigns/search',
            controller: "CampaignSearchCtrl",
            params: {feature: "campaigns", campaign: null},
            reloadOnSearch: false,
            data: {
                pageTitle: "Campaigns | Campaign Builder | Inquirly"
            }
        })
      .state('listen', {
        url: "/listen",
        templateUrl: baseURL + '/listen_v2/v2/listen',
        controller: 'listenCtrl',
        params: {feature: "listen"},
        reloadOnSearch: false,
        data: {
          pageTitle: 'Listen | Inquirly'
        }
      })
      .state('configure', {
        url: "/configure",
        abstract: true,
        templateUrl: '/ng-app/templates/configure/index.html',
        controller: 'ConfigureController',
        data: {
          pageTitle: 'Configure | Inquirly'
        }
      }).state('configure.social', {
            url: "/social",
            templateUrl: "/ng-app/templates/configure/social.html",
            controller: 'SocialController',
            params: {feature: "configure_social"},
            reloadOnSearch: false,
            data: {
                pageTitle: 'Configure | Social | Inquirly'
            }
        }).state('configure.mobile', {
            url: "/mobile",
            templateUrl: "/ng-app/templates/configure/mobile.html",
            controller: 'MobileController',
            params: {feature: "configure_mobile"},
            reloadOnSearch: false,
            data: {
                pageTitle: 'Configure | Mobile | Inquirly'
            }
        }).state('configure.company', {
            url: "/company",
            templateUrl: "/ng-app/templates/configure/company.html",
            controller: 'CompanyController',
            params: {feature: "configure_company"},
            reloadOnSearch: false,
            data: {
                pageTitle: 'Configure | Company | Inquirly'
            }
        }).state('configure.schedule', {
            url: "/schedule",
            templateUrl: "/ng-app/templates/configure/schedule.html",
            params: {feature: "configure"},
            controller: 'ScheduleController',
            reloadOnSearch: false,
            data: {
                pageTitle: 'Configure | Schedule | Inquirly'
            }
        }).state('configure.listen', {
            url: "/listen",
            templateUrl: baseURL + "/listen_v2/v2/config",
            controller: "listenConfigCtrl",
            params: {feature: "configure_listen"},
            reloadOnSearch: false,
            data: {
                pageTitle: 'Configure | Listen | Inquirly'
            }
        }).state('configure.in-location', {
            url: "/in-location",
            templateUrl: "/ng-app/templates/configure/inLocation.html",
            controller: "InLocationController",
            params: {feature: "configure_location"},
            reloadOnSearch: false,
            data: {
                pageTitle: 'Configure | In Location | Inquirly'
            }
        }).state('configure.catalogue', {
            url: "/catalogue",
            templateUrl: baseURL + "/campaigns/catalog_config",
            controller: "catalogConfigCtrl",
            params: {feature: "configure_catalogue"},
            reloadOnSearch: false,
            data: {
                pageTitle: 'Catalogue | In Location | Inquirly'
            }
        }).state('configure.alerts', {
            url: "/alerts",
            templateUrl: "/ng-app/templates/configure/alerts.html",
            controller: 'AlertConfigController',
            params: {feature: "configure_alerts"},
            reloadOnSearch: false,
            data: {
                pageTitle: 'Configure | Alerts | Inquirly'
            }
        })
      .state('alerts', {
        url: "/alerts",
        templateUrl: baseURL + '/listen_v2/v2/alerts',
        controller: 'alertsCtrl',
        params: {feature: "alerts"},
        data: {
            pageTitle: 'Alerts | Inquirly'
        }
      })
      .state('account', {
        url: "/account",
        abstract: true,
        templateUrl: '/ng-app/templates/account/index.html',
        controller: 'AccountSettingsController',
        data: {
            pageTitle: 'Account | Inquirly'
        }
        }).state('account.settings', {
            url: "/settings",
            templateUrl: "/ng-app/templates/account/settings.html",
            controller: 'AccountController',
            params: {feature: "account_settings"},
            reloadOnSearch: false,
            data: {
                pageTitle: 'Account | Settings | Inquirly'
            }
        }).state('account.payments', {
            url: "/payments",
            templateUrl: "/ng-app/templates/account/payments.html",
            controller: 'PaymentController',
            params: {feature: "account_payments"},
            reloadOnSearch: false,
            data: {
                pageTitle: 'Account | Payments | Inquirly'
            }
        })
      .state('client', {
            url: "/client",
            abstract:true,
            templateUrl: '/ng-app/templates/client/index.html',
            controller: "ClientController"
        }).state('client.roles', {
            url: "/roles",
            templateUrl: "/ng-app/templates/client/roles.html",
            controller: "RolesController",
            params: {feature: "client_roles"},
            reloadOnSearch: false,
            data: {
                pageTitle: 'Teams and Roles | Inquirly'
            }
        }).state('client.users', {
            url: "/users",
            templateUrl: "/ng-app/templates/client/users.html",
            controller: "ClientUsersController",
            params: {feature: "client_users"},
            reloadOnSearch: false,
            data: {
                pageTitle: 'Teams and Roles | Inquirly'
            }
        }).state('client.tenants', {
            url: "/tenants",
            templateUrl: "/ng-app/templates/client/tenants.html",
            controller: "ClientTenantsController",
            params: {feature: "client_tenants"},
            reloadOnSearch: false,
            data: {
                pageTitle: 'Teams and Roles | Inquirly'
            }
        })
      .state('messages',{
            url: '/messages',
            abstract:true,
            template: '<div ui-view></div>',
            data: {
                pageTitle: 'Message | Inquirly'
            }
        }).state('messages.index', {
            url: "/index",
            controller: 'MessagesController',
            templateUrl: '/ng-app/templates/messages/index.html',
            params: {feature: "chat"},
            reloadOnSearch: false,
            data: {
                pageTitle: 'Message | Inquirly'
            }
        })
       .state('pipeline_old', {
            url:'/pipeline_old',
            abstract: true,
            templateUrl: '/ng-app/templates/pipeline/pipeline.index.html',
            controller: 'PipelineController',
            data: {
                pageTitle: 'Pipeline Old| Inquirly'
            }
        }).state('pipeline_old.sales', {
                    url: '/sales',
                    templateUrl: '/ng-app/templates/pipeline/pipeline.index.sales.html',
                    controller: 'PipelineSalesController',
                    params: {campaign_id:null, campaign_name:null, feature :"pipeline_sales"},
                    data: {
                        pageTitle: 'Sales | Pipeline | Inquirly'
                    }
                })
            .state('pipeline_old.marketing', {
                    url: '/marketing',
                    templateUrl: '/ng-app/templates/pipeline/pipeline.index.marketing.html',
                    controller: 'PipelineMarketingPersonController',
                    params: {campaign_id:null, campaign_name:null, source_type: null, status:null, feature:"pipeline_marketing"},
                    data: {
                        pageTitle: 'Marketing | Pipeline | Inquirly'
                    }
                })
           .state('pipeline_old.markmanager',{
                    url: '/markmanager',
                    controller: 'PipelineMarketingManagerController',
                    templateUrl: '/ng-app/templates/pipeline/pipeline.index.marketing.manager.html',
                    params: {campaign_id:null, campaign_name:null,source_type: null,filter_user:null,status:null,feature : "pipeline_marketing_manager"},
                    data: {
                       pageTitle: 'MarketingManager | Pipeline | Inquirly'
                    }
            })
            .state('pipeline_old.dboy', {
                    url: '/dboy',
                    controller: 'PipelineDBoyController',
                    templateUrl: '/ng-app/templates/pipeline/delivery_boy_view.html',
                    params: {feature : "pipeline_delivery"},
                    data: {
                        pageTitle: 'Delivery | Pipeline | Inquirly'
                   }
        })
       // .state('justbake', {
       //     url: '/justbake/pipeline',
       //     templateUrl: '/justbake/pipeline',
       //     controller: 'mainCtrl',
       //     params: {feature : "jb_pipeline"},
       //     data: {
       //         pageTitle: ' Pipeline | Inquirly'
       //     }
       // }).state('jbsearch', {
       //     url: '/justbake/search',
       //     templateUrl: '/justbake/search',
       //     controller: 'searchCtrl',
       //     params: {feature : "jb_pipeline"}
       // }).state('jb_tenant_account', {
       //     url: '/justbake/tenant_account',
       //     templateUrl: '/justbake/tenant_account',
       //     controller: 'tenantAccountsCtrl',
       //     params: {feature : "jb_pipeline"}
       // }).state('jb_admin_account', {
       //     url: '/justbake/admin_account',
       //     templateUrl: '/justbake/account',
       //     controller: 'accountsCtrl',
       //     params: {feature : "jb_pipeline"}
       // })
	.state('pipeline', {
            url:'/pipeline',
            abstract: true,
            template: '<div ui-view></div>',
            controller: "pipelineMainCtrl",
            data: {
                pageTitle: 'Pipeline | Inquirly'
            }
        })
        .state('pipeline3', {
            url: "/pipeline3",
            abstract:true,
            template: '<div ui-view></div>'
        }).state('pipeline3.index', {
            url: "/index",
            templateUrl: baseURL + '/pipeline2/home',
	    params: {feature: "pipeline_sales"},
            controller: "pipelineMainCtrl"
        }).state('pipeline3.stats', {
    	    url: "/stats",
      	    templateUrl: baseURL + '/pipeline2/stats',
            params: {feature: "pipeline_sales"},
            controller: "pipelineStatsCtrl"
        }).state('pipeline3.data', {
            url: "/data",
            templateUrl: baseURL + '/pipeline2/data',
            params: {feature: "pipeline_sales"},
            controller: "pipelineDataCtrl"
        });
});


InquirlyApp.filter('titleCase', function() {
        return function(input) {
            input = input || '';
            return input.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
        };
});

InquirlyApp.directive('updateTitle', ['$rootScope', '$timeout',function($rootScope, $timeout) {
        return {
            link: function(scope, element) {
                var listener = function(event, toState) {
                    var title = 'Inquirly';
                    if (toState.data && toState.data.pageTitle) title = toState.data.pageTitle;
                    $timeout(function() {
                        element.text(title);
                    }, 0, false);
                };
                $rootScope.$on('$stateChangeSuccess', listener);
            }
        };
    }
]);

InquirlyApp.controller('tourCtrl', function($scope,$http,$cookies,$rootScope) {

    $scope.enableTour = function(){
        $cookies.step = 0;
        var tourCookie = $cookies.page;
        if(!tourCookie) {
            tourCookie = { ps: false, listen: false };
        }else{
            tourCookie = JSON.parse(tourCookie);
            tourCookie['ps'] = false;
            tourCookie['listen'] = false;
        }
        $cookies.page =  JSON.stringify(tourCookie);
        $rootScope.$broadcast('openTour',{});
    };
});

InquirlyApp.controller('routeAccessCtrl', function($scope,$http,$rootScope,$state,$location,$cookieStore) {

    $scope.logOut = function(){
      delete sessionStorage.permissions;
       $cookieStore.remove("client_user_id");
       $cookieStore.remove("_layer_s_token");
      window.location.href = "/users/sign_out";
    };

    $scope.checkPageAccess  = function(feature){

        var permissions = $rootScope.session.data.permissions;

        if(permissions && permissions.campaigns) { permissions.configure_catalogue = true; }
  console.log(feature);
        if(feature == "configure"){
            if(permissions["configure_social"]){
                $state.go('configure.social');
                $location.path('/configure/social');
            } else if(permissions["configure_mobile"]){
                $state.go('configure.mobile');
                $location.path('/configure/mobile');
            } else if(permissions["configure_company"]){
                $state.go('configure.company');
                $location.path('/configure/company');
            } else if(permissions["configure_listen"]){
                $state.go('configure.listen');
                $location.path('/configure/listen');
            } else if(permissions["configure_location"]){
                $state.go('configure.in-location');
                $location.path('/configure/in-location');
            } else if(permissions["configure_catalogue"]){
                $state.go('configure.catalogue');
                $location.path('/configure/catalogue');
            } else{
                $rootScope.alerts = [{ type: 'danger', msg: 'You are not authorized for this operation.' }];
                $state.go('home.index');
                $location.path("/home/index");
            }
        } else if(feature == "account"){
            if(permissions["account_settings"]){
                $state.go('account.settings');
                $location.path('/account/settings');
            } else if(permissions["account_payments"]){
                $state.go('account.payments');
                $location.path('/account/payments');
            } else{
                $rootScope.alerts = [{ type: 'danger', msg: 'You are not authorized for this operation.' }];
                $state.go('home.index');
                $location.path("/home/index");
            }
        } else if(feature == "client"){
            if(permissions["client_roles"]){
                $state.go('client.roles');
                $location.path('/client/roles');
            } else if(permissions["client_users"]){
                $state.go('client.users');
                $location.path('/client/users');
            } else{
                $rootScope.alerts = [{ type: 'danger', msg: 'You are not authorized for this operation.' }];
                $state.go('home.index');
                $location.path("/home/index");
            }
        } else if(feature == "pipeline"){
            //if(permissions["pipeline_sales"]){
            //    $state.go('pipeline.sales');
            //    $location.path('/pipeline/sales');
            //} else if(permissions["pipeline_marketing"]){
            //    $state.go('pipeline.marketing');
            //    $location.path('/pipeline/marketing');
            //} else if(permissions["pipeline_marketing_manager"]){
            //    $state.go('pipeline.markmanager');
            //    $location.path('/pipeline/markmanager');
            //} else if(permissions["pipeline_delivery"]){
            //    $state.go('pipeline.dboy');
            //    $location.path('/pipeline/dboy');
            //}else if(permissions["jb_pipeline"]){
            //    $state.go('justbake');
            //    $location.path('/justbake/pipeline');
            //}else if(permissions["coolberryz_pipeline"]){
                $state.go('pipeline3.index');
                $location.path('/pipeline3/index');
                //$state.go('configure.social');
            //} else{
            //    console.log('here');
            //    $rootScope.alerts = [{ type: 'danger', msg: 'You are not authorized for this operation.' }];
            //    $state.go('home.index');
            //    $location.path("/home/index");
            //}
        } else if(feature == "pipeline_old"){
            if(permissions["pipeline_sales"]){
                $state.go('pipeline_old.sales');
                $location.path('/pipeline/sales');
            } else if(permissions["pipeline_marketing"]){
                $state.go('pipeline_old.marketing');
                $location.path('/pipeline/marketing');
            } else if(permissions["pipeline_marketing_manager"]){
                $state.go('pipeline_old.markmanager');
                $location.path('/pipeline/markmanager');
            } else if(permissions["pipeline_delivery"]){
                $state.go('pipeline_old.dboy');
                $location.path('/pipeline/dboy');
            } else{
                console.log('here');
                $rootScope.alerts = [{ type: 'danger', msg: 'You are not authorized for this operation.' }];
                $state.go('home.index');
                $location.path("/home/index");
            }
        }
    };
});

InquirlyApp.directive('compile', ['$compile', function ($compile) {
    return function(scope, element, attrs) {
        scope.$watch(
            function(scope) {
                return scope.$eval(attrs.compile);
            },
            function(value) {
                element.html(value);
                $compile(element.contents())(scope);
            }
        )};
}]);
