module Api
  class EmailContent
	  def self.html_content
      "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
		<html xmlns='http://www.w3.org/1999/xhtml'>
		<head>
		  <meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
		  <title>*|SUBJECT|*</title>
		  <style type='text/css'>
		      #outlook a{
		      padding:0;
		    }
		    body{
		      width:100% !important;
		    }
		    .ReadMsgBody{
		      width:100%;
		    }
		    .ExternalClass{
		      width:100%;
		    }
		    body{
		      -webkit-text-size-adjust:none;
		    }
		    body{
		      margin:0;
		      padding:0;
		    }
		    img{
		      border:0;
		      height:auto;
		      line-height:100%;
		      outline:none;
		      text-decoration:none;
		    }
		    table td{
		      border-collapse:collapse;
		    }
		    #backgroundTable{
		      height:100% !important;
		      margin:0;
		      padding:0;
		      width:100% !important;
		    }
		/*
		@tab Page
		@section background color
		@tip Set the background color for your email. You may want to choose one that matches your company's branding.
		*/
		body,#backgroundTable{
		  /*@editable*/background-color:#FAFAFA;
		}
		/*
		@tab Page
		@section heading 1
		@tip Set the styling for all first-level headings in your emails. These should be the largest of your headings.
		@style heading 1
		*/
		h1,.h1{
		  /*@editable*/color:#505050;
		  display:block;
		  /*@editable*/font-family:Helvetica;
		  /*@editable*/font-size:30px;
		  /*@editable*/font-weight:normal;
		  /*@editable*/line-height:100%;
		  margin-top:0;
		  margin-right:0;
		  margin-bottom:10px;
		  margin-left:0;
		  /*@editable*/text-align:left;
		}
		/*
		@tab Page
		@section heading 2
		@tip Set the styling for all second-level headings in your emails.
		@style heading 2
		*/
		h2,.h2{
		  /*@editable*/color:#505050;
		  display:block;
		  /*@editable*/font-family:Helvetica;
		  /*@editable*/font-size:24px;
		  /*@editable*/font-weight:normal;
		  /*@editable*/line-height:100%;
		  margin-top:0;
		  margin-right:0;
		  margin-bottom:10px;
		  margin-left:0;
		  /*@editable*/text-align:left;
		}
		/*
		@tab Page
		@section heading 3
		@tip Set the styling for all third-level headings in your emails.
		@style heading 3
		*/
		h3,.h3{
		  /*@editable*/color:#505050;
		  display:block;
		  /*@editable*/font-family:Helvetica;
		  /*@editable*/font-size:20px;
		  /*@editable*/font-weight:normal;
		  /*@editable*/line-height:100%;
		  margin-top:0;
		  margin-right:0;
		  margin-bottom:10px;
		  margin-left:0;
		  /*@editable*/text-align:left;
		}
		/*
		@tab Page
		@section heading 4
		@tip Set the styling for all fourth-level headings in your emails. These should be the smallest of your headings.
		@style heading 4
		*/
		h4,.h4{
		  /*@editable*/color:#505050;
		  display:block;
		  /*@editable*/font-family:Helvetica;
		  /*@editable*/font-size:16px;
		  /*@editable*/font-weight:bold;
		  /*@editable*/line-height:100%;
		  margin-top:0;
		  margin-right:0;
		  margin-bottom:10px;
		  margin-left:0;
		  /*@editable*/text-align:left;
		}
		/*
		@tab Header
		@section preheader style
		@tip Set the background color for your email's preheader area.
		*/
		#templatePreheader{
		  /*@editable*/background-color:#F5F5F5;
		  /*@editable*/border-bottom:1px solid #CCCCCC;
		}
		/*
		@tab Header
		@section preheader text
		@tip Set the styling for your email's preheader text. Choose a size and color that is easy to read.
		*/
		.preheaderContent div{
		  /*@editable*/color:#505050;
		  /*@editable*/font-family:Helvetica;
		  /*@editable*/font-size:10px;
		  /*@editable*/line-height:100%;
		  /*@editable*/text-align:left;
		}
		/*
		@tab Header
		@section preheader link
		@tip Set the styling for your email's preheader links. Choose a color that helps them stand out from your text.
		*/
		.preheaderContent div a:link,.preheaderContent div a:visited,.preheaderContent div a .yshortcuts {
		  /*@editable*/color:#0DB297;
		  /*@editable*/font-weight:normal;
		  /*@editable*/text-decoration:underline;
		}
		/*
		@tab Header
		@section upper header style
		@tip Set the background color for your email's upper header area.
		*/
		#upperTemplateHeader{
		  /*@editable*/background-color:#FAFAFA;
		  padding-top:30px;
		  padding-bottom:30px;
		}
		/*
		@tab Header
		@section upper header text
		@tip Set the styling for your email's header text. Choose a size and color that is easy to read.
		*/
		.upperHeaderContent{
		  /*@editable*/color:#505050;
		  /*@editable*/font-family:Helvetica;
		  /*@editable*/font-size:34px;
		  /*@editable*/font-weight:normal;
		  /*@editable*/line-height:100%;
		  /*@editable*/padding-top:0;
		  /*@editable*/padding-right:0;
		  /*@editable*/padding-bottom:0;
		  /*@editable*/vertical-align:middle;
		}
		/*
		@tab Header
		@section upper header link
		@tip Set the styling for your email's upper header links. Choose a color that helps them stand out from your text.
		*/
		.upperHeaderContent a:link,.upperHeaderContent a:visited,.upperHeaderContent a .yshortcuts {
		  /*@editable*/color:#0DB297;
		  /*@editable*/font-weight:normal;
		  /*@editable*/text-decoration:none;
		}
		/*
		@tab Header
		@section lower header style
		@tip Set the background color for your email's lower header area.
		@theme page
		*/
		#lowerTemplateHeader{/*@editable*/
		  background-color:#eeeeee;
		  padding: 30px 15px;
		  color: #7b7a7a;
		  border-bottom: 1px solid #d1d1d1;
		}
		/*
		@tab Header
		@section lower header text
		@tip Set the styling for your email's lower header text. Choose a size and color that is easy to read.
		*/
		.lowerHeaderContent{
		  /*@editable*/color:#505050;
		  /*@editable*/font-family:Helvetica;
		  /*@editable*/font-size:34px;
		  /*@editable*/font-weight:normal;
		  /*@editable*/line-height:100%;
		  /*@editable*/vertical-align:middle;
		}
		/*
		@tab Header
		@section lower header link
		@tip Set the styling for your email's lower header links. Choose a color that helps them stand out from your text.
		*/
		.lowerHeaderContent a:link,.lowerHeaderContent a:visited,.lowerHeaderContent a .yshortcuts {
		  /*@editable*/color:#FFFFFF;
		  /*@editable*/font-weight:normal;
		  /*@editable*/text-decoration:underline;
		}
		#headerImage{
		  height:auto;
		  max-width:600px;
		}
		/*
		@tab Columns
		@section left column text
		@tip Set the styling for your email's left column text. Choose a size and color that is easy to read.
		*/
		.leftColumnContent div{
		  /*@editable*/color:#505050;
		  /*@editable*/font-family:Helvetica;
		  /*@editable*/font-size:14px;
		  /*@editable*/line-height:150%;
		  /*@editable*/text-align:left;
		}
		/*
		@tab Columns
		@section left column link
		@tip Set the styling for your email's left column links. Choose a color that helps them stand out from your text.
		*/
		.leftColumnContent div a:link,.leftColumnContent div a:visited,.leftColumnContent div a .yshortcuts {
		  /*@editable*/color:#0DB297;
		  /*@editable*/font-weight:normal;
		  /*@editable*/text-decoration:underline;
		}
		.leftColumnContent img{
		  display:inline;
		  height:auto;
		}
		/*
		@tab Columns
		@section center column text
		@tip Set the styling for your email's center column text. Choose a size and color that is easy to read.
		*/
		.centerColumnContent div{
		  /*@editable*/color:#505050;
		  /*@editable*/font-family:Helvetica;
		  /*@editable*/font-size:13px;
		  /*@editable*/line-height:150%;
		  /*@editable*/text-align:left;
		}
		/*
		@tab Columns
		@section center column link
		@tip Set the styling for your email's center column links. Choose a color that helps them stand out from your text.
		*/
		.centerColumnContent div a:link,.centerColumnContent div a:visited,.centerColumnContent div a .yshortcuts {
		  /*@editable*/color:#0DB297;
		  /*@editable*/font-weight:normal;
		  /*@editable*/text-decoration:underline;
		}
		.centerColumnContent img{
		  display:inline;
		  height:auto;
		}
		/*
		@tab Columns
		@section right column text
		@tip Set the styling for your email's right column text. Choose a size and color that is easy to read.
		*/
		.rightColumnContent div{
		  /*@editable*/color:#505050;
		  /*@editable*/font-family:Helvetica;
		  /*@editable*/font-size:13px;
		  /*@editable*/line-height:150%;
		  /*@editable*/text-align:left;
		}
		/*
		@tab Columns
		@section right column link
		@tip Set the styling for your email's right column links. Choose a color that helps them stand out from your text.
		*/
		.rightColumnContent div a:link,.rightColumnContent div a:visited,.rightColumnContent div a .yshortcuts {
		  /*@editable*/color:#0DB297;
		  /*@editable*/font-weight:normal;
		  /*@editable*/text-decoration:underline;
		}
		.rightColumnContent img{
		  display:inline;
		  height:auto;
		}
		/*
		@tab Body
		@section body style
		@tip Set the bottom border for your email's body area.
		@theme footer
		*/
		#templateBodyWrapper{
		  /*@editable*/
		  min-height: 300px;
		  padding: 0 0 40px;
		}
		/*
		@tab Body
		@section body text
		@tip Set the styling for your email's main content text. Choose a size and color that is easy to read.
		@theme main
		*/
		.bodyContent div{
		  /*@editable*/color:#505050;
		  /*@editable*/font-family:Helvetica;
		  /*@editable*/font-size:14px;
		  /*@editable*/line-height:150%;
		  /*@editable*/text-align:left;
		}
		/*
		@tab Body
		@section body link
		@tip Set the styling for your email's main content links. Choose a color that helps them stand out from your text.
		*/
		.bodyContent div a:link,.bodyContent div a:visited,.bodyContent div a .yshortcuts {
		  /*@editable*/color:#0DB297;
		  /*@editable*/font-weight:normal;
		  /*@editable*/text-decoration:underline;
		}
		.bodyContent img{
		  display:inline;
		  height:auto;
		}
		/*
		@tab Footer
		@section footer style
		@tip Set the background color and top border for your email's footer area.
		@theme footer
		*/
		#templateFooter{
		  /*@editable*/background-color:#717170;
		  /*@editable*/border-top:2px solid #222426;
		}
		/*
		@tab Footer
		@section footer text
		@tip Set the styling for your email's footer text. Choose a size and color that is easy to read.
		@theme footer
		*/
		.footerContent div{
		  /*@editable*/color:#ffffff;
		  /*@editable*/font-family:Helvetica;
		  /*@editable*/font-size:12px;
		  /*@editable*/line-height:125%;
		  /*@editable*/text-align:left;
		  padding-left: 15px;
		}
		/*
		@tab Footer
		@section footer link
		@tip Set the styling for your email's footer links. Choose a color that helps them stand out from your text.
		*/
		.footerContent div a:link,.footerContent div a:visited,.footerContent div a .yshortcuts {
		  /*@editable*/color:#909090;
		  /*@editable*/font-weight:normal;
		  /*@editable*/text-decoration:underline;
		}
		.footerContent img{
		  display:inline;
		}
		/*
		@tab Footer
		@section social bar style
		@tip Set the text alignment for your email's footer social bar.
		*/
		#social div{
		  /*@editable*/text-align:left;
		}
		/*
		@tab Footer
		@section utility bar style
		@tip Set the text alignment for your email's footer utility bar.
		*/
		#utility div{
		  /*@editable*/text-align:left;
		}
		#monkeyRewards img{
		  max-width:190px;
		}
		.bottom-line{
		  margin-top: 30px;
		  padding: 10px 15px 0 15px;
		  border-top: 1px solid #d1d1d1;
		}
		.email-body-content{
		  padding: 0 15px;
		}
		      .HeaderWrapper{
			  overflow: hidden;
		      }
		      .Headerlogo{
			  float: left;
		      }
		      .HeaderCompanyName{
			  float: left;
			  margin: 20px 0 0 20px;
		      }
		</style>
		</head>
		<body leftmargin='0' marginwidth='0' topmargin='0' marginheight='0' offset='0'>
		  <center>
		    <table border='0' cellpadding='0' cellspacing='0' height='100%' width='100%' id='backgroundTable'>
		      <tr>
			<td align='center' valign='top' id='templateBodyWrapper'>
			  <!-- // Begin Template Body \\ -->
			  <table border='0' cellpadding='0' cellspacing='0' width='90%' id='templateBody'>
			    <tr>
			      <td colspan='3' valign='top' style='padding-top:20px;'>
				<table border='0' cellpadding='0' cellspacing='0' width='100%'>
				  <tr>
				    <td colspan='3' valign='top' class='bodyContent'>
				      <!-- // Begin Module: Standard Content \\ -->
				      <table border='0' cellpadding='0' cellspacing='0' width='100%'>
					<tr>
					  <td valign='top'></td>
					    <div mc:edit='header' style='padding: 15px;'>
					      *|CONTENT|*
					    </div>
					    <p><span mc:edit='main' style='color:#0191a9;'></span></p>
					</tr>
				      </table>
				      <!-- // End Module: Standard Content \\ -->
				    </td>
				  </tr>
				</table>
			      </td>
			    </tr>
			  </table>
			  <!-- // End Template Body \\ -->
			</td>
		      </tr>
		    </table>
		  </center>
		</body>
		</html>"
	  end
  end
end