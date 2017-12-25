InquirlyApp.factory('Session', function($http) {
  var Session = {
    version: 'v1',
    data: {},
    saveSession: function() { /* save session data to db */ },
    updateValue: function(key, value) {
      Session.data[key] = value;
    },
    updateSession: function() {
      /* load data from db */
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
          }).
          error(function(data, status, headers, config) {
              // log error
      });
    }
  };
  Session.updateSession();
  return Session;
});