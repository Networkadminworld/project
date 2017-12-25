$(document).ready(function () {
    var status_switch = $('.user-status-switch');
    var status_dialog = $('#reset-client');

    status_switch.bootstrapSwitch({
        onText: 'Active',
        offText: 'Inactive',
        size: 'small'
    });

    status_switch.on('switchChange.bootstrapSwitch', function (e, data) {
        var id = this.id.split("-")[2];
        var status = $("#change-status-"+id).attr('data-status');
        $('.user-status-switch#change-status-'+id).bootstrapSwitch('state', !data, true);
        var label = status == 'true' ? ' de-activate ' : ' activate ';
        var title = 'Are you sure you want'+ label + 'this user?';
        $("#status-change-header").text(title);
        status_dialog.modal({
            backdrop: 'static',
            keyboard: false
        });

        status_dialog.on('show.bs.modal', function (event) {
            $("#deactivate-client").attr('user-id', id).attr('status',status);
        });
    });

    // Ajax function to de-activate/activate the client status

    $("#deactivate-client").click(function(event){
        var status = $(this).attr('status');
        var user_id = $(this).attr('user-id');
        if(user_id == ''){
            status_dialog.modal('show');
            $(this).click();
        }else{
            $(this).attr('disabled', true);
            var is_active = status != 'true';
            $.ajax({
                url: '/admin/manage_clients/change_client_status',
                type:'POST',
                data: { user_id: user_id, is_active: is_active },
                success:function(response){
                    status_dialog.modal('hide');
                    $(this).attr('disabled', false);
                    window.location.href = '/admin/manage_clients';
                }
            });
        }
    });

    var current_url = window.location.pathname.split('/');
    var position = window.location.pathname.split('/').length - 1;

    // This function validate the client attributes from the backend and save in database

    $("#client-form-submit").click(function(){
        var current = $(this);
        var first_name = $("#first_name").val();
        var last_name = $("#last_name").val();
        var email = $("#email").val();
        var mobile = $("#mobile").val();
        var password = $("#password").val();
        var password_confirmation = $("#password_confirmation").val();
        var role_id = $("#role_id").val();
        $.ajax({
            url: '/admin/manage_clients/save_client',
            method:'POST',
            dataType: 'JSON',
            data: {
                user: {
                    first_name: first_name,
                    last_name: last_name,
                    email: email,
                    mobile: mobile,
                    password: password,
                    password_confirmation: password_confirmation,
                    role_id: role_id
                }
            },
            success:function(response){
                serverResponse(response,'signup');
            }
        });
    });

    // This function validate the company inputs immediate after client data save also save
    // company tags in database.

    var industry_input = $("#industry_id");

    if(current_url[position] == 'client_company'){
        loadIndustryTag(industry_input.val(),false);
    }

    industry_input.change(function(){
        loadIndustryTag($(this).val(),true);
    });

    $("#client-company-form").click(function(){
        var company_name = $("#company_name").val();
        var company_address = $("#company_address").val();
        var industry_id = $("#industry_id").val();
        var tags = $("#tags").val();
        var user_id = $("#client_id").val();
        $.ajax({
            url: '/admin/manage_clients/save_client_company',
            method:'POST',
            dataType: 'JSON',
            data: {
                company: {
                    name: company_name,
                    address: company_address,
                    industry_id: industry_id,
                    user_id: user_id
                },
                tag_values: tags.split(",")
            },
            success:function(response){
                serverResponse(response,'company');
            }
        });
    });

    // This function fetch the pricing plan list from the backend also save client pricing plan in
    // database

    var pricing_plan = $("#pricing_plan_id");

    if(current_url[position] == 'client_pricing_plan'){
        loadPlanDetails(pricing_plan.val());
    }

    pricing_plan.change(function(){
        loadPlanDetails($(this).val());
    });

    // Duplicate should need to refactor

    $("#client-pricing-plan-form").click(function(){
        var plan_start_date = $("#start_date").val();
        var expiry_months = $("#expiry_in").val();
        var client_id = $("#client_id").val();
        if(plan_start_date != ''){
            $("#error_start_date").hide();
            savePlan(plan_start_date,expiry_months,client_id,'New',$(this))
        }else{
            $("#error_start_date").show();
        }
    });

    $("#update-client-pricing-plan-form").click(function(){
        var plan_start_date = $("#plan_start_date").val();
        var expiry_months = $("#expiry_in").val();
        var client_id = $("#client_id").val();
        var update_action = $("#update_action").val();
        if(plan_start_date != ''){
            $("#error_start_date").hide();
            savePlan(plan_start_date,expiry_months,client_id,update_action,$(this))
        }else{
            $("#error_start_date").show();
        }
    });

    $("#start_date").datepicker({
        showOn : "button",
        buttonImage : "/ng-app/Images/calendar.png",
        buttonImageOnly : true,
        dateFormat : 'yy/mm/dd',
        minDate: new Date()
    });

    $("#plan_start_date").datepicker({
        showOn : "button",
        buttonImage : "/ng-app/Images/calendar.png",
        buttonImageOnly : true,
        dateFormat : 'yy/mm/dd',
        minDate: $("#upgrade_min_date").val()
       });

    var pricing_plan_partial = $("#render_plan_detail");
    pricing_plan_partial.css('display','none');

    $("#show-hide-details").click(function(){
        var txt = $(this).text();
        if(txt == 'Show Details'){
            pricing_plan_partial.css('display','block');
            $(this).text('Hide Details');
        }else{
            $(this).text('Show Details');
            pricing_plan_partial.css('display','none');
        }
    });

    // Update client company details

    $("#update-client-company").click(function(){
        var company_id = $("#company_id").val();
        var company_name = $("#company_name").val();
        var company_address = $("#company_address").val();
        var industry_id = $("#industry_id").val();
        var tags = $("#tags").val();
        var user_id = $("#client_id").val();
        $.ajax({
            url: '/admin/manage_clients/update_client_company',
            method:'POST',
            dataType: 'JSON',
            data: {
                company: {
                    id: company_id,
                    name: company_name,
                    address: company_address,
                    industry_id: industry_id,
                    user_id: user_id
                },
                tag_values: tags.split(",")
            },
            success:function(response){
                serverResponse(response,'update_company');
            }
        });
    });

    // AutoComplete Client Email

    $('#search_client_email').autocomplete({
        autoFocus: true,
        source: "/payments/get_user_emails",
        messages: {
            noResults: '',
            results: function() {}
        },
        minLength: 1,
        focus: function (event, ui) {
            $(event).val(ui.item.label);
        },
        select: function (event, ui) {
            $(event).val(ui.item.label);
        }
    });
});

