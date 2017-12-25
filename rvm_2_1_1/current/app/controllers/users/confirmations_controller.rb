class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation/new
  def new
    build_resource({})
  end

  # POST /resource/confirmation
  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)

    if successfully_sent?(resource)
      respond_with({}, :location => after_resend_confirmation_path(resource_name))
    else
      respond_with(resource)
    end
  end

  # GET /resource/confirmation?confirmation_token=
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
     if self.resource.errors.messages[:password].present?
        self.resource.save(:validate => false)
       self.resource.errors.clear
     end
    if resource.errors.empty?
      self.resource.authentication_token = SecureRandom.hex(12)
      self.resource.save(:validate => false)
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      sign_in(resource_name, resource)
      BusinessCustomerInfo.sub_account_create(resource)
      resource.create_action_list
      AlertScript.new.create_alert_config(resource)
      session[:user_permissions] = resource.permissions
      flash[:notice]="Your account has been confirmed successfully."
      respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource,params["pay"]) }
    else
      flash[:notice]= "Your account has already been confirmed."
      redirect_to root_path
    end
  end

  protected

  def after_resend_confirmation_path(resource_name)
    new_session_path(resource_name)
  end

  def after_confirmation_path_for(resource_name, resource,pay_status)
    after_sign_in_path_for(resource,pay_status)
  end

end
