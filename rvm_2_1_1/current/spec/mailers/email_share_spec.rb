require "spec_helper"

describe EmailShare do
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @user = FactoryGirl.create(:user, :default_biz_user, :id => 50000)
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  describe "#email_share" do
    #~ it "Should send the test email campaign" do
       #~ email_array = [{"email" => "kumaresh.btech09@gmail.com", "bitly_url" => "http://inquirly.com"},{"email" => "kumait10resh@gmail.com", "bitly_url" => "http://inquirly.com"},{"email" => "kumareshc10@gmail.com", "bitly_url" => "http://inquirly.com"}]
       #~ subject = "Testing test email share"
       #~ message_content = "Aw! Take me to your supreme leader"
       #~ question_image = "http://www.thesearchagents.com/wp-content/uploads/2013/11/Google-Search.jpg"
       #~ current_user_email = @user.email
       #~ current_user_company_name = @user.company_name
       #~ is_html = false
       #~ EmailShare.email_share(email_array,subject,message_content,current_user_email, question_image,current_user_company_name,@user,1,is_html)
       #~ ActionMailer::Base.deliveries.count.should == 0
    #~ end
    #~ it "Should send the test html campaign" do
      #~ email_array = [{"email" => "kumaresh.btech09@gmail.com", "bitly_url" => "http://inquirly.com"},{"email" => "kumait10resh@gmail.com", "bitly_url" => "http://inquirly.com"},{"email" => "kumareshc10@gmail.com", "bitly_url" => "http://inquirly.com"}]
      #~ subject = "Testing html email share"
      #~ message_content = "Aw! Take me to your supreme leader"
      #~ question_image = "http://www.thesearchagents.com/wp-content/uploads/2013/11/Google-Search.jpg"
      #~ current_user_email = @user.email
      #~ current_user_company_name = @user.company_name
      #~ is_html = true
      #~ EmailShare.email_share(email_array,subject,message_content,current_user_email, question_image,current_user_company_name,@user,1,is_html)
      #~ ActionMailer::Base.deliveries.count.should == 0
    #~ end
    #~ it "Should throw mandrill to address format error" do
      #~ email_array = ["kumaresh.btech09@gmail.com"]
      #~ subject = "Testing html email share"
      #~ message_content = "Aw! Take me to your supreme leader"
      #~ question_image = "http://www.thesearchagents.com/wp-content/uploads/2013/11/Google-Search.jpg"
      #~ current_user_email = @user.email
      #~ current_user_company_name = @user.company_name
      #~ is_html = true
      #~ EmailShare.email_share(email_array,subject,message_content,current_user_email, question_image,current_user_company_name,@user,1,is_html)
      #~ ActionMailer::Base.deliveries.count.should == 0
    #~ end
  end
end