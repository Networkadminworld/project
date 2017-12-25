$(document).ready(function(){
    jQuery("#search_user").click(function(){
        var email = jQuery("#search_user_email").val();
        $.ajax(
            {
                url : "/admin/client_settings/user_client_settings",
                type: "GET",
                data : {email: email} ,
                dataType: "script",
                success:function(data)
                {
                }
            });
    });
    /* Auto complete Valid email Address */
    $('#search_user_email').autocomplete({
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
})