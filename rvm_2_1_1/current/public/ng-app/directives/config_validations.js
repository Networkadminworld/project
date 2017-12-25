InquirlyApp.service('ConfigValidation', function($parse) {

    this.qrErrorResponse = function(data){
        var fieldState = { name: 'VALID', url: 'VALID' };

        if (data.errors.name){
            if (data.errors.name[0] == "has already been taken") fieldState.name = 'Name already exists';
        }else{
            fieldState.name = 'VALID';
        }
        if (data.errors.url){
            if (data.errors.url[0] == "is invalid") fieldState.url = 'Please enter valid URL';
        }else{
            fieldState.url = 'VALID';
        }
        return fieldState;
    };

    this.qrServerResponse = function(data,scope){
        var errorResponse = this.qrErrorResponse(data);
        for (var fieldName in errorResponse) {
            var message = errorResponse[fieldName];
            var serverMessage = $parse('form.selectedQrCode.'+fieldName+'.$error.serverMessage');

            if (message == 'VALID') {
                scope.form.qrcode.$setValidity(fieldName, true, scope.form.qrcode);
                serverMessage.assign(scope, undefined);
            }
            else {
                scope.form.qrcode.$setValidity(fieldName, false, scope.form.qrcode);
                serverMessage.assign(scope, errorResponse[fieldName]);
            }
        }
    }
});