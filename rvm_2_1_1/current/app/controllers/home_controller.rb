class HomeController < ApplicationController
  skip_before_filter :authenticate_user!
  layout 'home_page'
  before_action :check_remember, only: [:index,:signin_form]
  skip_before_action :verify_authenticity_token,:only => [:signup_form], if: :json_request?

  def index
  end

  def signup_form
    @industry = IndustryTag.list
    respond_to do |format|
        format.js
        format.html
        format.json { render json: @industry }
    end
  end

  def enterprise_login
    @subdomain = request.subdomain
    if current_user
      redirect_to "#{ENV['CUSTOM_URL']}dashboard"
    end
  end

  def signin_form
    respond_to do |format|
        format.js
    end
  end

  def forgot_password_form
    respond_to do |format|
        format.js
    end
  end

  def save_referrer
    render :json => session[:request_referrer] = params[:referrer_url]
  end

  def fetch_short_url
    require 'rest-client'
    data = {url: params[:long_url], secret: ENV['SHORTEN_SECRET']}
    render :json => JSON.parse(RestClient.post ENV['SHORTEN_ENDPOINT'], data.to_json, :content_type => 'application/json')
  end

  private

  def check_remember
    @email = Base64.decode64(cookies[:auth_token]) if cookies[:auth_token]
    @pass =  Base64.decode64(cookies[:user_token]) if cookies[:user_token]
    @remember_me = cookies[:auth_token] && cookies[:user_token] ? true : false
  end

end