function serverResponse(response,step){
    if(response.status == 200){
        $(".error").hide();
        if(step == 'company'){
            window.location.href = '/admin/manage_clients/'+ response.user_id +'/client_pricing_plan'
        }else if(step  == 'signup'){
            window.location.href = '/admin/manage_clients/' + response.id +'/client_company'
        }else if(step == 'update_company'){
            window.location.href = '/admin/manage_clients/' + response.user_id +'/edit'
        } else{
            window.location.href = '/admin/manage_clients'
        }
    }else{
        var errors = response.errors;
        $(".error").hide();
        for (x in errors)
            $('#error_'+x).html(errors[x][0]).show();
    }
}

function loadIndustryTag(industry_id,is_change){
    var user_id = $("#client_id").val();
    var url = is_change ? '/companies/get_tags?industry_id='+industry_id : '/companies/get_tags?industry_id='+industry_id+'&user_id='+ user_id;
    var tags = $('#tags');
    $.ajax({
        url: url,
        method:'GET',
        dataType: 'JSON',
        success:function(response){
            var results = [];
            $.each(response, function( index, value ) {
                results.push(value.text);
            });
            tags.tagsinput('removeAll');
            tags.tagsinput('add', results.join(","));
        }
    });
}

function loadPlanDetails(plan_id){
    $.ajax({
        url: "/admin/manage_clients/plan_settings",
        type:"GET",
        data: {plan_id: plan_id},
        dataType: "script",
        success:function(data){

        }
    });
}

function resetClient(user_id,status){
    var label = status == 'true' ? ' de-activate ' : ' activate ';
    var title = 'Are you sure you want'+ label + 'this user?';
    $(".modal-title").html(title);

    $("#deactivate-client").attr('user-id', user_id).attr('status',status);
    $('#reset-client').modal('show');
}

function savePlan(plan_start_date,expiry_months,client_id,action,current_id){
    current_id.attr('disabled', true);
    $.ajax({
        url: '/admin/manage_clients/save_client_pricing_plan',
        method:'POST',
        dataType: 'JSON',
        data: {
            pricing_plan: {
                id: $("#pricing_plan_id").val(),
                start_date: plan_start_date,
                end_months: expiry_months,
                client_id: client_id,
                action: action,
                client_type: "User"
            }
        },
        success:function(response){
            serverResponse(response,'pricing_plan');
        }
    });
}

function loadClientPlanDetails(client_id){
    $.ajax({
        url: "/admin/manage_clients/client_plan_details",
        type:"GET",
        data: {client_id: client_id},
        dataType: "script",
        success:function(data){
            $("#client-plan-detail").modal('show');
        }
    });
}