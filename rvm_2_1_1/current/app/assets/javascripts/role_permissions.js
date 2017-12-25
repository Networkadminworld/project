$(document).ready(function() {
    var parent = $(".parent-select");
    var child = $(".sub_case");
    parent.not("[data-switch-no-init]").bootstrapSwitch();
    child.not("[data-switch-no-init]").bootstrapSwitch();

    parent.click(function () {
         var id = this.id.split("_")[1];
         var child_id = "#sub_feature_index_" + id;
         var parent_id = "#feature_" + id + "_access_level";
         var is_checked = jQuery(parent_id).is(':checked');
         if(is_checked)
         {
           $(child_id).find('input[type=checkbox]').each(function() {
                this.checked = true;
           });
         }
         else
         {
            $(child_id).find('input[type=checkbox]').each(function() {
                this.checked = false;
            });
         }
    });

    child.click(function(){
        var id = this.id.split("_")[2];
        var child_id = "#sub_feature_index_" + id;
        var parent_id = "#feature_" + id + "_access_level";
        if($(child_id).children().length == $(child_id).find('input[type=checkbox]:checked').length) {
              $(parent_id).prop('checked', true);

        } else {
              $(parent_id).prop('checked', false);
        }
    });
});
