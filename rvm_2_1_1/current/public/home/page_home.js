///////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////	Home Page //////////////////////////////////////////////////////


$(document).ready(function() {
	
	// Question example slideshow
	$('#example_slideshow').cycle({
	  fx: 'fade', 
    timeout: 4500
	});
	

	// Lightbox images
	$('#screen_preview_1').click(function() {
	    $('#screen_preview_image_1').lightbox_me({
	        centered: true
	    });
	});
	
	$('#screen_preview_2').click(function() {
	    $('#screen_preview_image_2').lightbox_me({
	        centered: true
	    });
	});
	
	$('#screen_preview_3').click(function() {
	    $('#screen_preview_image_3').lightbox_me({
	        centered: true
	    });
	});

});


///////////////////////// END Home page //////////////////////////////////
/////////////////////////////////////////////////////////////////////////