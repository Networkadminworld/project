   $(document).ready(function(){

       /* MultiSelect Business Option */

       var config = {
           '.chosen-select'           : {},
           '.chosen-select-deselect'  : {allow_single_deselect:true},
           '.chosen-select-no-single' : {disable_search_threshold:10},
           '.chosen-select-no-results': {no_results_text:'Oops, nothing found!'},
           '.chosen-select-width'     : {width:"95%"}
       };
       for (var selector in config) {
           $(selector).chosen(config[selector]);
       }

       /* Mobile Number only */

       $("#mobile-field").keypress(function (e) {
           if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
               return false;
           }
       });

       /* Create Service Executive user */

       $("#save-executive-user").click(function(){
           $.ajax({
               url:'/admin/manage_users',
               type:'POST',
               data:$("#user-form").serialize(),
               success:function(response){
                   if(response.errors){
                       var errors = response.errors;
                       $(".error").hide();
                       for (x in errors)
                           $('#error_'+x).html(errors[x][0]).show();
                   }else{
                       $(".error").hide();
                       $('#user-form').each(function(){ this.reset(); });
                       window.location.reload();
                   }
               }
           });
       });

       $("#update-user").click(function(){
           var form = $("#update-form");
           $.ajax({
               url:form.attr('data-url'),
               type:'PUT',
               data: form.serialize(),
               success:function(response){
                   if(response.errors){
                       var errors = response.errors;
                       $(".error").hide();
                       for (x in errors)
                           $('#error_'+x).html(errors[x][0]).show();
                   }else{
                       $(".error").hide();
                       $('#update-form').each(function(){ this.reset(); });
                       history.go(-1);
                   }
               }
           });
       });

       $('#createUser').on('hidden.bs.modal', function () {
           $(".error").hide();
       })
   });

   function resetUser(user_id,status){
       var label = status == 'true' ? ' de-activate ' : ' activate ';
       var title = 'Are you sure you want'+ label + 'this user?';
       $("#reset-user .modal-title").html(title);

       $("#deactivate-user").attr('user-id', user_id).attr('status',status);
       $('#reset-user').modal('show');
   }

   $(document).on("click", "#deactivate-user", function(event){
       var status = $(this).attr('status');
       var is_active = status != 'true';
       $(this).attr('disabled',true);
       $.ajax({
           url: '/admin/users/change_status',
           type:'POST',
           data: {user_id: $(this).attr('user-id'), is_active: is_active},
           success:function(response){
                   $('#reset-user').modal('hide');
                   window.location.href = '/admin/users';
                   $("#deactivate-user").attr('disabled',false);
           }
       });
   });
    
    