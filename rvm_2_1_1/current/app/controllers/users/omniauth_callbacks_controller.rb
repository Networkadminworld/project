class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :check_exist_account, only: [:twitter, :linkedin]

  include ApplicationHelper
  include OmniauthSocialStrategy

  def google
    response = request.env["omniauth.auth"]
    account = UserSocialChannel.account_exist?(current_user,request.env["omniauth.auth"])
    if account.blank?
      @add_user = UserSocialChannel.create_account(current_user,request.env["omniauth.auth"],request.env["omniauth.auth"].info.image)
      if @add_user
        success_msg("#/configure/social",'google', 1)
      else
        success_msg("#/configure/social",'google', 2)
      end
    else
      success_msg("#/configure/social",'google', 3)
    end
  end

  def facebook
    path = "#/configure/social"
    response = request.env["omniauth.auth"]
    type_change = response.info.image.split("type")
    normal_image = type_change.first + "type=normal"
    fb_user,existing_accounts = existing_fb_details(current_user,response)
    if existing_accounts.blank? && fb_user.accounts.count == 0
      UserSocialChannel.create_account(current_user,response,normal_image)
      success_msg(path,response.provider, 1)
    else
      save_account_json(current_user,existing_accounts,response,normal_image)
      save_page_json(response,existing_accounts,current_user)
      path = "#/configure/social?source=facebook&page=true"
      success_msg(path,response.provider, 1)
    end
  end

  def save_account_json(user,exist_accounts,response,image)
    session[:fb_account] = []
    unless exist_accounts.include?(UserSocialChannel.social_uid(response))
      session[:fb_account] << { user_id: user.id, channel: response.provider, email: UserSocialChannel.email_address(response), social_id: UserSocialChannel.social_uid(response),
                              social_token: response.credentials.token, name: UserSocialChannel.profile_name(response), profile_image: image, active: true }
    end
  end

  def save_page_json(response,exist_accounts,user)
    session[:fb_pages] = []
    list = []
    fb_user = FbGraph2::User.me(response.credentials.token)
    admin_id = UserSocialChannel.where(user_id: user.id, social_id: response.uid).last.try(:id)
    list << fb_user.accounts unless fb_user.accounts.blank?
    list << fb_user.accounts.next unless fb_user.accounts.next.blank?
    list << fb_user.accounts.next.next unless fb_user.accounts.next.next.blank?
    list << fb_user.accounts.next.next.next unless fb_user.accounts.next.next.next.blank?
    list.each do |accounts|
      accounts.each do |account|
        attributes = account.raw_attributes
        session[:fb_pages] << pages_json(attributes,user,admin_id) unless exist_accounts.include?(attributes['id'])
      end
    end
  end

  def save_fb_pages
    selected_params = params[:pages] || []
    save_account(session[:fb_account]) if params[:account]
    selected_pages = session[:fb_pages].select { |page| selected_params.include? (page["social_id"])}
    selected_pages.each { |page| UserSocialChannel.create_pages(page) }
    session[:fb_pages] = []
    session[:fb_account] = []
    render :json => 200
  end

  def save_account(session_data)
    UserSocialChannel.create_fb(session_data.first)
  end

  def fb_pages
    render :json => [session[:fb_pages],session[:fb_account]]
  end

  def remove_fb_session
    session[:fb_pages] = []
    session[:fb_account] = []
    render :json => { status: 200 }
  end

  def twitter
    if @account.blank?
      @add_user = UserSocialChannel.create_account(current_user,@response,@response.info.image)
      if @add_user
        success_msg("#/configure/social",@response.provider, 1)
      else
        success_msg("#/configure/social",@response.provider, 2)
      end
    else
      update_status(@account,@response.provider,@response) unless @account.active
      success_msg("#/configure/social",@response.provider, 3)
    end
  end

  def linkedin
    path = "#/configure/social"
    exist_account,exist_company_page_ids,company_list = existing_ln_details(current_user,@response,@response.credentials.token)
    if exist_account.blank? &&  company_list["_total"] == 0
      if @account.blank?
        @add_user = UserSocialChannel.create_account(current_user,@response,@response.info.image)
        if @add_user
          success_msg(path,@response.provider, 1)
        else
          success_msg(path,@response.provider, 2)
        end
      else
        update_status(@account,@response.provider,@response) unless @account.active
        success_msg("#/configure/social",@response.provider, 3)
      end
    else
      company_admin_account_json(current_user,exist_account,@response)
      company_page_json(@response,exist_company_page_ids,current_user,company_list,@response.credentials.token)
      path = "#/configure/social?source=linkedin&page=true"
      success_msg(path,"linkedin", 1)
    end
  end

  def company_admin_account_json(user,exist_account,response)
    session[:linkedin_account] = []
    unless exist_account.include?(response.uid)
      session[:linkedin_account] << { user_id: user.id,
                                      channel: response.provider,
                                      email: UserSocialChannel.email_address(response),
                                      social_id: response.uid,
                                      social_token: response.credentials.token,
                                      name: UserSocialChannel.profile_name(response),
                                      profile_image: response.info.image, active: true }
    end
  end

  def company_page_json(response,exist_page_ids,user,company_list,access_token)
    session[:linkedin_page] = []
    if company_list["_total"] > 0
      company_list["values"].each do |value|
        session[:linkedin_page] << linkedin_page_json(user,value,response,access_token) unless exist_page_ids.include?(value["id"])
      end
    end
  end

  def linkedin_pages
    render :json => [session[:linkedin_page],session[:linkedin_account]]
  end

  def remove_linkedin_session
    session[:linkedin_page] = []
    session[:linkedin_account] = []
    render :json => { status: 200 }
  end

  def save_linkedin_pages
    selected_params = params[:pages] || []
    save_linkedin_account(session[:linkedin_account],false) if params[:account]
    selected_pages = session[:linkedin_page].select { |page| selected_params.include? (page["company_id"])}
    selected_pages.each { |page|  UserSocialChannel.create_linkedin(page,true) }
    session[:linkedin_page] = []
    session[:linkedin_account] = []
    render :json => 200
  end

  def save_linkedin_account(session_data,is_page)
    UserSocialChannel.create_linkedin(session_data.first,is_page)
  end


  def failure
    redirect_to root_url, alert: "Your social media account authentication has failed."
  end

  private

  def check_exist_account
    @response =  request.env["omniauth.auth"]
    @account = UserSocialChannel.account_exist?(current_user, @response)
  end

  def success_msg(redirect_path,provider_name, response_code)
    case response_code
      when 1
        msg = {"message" => "#{provider_name.capitalize} account added successfully."}
      when 2
        msg = {"message" => "User not added"}
      when 3
        msg = {"message" => "This #{provider_name.capitalize} account already exists."}
      else
        msg = {"message" => ""}
    end
    response = response_code == 1 ? msg.merge({"message_type"=> "success"}) : msg.merge({"message_type"=> "danger"})
    cookies[:error_message] = JSON.generate(response)
    redirect_to redirect_path
  end

  def update_status(account,channel,response)
    save_result = { user_id: account.user_id, channel: response.provider, email: UserSocialChannel.email_address(response), social_id: UserSocialChannel.social_uid(response),
      social_token: response.credentials.token, name: UserSocialChannel.profile_name(response), profile_image: response.info.image }
    account.update_auth_props(save_result)
  end

  def pages_json(attributes,user,admin_id)
    json = {}
    json[:profile_image] = "https://graph.facebook.com/#{attributes['id']}/picture?access_token=#{attributes['access_token']}"
    json[:name] = attributes['name']
    json[:social_token] = attributes['access_token']
    json[:social_id] = attributes['id']
    json[:channel] = "facebook"
    json[:user_id] = user.id
    json[:is_page] = true
    json[:admin_id] = admin_id
    json.stringify_keys!
  end

  def linkedin_page_json(user,value,response,access_token)
    json = {}
    json[:profile_image] = JSON.parse(RestClient.get("https://api.linkedin.com/v1/companies/#{value['id']}:(id,square-logo-url)?oauth2_access_token=#{access_token}&format=json"))["squareLogoUrl"]
    json[:name] = value['name']
    json[:social_token] = response.credentials.token
    json[:social_id] = response.uid
    json[:channel] = "linkedin"
    json[:user_id] = user.id
    json[:is_page] = true
    json[:company_id] = value['id']
    json[:admin_id] = 0
    json.stringify_keys!
  end

end