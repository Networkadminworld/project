class Users::SessionsController < Devise::SessionsController
  respond_to :html, :xml, :json
  prepend_before_filter :require_no_authentication, :only => [:new, :create]
  prepend_before_filter :allow_params_authentication!, :only => :create
  layout 'home_page'
  include ErpSessionData
  prepend_before_filter { request.env["devise.skip_timeout"] = true }

  # GET /resource/sign_in
  def new
    self.resource = build_resource(nil, :unsafe => true)
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource))
  end

  # POST /resource/sign_in
  def create
    resource = User.find_by_email(params[:user][:email])
    resource,params[:user][:password] = create_enterprise_user(params[:user]) if resource.blank? && params[:user][:is_sso] == 'true'
    respond_to do |format|
      check_valid_user = params[:user][:is_sso] == 'true' ? resource.present? : (resource.present? && resource.valid_password?(params[:user][:password]))
      if check_valid_user
        if resource.confirmed? &&  !resource.locked_at && resource.is_active
          set_flash_message(:notice, :signed_in) if is_navigational_format?
          sign_in(resource_name, resource)
          resource.ensure_authentication_token!
          resource.create_action_list
          resource.update_alert_config unless resource.admin
          session[:user_permissions] = resource.permissions unless resource.admin
          session[:user_info] = resource.session_info unless resource.admin
          session[:is_service_user] = resource.role.try(:service_user_role)
          erp_session_data(resource) if params[:user][:is_sso] == 'true'
          if params[:user][:remember_me] == "true"
            cookies.permanent[:auth_token] =  Base64.encode64(resource.email)
            cookies.permanent[:user_token] = Base64.encode64(params[:user][:password])
          else
            cookies.delete(:auth_token)
            cookies.delete(:user_token)
          end
          format.json { render :json => success({:success => true,:user_id => resource.id,
                                                 :auth_token => resource.authentication_token,
                                                 :email => resource.email,
                                                 :first_name => resource.first_name,
                                                 :last_name => resource.last_name,
                                                 :role => resource.admin,
                                                 :_session_id => session.id,
                                                 :permissions => session[:user_permissions],
                                                 referrer_path: session[:request_referrer] })}
          format.html { admin_permissions_path(:auth_token => resource.authentication_token,:notice => flash[:notice])} if resource.email == ENV["ADMIN_EMAIL"] 
        else
          format.json { render :json => failure({:errors => failure_msg(resource) })}
        end
      else
        format.json { render :json => failure({:errors => failure_msg(resource) }) }
        format.html {redirect_to "#{ENV["INQUIRLY_LIVE"]}&error=#{failure_msg(resource)}"}
      end
    end
  end

  def create_enterprise_user(params)
    client_details = User.where(email: params[:client_email]).first
    resource, password = nil, nil
    if client_details
      tenant = Tenant.create(name: params[:tenant_name], address: params[:tenant_address], client_id: client_details.id, redirect_url: client_details.redirect_url, from_number: client_details.from_number)
      params[:tenant_id] = tenant.id
      params[:parent_id] = client_details.id
      params[:role_id] = 5 #Default Executive Role
      resource, password,admin = User.create_corp_user(params)
      resource.save
    end
    [resource,password]
  end

  def validate_user_data
    endpoint = EnterpriseApiEndpoint.subdomain params[:subdomain]
    data = RestClient.post(endpoint.login_path, :username => params[:username], :password => params[:password])
    session[:subdomain] = params[:subdomain] if data
    render :json =>  JSON.parse(data)
  end

  # DELETE /resource/sign_out
  def destroy
    session[:user_permissions] = {}
    session[:user_info] = {}
    resource = current_user
    if resource.present?
      resource.update_attribute(:authentication_token,nil)
      signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    end
    respond_to do |format|
      if resource.present?
        format.js {render :js => "window.location = '#{ENV['INQUIRLY_LIVE']}'"}
        format.html { redirect_to ENV["INQUIRLY_LIVE"], :notice => signed_out && is_navigational_format? && !params[:time_out] ? "Signed out successfully." : params[:notice]}
        format.json {render :json => success({:success => "successfully logout."})}
      else
        format.html { redirect_to ENV["INQUIRLY_LIVE"] }
        format.json {render :json => { :header => {:status => "error"}, :body => {:message => "session does not exist"} }}
      end
    end
  end

  protected

  def allow_params_authentication!
    request.env["devise.allow_params_authentication"] = true
  end

  def serialize_options(resource)
    methods = resource_class.authentication_keys.dup
    methods = methods.keys if methods.is_a?(Hash)
    methods << :password if resource.respond_to?(:password)
    {:methods => methods, :only => [:password]}
  end

  def auth_options
    {:scope => resource_name, :recall => "#{controller_path}#new"}
  end

  def failure_msg(resource)
    if resource && resource.locked_at
      "Your account is locked. Please check your email."
    elsif resource && !resource.is_active
      "Your account is deactivated. Please contact #{resource.client ? resource.client.email : ENV["ADMIN_EMAIL"]} for the access."
    else
      resource && !resource.confirmed? ? 'Your email address is either incorrect or not yet confirmed. Please update or confirm your e-mail address.' : "Invalid email or password."
    end
  end
end

