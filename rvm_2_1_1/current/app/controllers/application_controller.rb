class ApplicationController < ActionController::Base
  include AbstractController::Helpers::ClassMethods
  include ActionView::Helpers::DateHelper
  before_filter :verified_request?
  protect_from_forgery
  before_filter :set_session
  respond_to :xml
  layout :resolve_layout

  def add_cors_headers
    origin = request.headers["Origin"]
    #byebug
    Rails.logger.info("[LOG] Adding Rails headers with origin=#{request.headers.inspect}")
    unless (not origin.nil?) and (origin == "http://localhost" or origin.starts_with? "http://localhost:")
      origin = "https://api.layer.com"
    end
    headers['Access-Control-Allow-Origin'] = origin
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS, PUT, DELETE'
    allow_headers = request.headers["Access-Control-Request-Headers"]
    if allow_headers.nil?
      #shouldn't happen, but better be safe
      origin = "https://api.layer.com"
      allow_headers = 'Origin, Authorization, Accept, Content-Type'
    end
    headers['Access-Control-Allow-Headers'] = allow_headers
    headers['Access-Control-Allow-Credentials'] = 'true'
    headers['Access-Control-Max-Age'] = '1728000'
  end

  def check_role_level_permissions
    if current_user && current_user.role && session[:user_permissions].blank?
       session[:user_permissions] = Permission.define_permissions(current_user)
       unless session[:user_permissions]["#{params[:controller]}"]
           render json: {error: "#{APP_MSG['authorization']['failure']}", status: 400} if request.format.json?
       end
    end
  end

  def after_sign_in_path_for(resource,pay_status='false')
    "/"
  end

  def invalid_url
    redirect_to "#{request.protocol}#{request.host_with_port}/404.html"
  end

  def failure(body = nil)
    api_header("400", "Sorry,Record not found", body)
  end

  def success(body = nil)
    api_header("200", "Successfully completed", body)
  end

  def failure_authentication(body = nil)
    api_header("1005", "Invalid token", body)
  end

  def failure_token_missing(body = nil)
    api_header("1020", "Authentication token missing", body)
  end

  def unauthorized(body = nil)
    api_header("401", "unauthorized access", body)
  end

  def api_header(status=nil, message=nil, body=nil)
   {:header => {:status => status.to_i}, :body => body.present? ? body : {:errors => "#{message}"} }
  end


  def json_request?
    request.format.json?
  end

  def require_no_authentication
    assert_is_devise_resource!
    return unless is_navigational_format?
    no_input = devise_mapping.no_input_strategies
    authenticated = if no_input.present?
                      args = no_input.dup.push :scope => resource_name
                      warden.authenticate?(*args)
                    else
                      warden.authenticated?(resource_name)
                    end

    if authenticated && resource == warden.user(resource_name)
      flash[:alert] = I18n.t("devise.failure.already_authenticated")
      redirect_to after_sign_in_path_for(resource)
    end
  end

  def verified_request?
    if request.content_type == "application/json"
      true
    else
      super()
    end
  end

  def valid_email?(email)
    reg = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
    (reg.match(email)) ? true : false
  end

  def home
    redirect_to "/admin/permissions" if current_user && current_user.admin?
    redirect_to "/" unless current_user
  end

  def check_admin_user
    redirect_to "/" if current_user && !current_user.admin?
  end

  protected

  def set_session
    $_SESSION = session
  end

  private

  def bitly_url
    @bitly = Bitly.client
  end

  def authenticate_user_web_api
    params[:authentication_token] = params[:authenticity_token] if params[:authenticity_token].present?
    @current_user = User.check_user_auth_confirmed(params[:authentication_token])
    @current_user = current_user  unless @current_user.present?
    unless @current_user
      respond_to do |format|
        format.html { redirect_to "/", :notice => "You are not logged in. Please log in" }
        format.json { render :json => unauthorized }
      end
    end
  end

  def catch_exceptions
    yield
  rescue => exception
    ExceptionNotifier::Notifier.exception_notification(request.env, exception).deliver
    if exception.is_a?(ActiveRecord::RecordNotFound)
      render :file => "#{Rails.root}/public/404.html", :layout => false, :status => :not_found
    else
      render :file => "#{Rails.root}/public/500.html", :layout => false, :status => :not_found
    end
  end

  def resolve_layout
    case action_name
      when "home"
        "application_angular"
      else
        "application"
    end
  end

end