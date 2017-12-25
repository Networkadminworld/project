require "spec_helper"

describe InviteUser do
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @user = FactoryGirl.create(:user, :default_biz_user)
    @user2 = FactoryGirl.create(:user, :subscribed_biz_user)
    @user3 = FactoryGirl.create(:user, :default_user)
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  describe "#payment_success" do
    it "must send payment success mail" do
      InviteUser.payment_success("kumaresan@railsfactory.org","testname").deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end

  describe "#subscription_notification" do
    it "must send subscription notification email" do
      InviteUser.subscription_notification("kumaresan@railsfactory.org","testname",true,0).deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end

  describe "#subscription_end_notification" do
    it "must send subscription end notification email" do
      InviteUser.subscription_end_notification("kumaresan@railsfactory.org","testname").deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end

  describe "#import_company_data_status" do
    it "must send import company data status" do
      InviteUser.import_company_data_status(@user, 10, 0, 10, true, 0).deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end
  
  describe "#csv_file_error_mail" do
    it "must send csv file error mail" do
      InviteUser.csv_file_error_mail(@user,false).deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end  
  
  describe "#corporate_user_confirmation" do
    it "must send corporate user confirmation" do
      InviteUser.corporate_user_confirmation(@user,"kumaresan@railsfactory.org", "12345678").deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end    
  
  describe "#reset_user_password" do
    it "must send reset user password" do
      InviteUser.reset_user_password(@user,"kumaresan@railsfactory.org", "12345678").deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end   

  describe "#user_deactivation" do
    it "must send user deactivation" do
      admin_user = FactoryGirl.create(:user, :admin_user)
      tenant = FactoryGirl.create(:tenant)
      user = FactoryGirl.create(:user, :facebook_user, :parent_id => admin_user.id, :tenant_id => tenant.id, :role_id => 4)        
      InviteUser.user_deactivation(user,"kumaresan@railsfactory.org", "12345678").deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end 
  
  describe "#updated_user_details" do
    it "must send updated user details" do
      admin_user = FactoryGirl.create(:user, :admin_user)
      tenant = FactoryGirl.create(:tenant)
      user = FactoryGirl.create(:user, :facebook_user, :parent_id => admin_user.id, :tenant_id => tenant.id, :role_id => 4)      
      InviteUser.updated_user_details(user).deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end  
  #~ describe "#assign_role" do
    #~ it "must send assign role" do
      #~ InviteUser.assign_role("kumaresan@railsfactory.org","Individual", @user).deliver
      #~ ActionMailer::Base.deliveries.count.should == 1
    #~ end
  #~ end  
  
  #~ describe "#tenant_user_notification" do
    #~ it "must send tenant user notification" do
      #~ InviteUser.tenant_user_notification(@user,"test_name", @user2).deliver
      #~ ActionMailer::Base.deliveries.count.should == 1
    #~ end
  #~ end   
  
  #~ describe "#tenant_user_remove_notification" do
    #~ it "must send tenant user remove notification" do
      #~ InviteUser.tenant_user_remove_notification(@user, @user2).deliver
      #~ ActionMailer::Base.deliveries.count.should == 1
    #~ end
  #~ end   
  #~ describe "#email_share" do
    #~ it "should send email share mail" do
      #~ email = "kumaresan@railsfactory.org"
      #~ subject = "Testing email share"
      #~ message = "Hpe that you have received this message"
      #~ custom_url = "http://google.com"
      #~ question_logo = "http://www.thesearchagents.com/wp-content/uploads/2013/11/Google-Search.jpg"
      #~ bitly_url = "http://bitly.com"
      #~ current_user_email = "info@railsfactory.org"
      #~ InviteUser.email_share(email,subject,message, custom_url, question_logo, current_user_email, bitly_url).deliver
      #~ ActionMailer::Base.deliveries.count.should == 1
    #~ end
  #~ end
  describe "#manage_executive_tenants" do
    it "must send manage executive tenants" do
      admin_user = FactoryGirl.create(:user, :admin_user)
      tenant = FactoryGirl.create(:tenant)
      user = FactoryGirl.create(:user, :facebook_user, :parent_id => admin_user.id, :tenant_id => tenant.id, :role_id => 4)
      InviteUser.manage_executive_tenants(user, [tenant]).deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end   

  describe "#send_listener_share_email" do
    it "must send send listener_ hare email" do
      params = {:share_message => "Welcome inquirly Test", :keywords_content => 'show', :share_email => 'kumaresan@railsfactory.org', :share_subject => "Listener test mail"}
      InviteUser.send_listener_share_email(@user, params).deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end

  describe "#send_cancel_feed_back" do
    it "must send cancel feedback" do
      params = {:message => "Welcome inquirly Test"}
      InviteUser.send_cancel_feed_back(@user, params).deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end
  
  describe "#admin_company_details" do
    it "must send admin company details" do
      admin_user = FactoryGirl.create(:user, :admin_user)
      user = FactoryGirl.create(:user, :facebook_user, :parent_id => admin_user.id)
      InviteUser.admin_company_details(admin_user, user).deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end   

  describe "#mandrill_email_report" do
    it "must send mandrill email report" do
      InviteUser.mandrill_email_report(@user, false).deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end
  
  describe "#twillo_calls_report" do
    it "must send twillo calls report" do
      InviteUser.twillo_calls_report(@user).deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end
  
  describe "#subscription_expired" do
    it "must send subscribtion expired email" do
      InviteUser.subscription_expired("kumaresan@railsfactory.org", "http://bitly.com","testname").deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end

  describe "#trial_expired" do
    it "must send trial expired" do
      InviteUser.trial_expired("kumaresan@railsfactory.org", "http://bitly.com","testname").deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end

  describe "#social_acc_exp" do
    it "must send social account expiration email" do
      fb_user = @user
      twitter_user = @user2
      linkedin_user = @user3
      email = "kumaresan@railsfactory.org"
      InviteUser.social_acc_exp([fb_user],[twitter_user],[linkedin_user],email,"testname").deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end
end