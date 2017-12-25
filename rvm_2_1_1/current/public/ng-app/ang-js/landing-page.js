jQuery(document).ready(function(){

  /* SIGN IN */
  var pathName = window.location.pathname;

  if(pathName != '/shorten_link'){
      jQuery.ajax({
        beforeSend: function(xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        type: "POST",
        url: "/home/save_referrer",
        data: {referrer_url: window.location.href},
        success: function(data){}
      });
  }

  if(pathName == '/shorten_link'){
      document.title = 'Shorten | Inquirly';
  }else{
      document.title = 'SignIn | Inquirly';
  }

  jQuery("#login-submit").click(function(){
    var loginButton = $(this);
    loginButton.prop('disabled', true);
    loginButton.html("<i class='fa fa-spinner fa-spin'></i> LOGIN");
    var email = jQuery("#email").val();
    var password = jQuery("#password").val();
    var rememberMe = jQuery("#remember-me").val();


    var login_params = { user: {email: email, password: password, remember_me: rememberMe } };
    jQuery.ajax({
        beforeSend: function(xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        type: "POST",
        url: "/users/login",
        data: login_params,
        success: function(data){
            if (data.header.status == 200)
            {
                if (data.body.role == true)
                {
                    $(".alert").hide();
                    window.location.href = "/admin/permissions";
                }
                else
                {
                    $(".alert").hide();
                    sessionStorage.permissions = JSON.stringify(data.body.permissions);
                    window.location.href = data.referrer_path;
                    window.location.reload();
                }
            }
            else
            {
                loginButton.prop('disabled', false);
                loginButton.html("LOGIN");
                $("#email").focus();
                $(".alert").html('<a href="javascript:void(0);" onclick="closeAlert();" class="close">×</a>'+data.body.errors).show();
            }
        }
    });
    return false;
  });

  jQuery("#shorten-submit").click(function(e){
      e.preventDefault();
      var longUrl = jQuery("#long-url");
      if(longUrl.val() == ''){
          jQuery("#result-url").css('color','red').text('Please enter valid URL');
      }else{
          jQuery.ajax({
              beforeSend: function(xhr) { xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
              type: "POST",
              url: "/home/fetch_short_url",
              data: {long_url: longUrl.val()},
              success: function(data){
                  if(data.status == 'success'){
                      jQuery("#result-url").css('color','green').text(data.short_url);
                      longUrl.val('');
                  }
              }
          });
      }
  });

    if($("#remember-me").val() == "true") { jQuery('#remember-checkbox').removeClass('fa-square-o').addClass('fa-check-square-o'); }
});

function render_sign_up_form()
{
    document.title = 'SignUp | Inquirly';
    jQuery.ajax({
      type: "get",
      url: "/home/signup"
    });
 }

function render_sign_in_form()
{
    document.title = 'SignIn | Inquirly';
    jQuery.ajax({
      type: "get",
      url: "/home/signin"
    });
 }

function render_forgot_password_form()
{
    document.title = 'Forgot Password | Inquirly';
    jQuery.ajax({
      type: "get",
      url: "/home/forgot_password"
    });
}

function closeAlert(){
    jQuery(".alert").hide();
}

function selectRemember(){
    var remember = $("#remember-me");
    if(remember.val() == '' || remember.val() == false || remember.val() == "false"){
        remember.val(true);
        jQuery('#remember-checkbox').removeClass('fa-square-o').addClass('fa-check-square-o');
    }else{
        remember.val(false);
        jQuery('#remember-checkbox').removeClass('fa-check-square-o').addClass('fa-square-o');
    }
}