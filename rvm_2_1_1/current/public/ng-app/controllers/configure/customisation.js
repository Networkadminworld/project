InquirlyApp.controller('CustomisationController', function($scope, $http, Upload) {
    var campaigns = this;
    campaigns.backgroundColor = '';
    campaigns.questionTxtColor = '';
    campaigns.answerTxtColor = '';
    campaigns.buttonTxtColor = '';
    campaigns.buttonBgColor = '';
    campaigns.font = '';

    $http.get('/configurations/get_campaign_styles').
        success(function(data, status, headers, config) {
            responseData(data);
        }).
        error(function(data, status, headers, config) {
            // log error
    });

    /* Background Image Preview */
    $scope.uploadPic = function(files) {
        if (files != null) {
            generateThumbAndUpload(files[0])
        }
    };

    function generateThumbAndUpload(file) {
        $scope.errorMsg = null;
        $scope.generateThumb(file);
    }

    $scope.generateThumb = function(file) {
        if (file != null) {
            if ($scope.fileReaderSupported && file.type.indexOf('image') > -1) {
                $timeout(function() {
                    var fileReader = new FileReader();
                    fileReader.readAsDataURL(file);
                    fileReader.onload = function(e) {
                        $timeout(function() {
                            file.dataUrl = e.target.result;
                        });
                    }
                });
            }
        }
    };

    function getFormInputs(){
        var customise = {};
        customise["customise"] = {};
        customise["customise"]["bgcolor"] = campaigns.backgroundColor;
        customise["customise"]["question_txt_color"] = campaigns.questionTxtColor;
        customise["customise"]["answer_txt_color"] = campaigns.answerTxtColor;
        customise["customise"]["button_txt_color"] = campaigns.buttonTxtColor;
        customise["customise"]["button_bg_color"] = campaigns.buttonBgColor;
        customise["customise"]["font_style_id"] = $scope.fontSelected["id"];
        return customise;
    }

    $scope.upload = function (files) {
        /* With File Upload */
        if (files){
            for (var i = 0; i < files.length; i++) {
                var file = files[i];
                $scope.upload = Upload.upload({
                    url: '/configurations/customise_campaign',
                    method: 'POST',
                    headers: {'X-CSRF-Token': $('meta[name=csrf-token]').attr('content')},
                    withCredentials: true,
                    fields: {
                        'customise[bgcolor]': campaigns.backgroundColor,
                        'customise[question_txt_color]': campaigns.questionTxtColor,
                        'customise[answer_txt_color]': campaigns.answerTxtColor,
                        'customise[button_txt_color]': campaigns.buttonTxtColor,
                        'customise[button_bg_color]': campaigns.buttonBgColor,
                        'customise[font_style_id]': $scope.fontSelected["id"]
                    },
                    file: file,
                    fileFormDataName: 'customise[bgimage]'
                }).success(function (data, status, headers, config) {
                        responseData(data);
                });
            }
        }else{
            /* Without File upload */
            $http.post('/configurations/customise_campaign', getFormInputs()).
                success(function(data, status, headers, config) {
                    responseData(data);
                }).
                error(function(data, status, headers, config) {
                    // log error
            });
        }
    };

    $scope.getFontName = function(font) {
        for(var i=0; i < $scope.fonts.length; i++){
            if($scope.fonts[i].id == font.id){
                return $scope.fonts[i].name;
            }
        }
    };

    $scope.fonts = [];

    /* Preview on create & Update */
    function responseData(data){
        var styleObj = JSON.parse(data.campaigns);
        $scope.bgImage = data.bg_image_path;
        $scope.fonts = data.fonts;
        $scope.fontSelected = { id: styleObj.font_style_id };
        if (styleObj != null) {
            campaigns.backgroundColor = styleObj.background;
            campaigns.questionTxtColor = styleObj.question_text;
            campaigns.answerTxtColor = styleObj.answer_text;
            campaigns.buttonTxtColor = styleObj.button_text;
            campaigns.buttonBgColor = styleObj.button_background;
        }
    }

    $scope.$watch(function () {
        $scope.backgroundColor = campaigns.backgroundColor;
        $scope.questionTxtColor = campaigns.questionTxtColor;
        $scope.answerTxtColor = campaigns.answerTxtColor;
        $scope.buttonTxtColor = campaigns.buttonTxtColor;
        $scope.buttonBgColor = campaigns.buttonBgColor;
    },true);
});