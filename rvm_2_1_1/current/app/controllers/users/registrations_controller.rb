class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, :only => [:new, :create]
  respond_to :html, :xml, :json
  layout "application_angular"

  def new
    resource = build_resource({})
    respond_with resource
  end

  def create
    build_resource
    if resource.valid? && params[:user][:industry].present?
      if resource.save
        resource.update_industry params[:user][:industry]
        resource.update_pricing_plan(params)
        active_for_authentications
        respond_to do |format|
          format.json { render :json => success({:user => resource, :confirmation_token => resource.confirmation_token,:message => "Welcome! You have signed up successfully."}) }
        end
      end
    else
      respond_to do |format|
        format.json { render :json => failure({:resource => resource.errors}) }
      end
    end
  end

  protected

  def active_for_authentications
    if resource.active_for_authentication?
      set_flash_message :notice, :signed_up if is_navigational_format?
      sign_up(resource_name, resource)
    else
      set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
      expire_session_data_after_sign_in!
    end
  end


  def update_needs_confirmation?(resource, previous)
    resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation? && previous != resource.unconfirmed_email
  end

  def build_resource(hash=nil)
    hash ||= resource_params || {}
    self.resource = resource_class.new_with_session(hash.merge(:exp_date => Time.now + 14.days, :is_active => true, :step => "5"), session)
  end

  def sign_up(resource_name, resource)
    sign_in(resource_name, resource)
  end

  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end

  def authenticate_scope!
    send(:"authenticate_#{resource_name}!", :force => true)
    self.resource = send(:"current_#{resource_name}")
  end

  def valid_email?(email)
    email.match(/\A[A-Za-z0-9._%+-]+@(?:[A-Za-z0-9-]+\.){1,2}[A-Za-z]{2,4}\Z/i) ? true : false
  end

  def resource_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password,:company_name,:first_name,:last_name,:business_type_id,:parent_id, :role_id,:step,:redirect_url,:from_number)
  end

  private :resource_params
end
