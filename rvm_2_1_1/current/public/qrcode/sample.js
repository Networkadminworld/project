var draw_qrcode = function(text, typeNumber, errorCorrectLevel) {
	document.write(create_qrcode(text, typeNumber, errorCorrectLevel) );
};
var create_qrcode = function(text, typeNumber, errorCorrectLevel, table) {
	var qr = qrcode(typeNumber || 4, errorCorrectLevel || 'M');
	qr.addData(text);
	qr.make();

//	return qr.createTableTag();
	return qr.createImgTag();
};
var update_qrcode = function() {
    var qr_code_text = document.getElementById("txt_qr_code").value;
//    if(qr_code_text != ""){
      qr_code_text.replace(/^[\s\u3000]+|[\s\u3000]+$/g, '');
	  document.getElementById('qr').innerHTML = create_qrcode(qr_code_text);
      var url = jQuery("#qr img").attr("src");
      if(url){url = url.replace(/^data:image\/[^;]/, 'data:application/octet-stream');}
      jQuery("#qr_code_download").attr("href",url);
//    }
};
