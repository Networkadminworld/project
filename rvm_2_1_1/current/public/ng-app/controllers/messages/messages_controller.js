InquirlyApp.controller('MessagesController',['$http','$state','$scope','$rootScope','layerService','$cookieStore','chatGoService','messageListener',
    function($http,$state,$scope,$rootScope,layerService,$cookieStore, chatGoService,messageListener) {
        console.log("MessageController loaded");

        $scope.onTabSelect = function(option) {
            //console.log("selected="+option);
            $scope.selectedGroup = option;
            //if the tab has changed then load the apropriate user list
            //if "users" selected then load the users that we can chat with
            //else if "chats" selected then load active chat from browser cache
            tabSelectionChanged();
        };

        $scope.sendChat = function(evt) {
            //detect keypress for enter
            if(evt.keyCode == 13) {
                console.log("enter pressed");
                //user pressed enter
                $scope.sendMessage($scope.chat_message);
            }
        };

        $scope.sendMessage = function(textMessage) {
            if(textMessage != null && textMessage != "" && textMessage.length > 0) {
                console.log("sending message="+textMessage);
                //debugger;
                var item = {message: textMessage, sender: $rootScope.current_user.userId, type: "message"};
                //get existing messages
                var messageList = sessionStorage.getItem($scope.selectedUserID + "_chat");//angular.fromJson($cookieStore.get($scope.selectedUserID + "_chat"));
                if (messageList == null) {
                    messageList = [];
                } else {
                    messageList = JSON.parse(messageList);
                }
                messageList.push(item);
                sessionStorage.setItem($scope.selectedUserID + "_chat", JSON.stringify(messageList));

                $scope.conversations = messageList;
                $scope.chat_message = "";
                var layer_conv_id = sessionStorage.getItem($scope.selectedUserID);
                layerService.sendMessage(layer_conv_id, textMessage).
                    then(function (resp) {
                        //update conversation list
                        populateChatHeaders();
                        chatGoService.put_conv_history(layer_conv_id,
                            item.message,
                            item.sender,
                            item.type
                        ).then(function (resp) {
                                console.log("message added to history");
                            }, function (err) {
                                console.error("failed to add conversation to history");
                            });
                    }, function (err) {
                        console.error("layer send message failed");
                    });
            }

        };

        $scope.onUserSelection = function(user) {
            var selectedUserId;
            $scope.conversations = [];
            if($scope.selectedGroup == "chats") {
                $scope.selectedUserID = user.id;
                selectedUserId = user.id;
            }else {
                $scope.selectedUserID = user.id.Int64;
                selectedUserId = user.id.Int64;
            }
            //get selected user avatar
            chatGoService.get_user_avatar(user.uid)
                .then(function(resp){
                    var avatar_url = resp.data.avatar_url;
                    $scope.selectedUserAvatar = avatar_url;
                    //update the conv list to show the latest avatar url
                    var convList = sessionStorage.getItem("conv_list");
                    if(convList != null) {
                        convList = JSON.parse(convList);
                        angular.forEach(convList,function(conv) {
                            if (conv.uid == user.uid) {
                                conv.avatar = avatar_url;
                                //url updated write it to the sessionStorage
                            }
                        });
                        //update read count
                        angular.forEach(convList,function(conv){
                            if(conv.id == selectedUserId) {
                                conv.read_count = 0;
                            }
                        });
                        sessionStorage.setItem("conv_list", JSON.stringify(convList));
                        //$scope.chatList = convList;
                        CheckScopeBeforeApply();
                        /*if($scope.selectedGroup == "chats") {
                            $scope.$apply(function() {

                            });
                        }*/
                    }

                },function(err){
                    console.log("error getting avatar url");
                }
            );

            $scope.currentUserEmail = $rootScope.current_user.email;
            $scope.currentUserUID = $rootScope.current_user.userId;
            $scope.currentUserAvatar = $rootScope.current_user.avatar_url;
            //create a unique conversation
            //locate if we already have a layer conversation id
            //var layer_conv_id = $cookieStore.get(selectedUserId);
            var layer_conv_id = sessionStorage.getItem(selectedUserId);
            if ( layer_conv_id == null) {
                //conversation doesn't exist, create one unique per chat
                var participants = [$rootScope.current_user.userId, user.uid];
                layerService.createConversation(participants)
                    .then(function (resp) {
                        //store the current conversation id inside cookies
                        var curr_conv_id = resp.data.id.substring(23, resp.data.id.length);
                       // $cookieStore.put(selectedUserId, curr_conv_id); //only put the conv id
                        sessionStorage.setItem(selectedUserId,curr_conv_id);
                        console.log("conversation created=" + resp);
                        //get the conversation history(conv_id)
                        getConversationHistory(curr_conv_id);
                    },
                    function (err) {
                        //debugger;
                        console.log("error creating conversation=" + err.data + " mesg=" + err.data.message +
                            " property=" + err.data.data.property);
                    });

            } else {
                console.log("Picking current conversation id from cookies="+layer_conv_id);
                getConversationHistory(layer_conv_id);
            }
        };

        tabSelectionChanged = function(){
            $scope.chatList = [];
            if($scope.selectedGroup == "users"){
                req = {
                    url:  baseURL+"/api/user/myChatUsers",
                    method: "post",
                    data:{
                        userId: $rootScope.current_user.email
                    }
                };
                $http(req).then(function(resp){
                    console.log("user chat list loaded!");
                    //console.log(JSON.stringify(resp.data));
                    $scope.chatList = resp.data;
                },function(err){
                    console.log("error loading chat list");
                });

            }else if($scope.selectedGroup == "chats"){
               // debugger;
                var convList = sessionStorage.getItem("conv_list");
                if(convList != null) {
                    console.log("conv list not empty");
                    convList = JSON.parse(convList);
                    $scope.chatList = convList;
                }else{
                    $scope.chatList = $scope.convList;
                }
            }
        };

        /*helper functions*/
        getConversationHistory = function(layer_conv_id) {
            var convs = sessionStorage.getItem($scope.selectedUserID+"_chat");
            if(convs != null) {
                //json parse it
                convs = JSON.parse(convs);
                $scope.conversations = convs;
            }
            else{
                layerService.getConversationHistory(layer_conv_id).then(
                    function(resp){
                        if(resp.data.length > 0) {
                            populateConversation(resp.data,layer_conv_id);
                            console.log("conversation="+resp.data);
                            //$scope.conversations = resp.data;
                        }else{
                            console.log("No conversation found by Layer!");
                        }
                    },function(err){
                        console.log("Error in loading layer conversation="+JSON.stringify(err));
                    });
            }
        };
        populateConversation = function(conversations,layer_conv_id){
            var convs = [];
            console.log(JSON.stringify(conversations));
            for(i= (conversations.length - 1); i >=0 ; i--) {
                //top to bottom
                var item = conversations[i];
                if(item.parts[0].mime_type != "text/plain") {
                    var contentUrl = item.parts[0].content.download_url;
                    //since we are only sending either message or attachment, ignore part[0] i.e. message
                    var newMessage = {message: "Attachment", sender: item.sender.user_id, type: "attachment", url: contentUrl};
                    // get the download url
                    //var imageUrl = item.content.download_url;
                    convs.push(newMessage);
                } else {
                    var obj = { message: item.parts[0].body, sender: item.sender.user_id, type: "message" };
                    convs.push(obj);
                }
            }
            $scope.conversations = convs;
            sessionStorage.setItem($scope.selectedUserID+"_chat",JSON.stringify(convs));
            //save it to our backend so that it's available for us next time
            chatGoService.bulk_conv_history(convs, layer_conv_id).
                then(function(resp){
                    console.log("bulk conversation upload successful="+resp.data.message);
                },
                function(err) {
                    console.log("bulk conversation failure="+resp.data.message);
                }
            )
        };//populateConversation


        //called every time the page is loaded
        populateChatHeaders = function(){
            console.log("populateChatHeaders..");
            var convList = sessionStorage.getItem("conv_list");
            //if we have data then lets parse it back to json
            if (convList != null){
                convList = JSON.parse(convList);
            }
            //$scope.chatList = convList;

            layerService.listConversations().then(function(resp){
                addChatHeaders(resp,convList);
            },function(err){
                console.error("Error fetching layer conversation="+JSON.stringify(resp.data));
            }
            );
        };

        addChatHeaders = function(resp,convList){
            console.log("addChatHeaders()");
            if(resp.data.length > 0) {
             //if we have conversations
            //loop through the layer response json
                 angular.forEach(resp.data, function(item){
                    if(item.last_message != null){
                    //get the participant info
                        chatGoService.get_user_by_uid(item.participants[0])
                        .then(function(resp){
                            var u = resp.data;
                            //success we got the info, store the user data
                            var info = {id: u.id.Int64,
                                        first_name: u.first_name,
                                        last_name: u.last_name,
                                        email: u.email,
                                        avatar: u.avatar_url,
                                        uid: u.uid,
                                        last_message: item.last_message.parts[0].body,
                                        layer_conv_id: item.id.substring(23, item.id.length), //storing only the guid
                                        read_count: 0
                                    };
                            //check if convList is empty?
                            if(convList == null || convList == undefined) {
                                convList = [];
                                convList.push(info);
                                sessionStorage.setItem("conv_list",JSON.stringify(convList));

                            }else {
                                //push the item to list but see if we have not already added this
                                var conv = convList.filter(function (i) {
                                    return i.email == info.email; //watch=> this returns an array
                                });
                                if (conv.length == 0) {
                                    //if conv is empty, then it means this is a new conversation with a new user, add it
                                    convList.push(info);
                                    //  $scope.chatList = convList;
                                    sessionStorage.setItem("conv_list", JSON.stringify(convList));
                                    console.log("conversation item added=" + info);
                                }
                            }
                        },
                        function(err){
                            console.log("error fetching conversation="+JSON.stringify(err));
                        }
                        );
                    }
                });//end foreach

                $scope.chatList = convList;
                CheckScopeBeforeApply();

            }//end if
        };

        init = function(){
           //layerService.deleteConversation("5f824122-1b8b-4d5b-84b6-6e44e5ec487b");
           //subscribe
           messageListener.subscribe(newMessageObserver);
           messageListener.subscribe(newConversationObserver);
           $scope.selectedGroup = "chats";
           populateChatHeaders();

        };

        newMessageObserver = function(userId){
          console.log("newMessageObserver hit");
          var newMessage = this.channels.message;
          if($scope.selectedUserID == userId) {
              $scope.$apply(function(){
                  $scope.conversations = newMessage;
              });
          }else{
              var conv_list = sessionStorage.getItem("conv_list");
              if(conv_list != null) {
                  conv_list = JSON.parse(conv_list);
                  conv = conv_list.filter(function(item){
                     if(item.id == userId){
                         return true;
                     }
                  });
                  if(conv.length > 0) {
                      var read_count = conv[0].read_count;
                      read_count ++;
                      conv[0].read_count = read_count;
                      new_conv = [];
                      angular.forEach(conv_list,function(item){
                          if(item.id == conv[0].id){
                              new_conv.unshift(conv[0]);
                          }else{
                            new_conv.push(item);
                          }
                      });
                      sessionStorage.setItem("conv_list",JSON.stringify(new_conv));
                      if($scope.selectedGroup == "chats"){
                          $scope.$apply(function(){
                              $scope.chatList = new_conv;
                          });
                      }

                  }
              }
              console.log("incoming message for ="+userId);
          }
        };

        newConversationObserver = function(){
          console.log("newConversationObserver hit");
          var newConvList = this.channels.conversation;
          if($scope.selectedGroup == "chats"){
              $scope.$apply(function(){
                  $scope.chatList = newConvList;
              });
          }
        };

        CheckScopeBeforeApply = function() {
            if(!$scope.$$phase) {
                $scope.$apply();
            }
        };

        init();

    }]
);
