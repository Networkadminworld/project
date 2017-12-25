//Service talks to the backend APIs on Layer
InquirlyApp.service('layerService', ['$http','$q','$rootScope','$cookieStore', function($http,$q,$rootScope,$cookieStore){
  var service = this;

  service.layer_config ={
		config: { //TODO change to appropriate production ids
			serverUrl: "https://api.layer.com",
			appId: "layer:///apps/staging/39e5a19e-5154-11e5-9a12-7f0c831d7364"
		},
		headers: {
			Accept: "application/vnd.layer+json; version=1.0",
			Authorization: "",
			"Content-type": "application/json"
		}
	};
    /*LAYER API CALLS*/

    service.deleteConversation = function(convId){
        console.log("LayerService::deleteConversation()="+convId);
        var d = $q.defer();
        var authenticateHeader = {
            Accept: "application/vnd.layer+json; version=1.0",
            Authorization: "Layer session-token='"+ $cookieStore.get("_layer_s_token") + "'",
            "Content-type": "application/json"
        };


        var req = {
            method: 'DELETE',
            url: this.layer_config.config.serverUrl + "/conversations/"+convId+"?destroy=true",
            headers: authenticateHeader,
            data: {}
        };

        $http(req).then(function(resp){
                d.resolve(resp);
            },
            function(err){
                d.reject(err);
            }
        );
        return d.promise;
    }
    service.listConversations = function(){
        var d = $q.defer();
        var authenticateHeader = {
            Accept: "application/vnd.layer+json; version=1.0",
            Authorization: "Layer session-token='"+ $cookieStore.get("_layer_s_token") + "'",
            "Content-type": "application/json"
        };

        var req = {
            method: 'GET',
            url: this.layer_config.config.serverUrl + "/conversations",
            headers: authenticateHeader,
            data: {}
        };

        $http(req).then(function(resp){
            d.resolve(resp);
        }, function(err){
            d.reject(err);
        });
        return d.promise;
    };


    /*
     * getNonce from layer, first call in the list
     * */
  service.getNonce = function(){
    console.log("getting nonce")
    //debugger;
    var deferred = $q.defer();
    var req = {
      method: 'post',
      url: this.layer_config.config.serverUrl + "/nonces",
      headers: this.layer_config.headers,
      data: {}
    };
    $http(req)
      .then(function (resp) {
        console.log("resp=" + resp);
        //debugger;
        deferred.resolve(resp);
      }, function (err) {
        console.log("getnonce()=" + err.message);
        deferred.reject(err);
      });
    return deferred.promise;
  };

    /**
     * Create a session using the identity_token i.e. authenticate a user *
     * @method
     * @param  {string} identityToken   Identity token created by identity provider
     */
    service.authenticate = function (identityToken) {
        var d = $q.defer();
        var req = {
            method: 'POST',
            url: this.layer_config.config.serverUrl + "/sessions",
            headers: this.layer_config.headers,
            data: JSON.stringify({
                "identity_token": identityToken,
                "app_id": this.layer_config.config.appId
            })
        };
        //make post request
        $http(req)
            .then(
            function (data, textStatus, xhr) {
                //success
                console.log("session=" + textStatus);
                d.resolve(data);
            },
            function (err) {
                d.reject(err);
            }
        );
        return d.promise;
    };


     /*
       * create or get a distinct conversation
      */
      service.createConversation = function (participants) {
        //console.log("createConversation() with header=" + this.authenticateHeader.Authorization + " participants="+ participants);
        console.log("session_token="+ $cookieStore.get("_layer_s_token"));
        console.log("participants=" + participants);
        var authenticateHeader = {
        Accept: "application/vnd.layer+json; version=1.0",
        Authorization: "Layer session-token='"+ $cookieStore.get("_layer_s_token") + "'",
        "Content-type": "application/json"
        };

        var d = $q.defer();
        var req = {
          method: 'POST',
          url: this.layer_config.config.serverUrl + "/conversations",
          headers: authenticateHeader,
          data: JSON.stringify({
            "participants": participants,
              "distinct" : true //TODO:layer issues, for now setting it to false
          })
        };

        $http(req).then(
            function(res){
                d.resolve(res);
            },
            function(err){
                d.reject(err);
            }
        );
       return d.promise;
      };


     /**
      * BACKEND GOLANG SERVICE CALLS
      * */
      /*
      * get conversation history of a given conversation_id
      */

      service.getConversationHistory = function(conv_id) {
        //console.log("LayerService::getConversationHistory()="+$rootScope.layer_config.config.serverUrl + "/conversations/"+conv_id);
        var d = $q.defer();
        var authenticateHeader = {
              Accept: "application/vnd.layer+json; version=1.0",
              Authorization: "Layer session-token='"+ $cookieStore.get("_layer_s_token") + "'",
              "Content-type": "application/json"
            };

         var req = {
          method: 'GET',
          url: this.layer_config.config.serverUrl + "/conversations/"+conv_id+"/messages",
          headers: authenticateHeader,
          data: ""
        };

        $http(req).then(function(resp){
          d.resolve(resp);
        },
        function(err){
          d.reject(err);
        }
        );
        return d.promise;
      };

      /*
      * send a message towards a single conversation

      */

      service.sendMessage = function(conv_id, message){
        console.log("LayerService::sendMessage()="+message);
        var d = $q.defer();
        var authenticateHeader = {
              Accept: "application/vnd.layer+json; version=1.0",
              Authorization: "Layer session-token='"+ $cookieStore.get("_layer_s_token") + "'",
              "Content-type": "application/json"
            };

        var req = {
          method: 'POST',
          url: this.layer_config.config.serverUrl + "/conversations/" +conv_id + "/messages",
          headers: authenticateHeader,
          data: JSON.stringify({
                parts: [{
                    body: message,
                    mime_type: "text/plain"
                }]
            })
        };

        $http(req).then(function(resp){
          d.resolve(resp);
          console.log("message sent=" + resp.data.message + " " + resp.data);
        },function(err){
          d.reject(err);
          console.log("error sending message="+ err.data.message);
        });

        return d.promise;
      };

      service.destroy = function(sessionToken) {
        var authenticateHeader = {
              Accept: "application/vnd.layer+json; version=1.0",
              Authorization: "Layer session-token='"+ $cookieStore.get("_layer_s_token") + "'",
              "Content-type": "application/json"
            };

         var req = {
          method: 'DELETE',
          url: this.layer_config.config.serverUrl + "/sessions/"+sessionToken,
          headers: authenticateHeader,
          data: ""
        };

        $http(req).success(function(res){
          console.log("session removed!");
        }).error(function(err){
          console.log("error removing session=" + err.data.message);
        });
      };

     // service.get
     service.uploadAttachment = function(mimeType,size,data,convId) {
      console.log("LayerService::uploadAttachment()");
      var d = $q.defer();
      //initiate rich content for upload 
      initiateRichContentUpload(mimeType,size)
      .then(
        function(resp){
                   // debugger;
                    var uploadUrl = resp.data.upload_url;
                    var contentId = resp.data.id;
                    uploadContent(resp.data.upload_url, data).then(function(resp) {
                        //if everything is ok send the actual attachment
                        sendAttachment(contentId,size,convId,mimeType).then(
                            function(resp) {
                              d.resolve(resp);
                            },
                            function(err){
                              d.reject(err);
                            }
                          );
                    },function(err){
                      d.reject(err);
                    });
                },
        function(err){
          //debugger;
        }
      );
      return d.promise;
     };


     sendAttachment = function(contentId, size,conversationId,mimeType) {
        console.log("sending actual attachment as message");
        var d = $q.defer();
        var authenticateHeader = {
        Accept: "application/vnd.layer+json; version=1.0",
        Authorization: "Layer session-token='"+ $cookieStore.get("_layer_s_token") + "'",
        "Content-type": "application/json"
        };

        var d = $q.defer();
        var req = {
          method: 'POST',
          url: this.layer_config.config.serverUrl + "/conversations/"+conversationId+"/messages",
          headers: authenticateHeader,
          data: JSON.stringify({
             parts: [{
                    mime_type: mimeType,
                    content: {
                      id: contentId,
                      size: size                
                    }
                }]
          })
        };

        $http(req)
        .then(function(resp){
          d.resolve(resp);
        },
        function(err){
          d.reject(err);
        });
        return d.promise;
     };

     uploadContent = function(url,data) {
      console.log("uploading content to =" + url);
      var d = $q.defer();
        var r = new XMLHttpRequest();
        r.open('PUT', url, true);
        r.send(data);
        r.onload = function() {
            d.resolve(r.response);
        };
        return d.promise;
     };

     //helper methods 
     initiateRichContentUpload = function(mimeType,size) {
        var d = $q.defer();
        var authenticateHeader = {
              Accept: "application/vnd.layer+json; version=1.0",
              Authorization: "Layer session-token='"+ $cookieStore.get("_layer_s_token") + "'",
              "Content-type": "application/json",
              "Upload-Content-Type": mimeType,
              "Upload-Content-Length": size,
              "Upload-Origin": window.location.origin
            };

         var req = {
          method: 'POST',
          url: this.layer_config.config.serverUrl + "/content",
          headers: authenticateHeader,
          data: ""
        };

        $http(req).then(function(resp){
          d.resolve(resp);
        },function(err){
          d.reject(err);
        });


        return d.promise;
     };

      return service;
  }

]);
