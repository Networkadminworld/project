InquirlyApp.service("chatGoService", ['$http','$q', function($http,$q){
    var service = this;
    var rest_base_url = baseURL+"/";


    service.get_user_avatar = function(uid){
        var reqParams = {
            method: "post",
            url: rest_base_url + "api/user/userAvatar",
            data: {
                uid: uid
            }
        };
        var deferred = $q.defer();
        $http(reqParams).then(function(resp){
                deferred.resolve(resp);
            },
            function(err){
                deferred.reject(err);
            }
        );
        return deferred.promise;
    };

    service.get_user_by_email = function(email) {
        var reqParams = {
            method: "post",
            url: rest_base_url + "api/user/userByEmail",
            data: {
                email: email
            }
        };

        var deferred = $q.defer();
        $http(reqParams).then(function(resp){
            deferred.resolve(resp);
        },
            function(err){
                deferred.reject(err);
            }
        );
        return deferred.promise;
    };

     service.get_user_by_uid = function(uid) {
        var reqParams = {
            method: "post",
            url: rest_base_url + "api/user/userByUid",
            data: {
                uid: uid
            }
        };

        var deferred = $q.defer();
        $http(reqParams).then(function(resp){
            deferred.resolve(resp);
        },
            function(err){
                deferred.reject(err);
            }
        );
        return deferred.promise;
    };


    service.get_auth_token = function(nonce,userId){
        console.log("getting auth token");
        var deferred = $q.defer();
        var reqParams = {
            method: "post",
            url: rest_base_url+"api/user/token",
            data: {
               nonce: nonce,
               userId: userId //get this param from the existing system
            }
        }

        $http(reqParams).then(function(resp){
            deferred.resolve(resp);
        },function(err){
            deferred.reject(err);
        });
        return deferred.promise;
    }

    service.get_conv_history = function(layer_conv_id) {
        var deferred = $q.defer();
        var reqParams = {
            method: "post",
            url: rest_base_url+"api/conv/get_history",
            data:{
                layer_id: layer_conv_id
            }
        };

        $http(reqParams).then(function(resp){
            deferred.resolve(resp);
        },function(err){
            deferred.reject(err);
        });
        return deferred.promise;
    }

    service.put_conv_history = function(layer_conv_id,message,sender,type) {
        var deferred = $q.defer();
        var reqParams = {
            method: "post",
            url: rest_base_url+"api/conv/put_history",
            data:{
                layer_id: layer_conv_id,
                message: message,
                sender: sender,
                type: type
            }
        };

        $http(reqParams).then(function(resp){
            deferred.resolve(resp);
        },function(err){
            deferred.reject(err);
        });
        return deferred.promise;
    }

    service.bulk_conv_history = function(convs, layer_session_id) {
        var deferred = $q.defer();
        var reqParams = {
            method: "post",
            url: rest_base_url+"api/conv/bulk_history",
            data:{
                layer_id: layer_session_id,
                conversations: convs
            }
        };

        $http(reqParams).then(function(resp){
            deferred.resolve(resp);
        },
         function(err){
                deferred.reject(err)
            }
        );

        return deferred.promise;
    }

}]);