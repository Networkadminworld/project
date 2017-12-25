
InquirlyApp.service('messageListener',['$rootScope','$cookieStore','chatGoService','$location',function($rootScope,$cookieStore,chatGoService,$location){
    var service = this;
    service.channels = {
        message: [],
        conversation:[]
    };

    service.callbacks = [];
    service.subscribe = function(callback){
      if(typeof callback == "function"){
          console.log("messagecallback set");
          service.callbacks.push(callback);
      }
    };

    service.initWebSock = function(){
        init();
        console.log("websocket init()");
        //websocket listeners
        var webSock = new WebSocket("wss://api.layer.com/websocket?session_token="+$cookieStore.get("_layer_s_token"),"layer-1.0");
        webSock.onerror = function(evt){
            console.error("error opening websocket:"+JSON.stringify(evt));
            console.log("retrying websocket every 10 sec");
             setTimeout(function () {
            // Connection has closed so try to reconnect every 10 seconds.
               var webSock = new WebSocket("wss://api.layer.com/websocket?session_token="+$cookieStore.get("_layer_s_token"),"layer-1.0");
            }, 10*1000);
        };
        webSock.onopen = function(evt) {
            console.log("websocket initialized-"+JSON.stringify(evt));
        };
        webSock.onmessage = function(evt){
            console.log("WEBSOCKET:"+evt.data)
            service.handleMessage(JSON.parse(evt.data));
        };
        webSock.onclose = function(evt){
            console.error("websocket is closed..retrying..");
            setTimeout(function () {
            // Connection has closed so try to reconnect every 10 seconds.
               var webSock = new WebSocket("wss://api.layer.com/websocket?session_token="+$cookieStore.get("_layer_s_token"),"layer-1.0");
            }, 10*1000);
        };
    };

    service.handleMessage = function(data) {
        console.log("websocket:incoming");
        //load existing conversation list
        var conv_list = sessionStorage.getItem("conv_list");
        if (data.type == "change" && data.body.operation == "create" && data.body.object.type == "Message" && data.body.data.sender.user_id != $rootScope.current_user.userId) {
            console.log("New incoming message");
            //this is an incoming chat, possibly towards an existing conv
            var convListExistsButThisIsNew = true;
            //get the incoming layer conversation id
            var layer_conv_id = data.body.data.conversation.id.substring(23, data.body.data.conversation.id.length);
            //jsonify string array
            if (conv_list != null) {
                conv_list = JSON.parse(conv_list);
                angular.forEach(conv_list, function (c) {
                    //check, if the conversation list has this chat
                    if (c.layer_conv_id == layer_conv_id) {
                        //get the corresponding chat and add the new message
                        convListExistsButThisIsNew = false;
                        messages = sessionStorage.getItem(c.id + "_chat");
                        //if for some reason message
                        if (messages != null) {
                            messages = JSON.parse(messages);
                            var item = {
                                message: data.body.data.parts[0].body,
                                sender: data.body.data.sender.user_id,
                                type: "message"
                            };
                            messages.push(item);
                            sessionStorage.setItem(c.id + "_chat", JSON.stringify(messages));
                            //service.channels.message = [];//empty the existing list
                            service.channels.message = messages;
                            console.log("pushed new message");
                            if(service.callbacks[0] != null) {
                                service.callbacks[0].call(service, c.id);
                            }
                            console.log("new message-" + JSON.stringify(item));

                        } else {
                            //if for some reason chat doesn't exist for this conversation
                            console.log("no corresponding message found for incoming=" + data.body.data.sender.user_id);
                            messages = [];
                            messages.push({
                                message: data.body.data.parts[0].body,
                                sender: data.body.data.sender.user_id,
                                type: "message"
                            });
                            sessionStorage.setItem(c.id + "_chat", JSON.stringify(messages));
                            service.channels.message = [];
                            service.channels.message = messages;
                            if(service.callbacks[0] !=null) {
                                service.callbacks[0].call(service, c.id);
                            }
                            console.log("pushed new message");
                        }
                        if($location.url() != "/messages/index") {
                            var info = {first_name: c.first_name, last_name: c.last_name, avatar: c.avatar};
                            showNotification(info);
                        }
                    }
                });//end forEach
                //if we came out of looping and convListExistsButThisIsNew == true,
                //then this is a new incoming message on new conversation
                if (convListExistsButThisIsNew) {
                    service.addChatHeader(data, layer_conv_id, conv_list);
                }
            }else{
                //conv_list is null, that means it's the first conversation of the user
                service.addChatHeader(data,layer_conv_id,conv_list);
            }
        }
    };

    service.addChatHeader = function(data, layer_conv_id, conv_list) {
        //first add a conv_list entry in the session
        var sender = data.body.data.sender.user_id;
        //get this senders details from backend
        chatGoService.get_user_by_uid(sender).then(function (resp) {
            var u = resp.data;
            //success we got the info, store the user data
            var info = {
                id: u.id.Int64,
                first_name: u.first_name,
                last_name: u.last_name,
                email: u.email,
                avatar: u.avatar_url,
                uid: u.uid,
                last_message: null,
                layer_conv_id: layer_conv_id, //storing only the guid
                read_count:0
            };
            if(conv_list == null){
                conv_list = [];
            }
            conv_list.push(info);
            //replace the conv_list
            sessionStorage.setItem("conv_list", JSON.stringify(conv_list));
            if($location.url() != "/messages/index") {
                showNotification(info);
            }
            //update chatList for view
            service.channels.conversation = [];
            service.channels.conversation = conv_list;
            if(service.callbacks[1] != null) {
                service.callbacks[1].call(service);
            }

        });
    };

    init = function(){
        var Notification = window.Notification || window.mozNotification || window.webkitNotification;
        Notification.requestPermission(function (permission) {
            console.log(permission);
        });
    };

     showNotification = function(info){
        if (info.first_name == undefined) {
            var instance = new Notification(
                "New Message", {
                    body: info.email,
                    icon: info.avatar
                }
            );
        } else {
            var instance = new Notification(
                "New Message", {
                    body: info.first_name + " " + info.last_name,
                    icon: info.avatar
                }
            );
        }

    };
    return service;
}]);