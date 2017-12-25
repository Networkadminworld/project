require 'rubygems'
require 'twilio-ruby'
class InviteUser < ActionMailer::Base
  after_action :add_email_header

  def payment_success(email, first_name)
    @email = email
    @first_name = first_name
    mail(:to => email, :subject => "Payment Confirmation", :from => "no-reply@inquirly.com")
  end

  def subscription_notification(email, first_name, is_trial, remaining_days)
    @email = email
    @first_name = first_name
    msg = is_trial == true ? "Reminder to Upgrade Your Inquirly Account" : "Payment Reminder"
    rmg_text = remaining_days == 1 ? "#{remaining_days} day" : "#{remaining_days} days"
    @body_msg = is_trial == true ? "Trial period of your account will end after #{rmg_text}. Please upgrade your account." : "Your Inquirly account subscription will expire after #{rmg_text}. Please pay your subscription fee to continue using Inquirly features."
    mail(:to => email, :subject => msg, :from => "no-reply@inquirly.com")
  end

  def subscription_end_notification(email, first_name)
    @email = email
    @first_name = first_name
    mail(:to => email, :subject => "Subscription Notification", :from => "no-reply@inquirly.com")
  end

  def subscription_expired(email, first_name, bitly_url)
    @bitly_url=bitly_url
    @email = email
    @first_name = first_name
    mail(:to => email, :subject => "Subscription Expired", :from => "no-reply@inquirly.com")
  end

  def trial_expired(email, first_name, bitly_url)
    @bitly_url=bitly_url
    @email = email
    @first_name = first_name
    mail(:to => email, :subject => "Trial Period Expired", :from => "no-reply@inquirly.com")
  end

  def question_expired(user, question, rem_days)
    @user=user
    @question=question
    @remaining_days = rem_days == 1 ? "#{rem_days} day" : "#{rem_days} days"
    mail(:to => user.email, :subject => "Question Expiration", :from => "no-reply@inquirly.com")
  end

  def social_acc_exp(fb_user, twitter_user, linkedin_user, email, first_name)
    @fb_user = fb_user
    @twitter_user = twitter_user
    @linkedin_user =linkedin_user
    @current_user_email = email
    @first_name = first_name
    mail(:to => email, :subject => "Social Accounts Removed", :from => "no-reply@inquirly.com")
  end
  def import_company_data_status(user, success_count = 0, error_values = 0, total_record, data_create_status, remaining_records,error_list_path)
    @user_name = "#{user.first_name}"
    @email = user.email
    @imported_count = success_count
    @error_values = error_values
    @total_record = total_record
    @data_create_status = data_create_status
    @remaining_records = remaining_records
    attachments['customer_infos.csv'] = File.read(error_list_path) if error_values > 0
    mail(:to => @email, :subject => "Customer Information Upload Process Completed", :from => "no-reply@inquirly.com")
  end

  def csv_file_error_mail(user, csv_file_status)
    @user_name = "#{user.first_name}"
    @email = user.email
    @csv_file_status = csv_file_status
    mail(:to => @email, :subject => "CSV Upload Unsuccessful", :from => "no-reply@inquirly.com")
  end

  def campaign_unsuccessful(user,type,campaign)
    @email = user.email
    @cc_email = user.parent_id == 0 ? user.email : user.client.email
    @user_name = "#{user.first_name}"
    @type = type
    @campaign = campaign
    mail(:to => DEFAULTS["adm_group"], :subject => " #{user.email} have reached the maximum limit of #{type.upcase} quota",
              :from => "admin@inquirly.com")
  end

  def corporate_user_confirmation(user, admin_email, password)
    @first_name = user.first_name
    @email = user.email
    @password = password
    @admin_email = admin_email
    mail(:to => @email, :subject => "Welcome to Inquirly", :from => @admin_email)
  end

  def reset_user_password(user, admin_email, password)
    @first_name = user.first_name
    @email = user.email
    @password = password
    @admin_email = admin_email
    mail(:to => @email, :subject => "Inquirly - Password has been changed", :from => @admin_email)
  end

  def user_deactivation(user, admin_email, password=nil)
    @first_name = user.first_name
    @email = user.email
    @admin_email = user.parent_id == 0 ? 'admin@inquirly.com' : User.where(id: user.parent_id).first.email
    @status = user.is_active
    @role_name = user.role.try(:name)
    @tenant_name = user.tenant.try(:name)
    mail(:to => @email, :subject => "Admin Notification Email", :from => @admin_email)
  end

  def tenant_user_activation(user)
    @first_name = user.first_name
    @email = user.email
    @admin_email = user.client.email
    @role_name = user.role.try(:name)
    @tenant_name = user.tenant.try(:name)
    mail(:to => @email, :subject => "Admin Notification Email: Your account has been activated", :from => @admin_email)
  end

  def tenant_user_deactivation(user)
    @first_name = user.first_name
    @email = user.email
    @admin_email = user.client.email
    @role_name = user.role.try(:name)
    @tenant_name = user.tenant.try(:name)
    mail(:to => @email, :subject => "Admin Notification Email: Your account has been deactivated", :from => @admin_email)
  end

  def updated_user_details(user)
    @first_name = user.first_name
    @admin_email = user.parent_id == 0 ? 'admin@inquirly.com' : User.where(id: user.parent_id).first.email
    @email = user.email
    @status = user.is_active ? "Active" : "In-active"
    @role_name = Role.where(id: user.role_id).first.try(:name)
    @tenant_name = Tenant.where(id: user.tenant_id).first.try(:name)
    @company_name = user.company.try(:name)
    mail(:to => @email, :subject => "Admin Notification Email", :from => @admin_email)
  end

  def manage_executive_tenants(user,tenants)
    @first_name = user.first_name
    @admin_email = User.where(id: user.parent_id).first.email
    @email = user.email
    @status = user.is_active ? "Active" : "In-active"
    @role_name = Role.where(id: user.role_id).first.name
    @tenant_name = Tenant.where(id: user.tenant_id).first.name
    @tenants = tenants
    mail(:to => @email, :subject => "Admin Notification Email", :from => @admin_email)
  end

 def send_cancel_feed_back(user,params)
   @email = user.email
   @first_name = user.first_name 
   @last_name =  user.last_name
   @message = params[:message]
   mail(:to => "help@inquirly.com", :subject => "CC Avenue cancel Feedback", :from => @email)
 end

  def send_listener_share_email(user, params)
    @email = user.email
    @user_name = user.first_name + user.last_name
    @message = params[:share_message]
    @share_url  = params[:keywords_content]
    mail(:to => params[:share_email], :subject => params[:share_subject], :from => @email)
  end

  def admin_company_details(admin, user)
    @user_email = user.email
    @user_first_name = user.first_name
    @admin_first_name = admin.first_name
    @company_name = admin.company.try(:name)
    @admin_email = admin.email
    mail(:to => @admin_email, :subject => "Account Details changed", :from => @user_email)
  end

  def mandrill_email_report(user, email_report)
    @user_name = "#{user.first_name}"
    @email = user.email
    @email_report = email_report
    attachments['Email_report.csv'] = File.read("/tmp/report_#{ user.id }.csv") if email_report
    mail(:to => @email, :subject => "Email reports", :from => "no-reply@inquirly.com")
  end

  def twillo_calls_report(user)
    @user_name = "#{user.first_name}"
    @email = user.email
    attachments['Call_report.csv'] = File.read("/tmp/CallReport_#{ user.id }.csv") if File.exists?("/tmp/CallReport_#{ user.id }.csv")
    mail(:to => @email, :subject => "Make a call reports", :from => "no-reply@inquirly.com")
  end

  def share_detail_count_mismatch(user)
    mail(to: DEFAULTS["adm_group"], from: "no-reply@inquirly.com") do |format|
      format.text { render plain: "#{user.email} accounts share detail's question's count updated with mismatch count at #{Time.now} from #{ENV["CUSTOM_URL"]}" }
    end
  end

  def csv_copy_error_mail(user,type)
    @user_name = "#{user.first_name}"
    @email = user.email
    @type = type
    mail(:to => DEFAULTS["adm_group"], :subject => "#{type} Campaign process unsuccessful", :from => "no-reply@inquirly.com")
  end

  def on_board_invite(invite)
    @name = invite.name
    @email = invite.email
    mail(:to => DEFAULTS["support_emails"], :subject => "New invitation request on Inquirly", :from => "admin@inquirly.com")
  end

  private

  def add_email_header
    headers['X-MC-Important'] = "true"
  end
end
