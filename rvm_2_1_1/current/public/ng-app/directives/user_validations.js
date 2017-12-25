InquirlyApp.service('UserValidations', function($parse) {
	this.serverErrorResponse = function(data){
        var fieldState = {first_name: 'VALID', last_name: 'VALID', email: 'VALID', tenant_id: 'VALID', role_id: 'VALID', mobile: 'VALID',password_confirmation: 'VALID' };
        if (data == "success"){
    		fieldState.first_name = 'VALID';
    		fieldState.last_name = 'VALID';
    		fieldState.email = 'VALID';
			fieldState.role_id = 'VALID';
            fieldState.mobile =  'VALID';
            fieldState.password_confirmation = 'VALID';
    	}else{
    		if (data.errors.first_name){
	            if (data.errors.first_name[0] == " Please enter first name.")  fieldState.first_name = 'Please enter your first name.';
	            if (data.errors.first_name[0] == "First name should be min 2 and max 20 characters.") fieldState.first_name = 'First name should be min 2 and max 20 characters.';
	            if (data.errors.first_name[0] == "First Name should not have special characters") fieldState.first_name = 'First Name should not have special characters';
	        }else{
	            fieldState.first_name = 'VALID';
	        }

	        if (data.errors.last_name){
	            if (data.errors.last_name[0] == "Please enter last name.") fieldState.last_name = 'Please enter your last name.';
	            if (data.errors.last_name[0] == "Last name should be min 2 and max 20 characters.") fieldState.last_name = 'Last name should be min 2 and max 20 characters.';
	            if (data.errors.last_name[0] == "Last Name should not have special characters") fieldState.last_name = 'Last Name should not have special characters';
	        }else{
	            fieldState.last_name = 'VALID';
	        }

	        if (data.errors.email){
	            if (data.errors.email[0] == "Please enter your email address.") fieldState.email = "Please enter your email address.";
	            if (data.errors.email[0] == "Email address already exists.") fieldState.email = "Email address already exists.";
	            if (data.errors.email[0] == "Please enter a valid email address.") fieldState.email = "Please enter a valid email address.";
	        }else{
	            fieldState.email = 'VALID';
	        }

            if (data.errors.mobile){
                if (data.errors.mobile[0] == "is invalid") fieldState.mobile= 'Invalid mobile number';
                if (data.errors.mobile[0] == 'Mobile number length should be min 8 and max 15 characters.') fieldState.mobile= 'Length should be min 8 and max 15 characters.';
            }else{
                fieldState.mobile = 'VALID';
            }

	        if (data.errors.role_id){
	            if (data.errors.role_id[0] == "Select a Role Name.") fieldState.role_id = "Select a Role Name.";
	        }else{
	            fieldState.role_id = 'VALID';
	        }

            if(data.errors.password_confirmation){
                if (data.errors.password_confirmation[0] == "Your passwords should match.") fieldState.password_confirmation = "Your passwords should match.";
                if (data.errors.password_confirmation[0] == "Please enter confirm password.") fieldState.password_confirmation = "Please enter confirm password.";
            }else{
                fieldState.password_confirmation= 'VALID';
            }
    	}

        return fieldState;
    };

    this.serverResponse = function(data,scope){
    	if (data.success == "Your account was updated successfully."){
    		var serverResponse = {first_name: 'VALID', last_name: 'VALID', email: 'VALID', mobile: 'VALID', password_confirmation: 'VALID'};
    	}else{
	    	var serverResponse = this.serverErrorResponse(data);
    	}
    	for (var fieldName in serverResponse) {
	            var message = serverResponse[fieldName];
	            var serverMessage = $parse('form.userForm.'+fieldName+'.$error.serverMessage');
	            if (message == 'VALID') {
	                scope.form.userForm.$setValidity(fieldName, true, scope.form.userForm);
	                serverMessage.assign(scope, undefined);
	            }
	            else {
	                scope.form.userForm.$setValidity(fieldName, false, scope.form.userForm);
	                serverMessage.assign(scope, serverResponse[fieldName]);
	            }
	        }
    }
}); 