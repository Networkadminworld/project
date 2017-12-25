class Users::PasswordsController < Devise::PasswordsController
  layout "forgotpassword"
  prepend_before_filter :require_no_authentication
  # Render the #edit only if coming from a reset password email link
  append_before_filter :assert_reset_token_passed, :only => :edit
  layout 'home_page'
  respond_to :html, :xml, :json

  # GET /resource/password/new
  def new
    build_resource({})
  end

  # POST /resource/password
  def create
    user = User.where('users.email = ?', params[:user]["email"])
    if user.present?
      if user.first.parent_id == nil || user.first.parent_id == 0
        self.resource = resource_class.send_reset_password_instructions(params[:user])
        if successfully_sent?(resource)
          render json: success({success: "Email successfully sent."})
        else
          render json: failure({errors: "Email was not sent. Please try again later."})
        end
      else
        render json: failure({errors: "Please contact your Admin for this Service"})
      end
    else
      render json: failure({errors: "Please provide the valid email address."})
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    self.resource = resource_class.find_or_initialize_with_error_by(:reset_password_token, params[:reset_password_token])
    if resource.errors.empty?
      self.resource = resource_class.new
      resource.reset_password_token = params[:reset_password_token]
    else
      flash[:notice] = "Password already changed using this link."
      redirect_to root_path
    end
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, :location => after_sign_in_path_for(resource)
    else
      respond_with resource
    end
  end

  protected

  # The path used after sending reset password instructions
  def after_sending_reset_password_instructions_path_for(resource_name)
    new_session_path(resource_name)
  end

  # Check if a reset_password_token is provided in the request
  def assert_reset_token_passed
    if params[:reset_password_token].blank?
      set_flash_message(:error, :no_token)
      redirect_to new_session_path(resource_name)
    end
  end

  # Check if proper Lockable module methods are present & unlock strategy
  # allows to unlock resource on password reset
  def unlockable?(resource)
    resource.respond_to?(:unlock_access!) &&
        resource.respond_to?(:unlock_strategy_enabled?) &&
        resource.unlock_strategy_enabled?(:email)
  end
end