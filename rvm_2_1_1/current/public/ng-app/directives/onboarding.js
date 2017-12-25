InquirlyApp.service('Onboarding', function($http) {
     this.update_status = function(scope) {
        if(_.isEmpty(scope.myData)) { scope.myData = []; }
        $http.get('/configurations/get_user_actions.json').success(function(data) {
              scope.myData =  data;
        });
     }
});