class DashboardController < ApplicationController
  before_action :authenticate_user_web_api
  before_action :check_client, only: [:user_engaged_results, :planner_details, :post_reviews, :alerts, :post_revision]
  respond_to :json

  def index
    session[:client_id] = session[:is_service_user] ? params[:client_id] :  current_user.id
    details = CommandCenter::EngagementInfo.new(session[:client_id],session[:is_service_user] && session[:client_id] ? current_user.id : '').over_the_time
    render :json => {channels: details[0], campaigns: details[1], company_logo: details[2], company_name: details[3], client_email: details[4]}
  end

  def get_businesses_info
    render :json => Company.business_details(params)
  end

  def get_piwik_info
    render :json => Company.piwik_info(@current_user)
  end 
   
  def user_engaged_results
    render :json => User.over_all_engaged(params,@current_user)
  end

  def planner_details
    render :json => CommandCenter::PlannerDetail.new(params[:client_user_id],params[:service_user_id],session[:is_service_user],params[:current_date],params[:time_zone]).planner_details
  end

  def post_reviews
    render :json => CommandCenter::PostReview.new(params[:client_user_id],params[:service_user_id],params[:limit],params[:offset],params[:filter_by]).posts
  end

  def post_revision
    render :json => CommandCenter::PostRevision.new(params[:client_user_id],params[:service_user_id],params[:limit],params[:offset],params[:filter_by]).revisions
  end

  def alerts
    render :json => CommandCenter::AlertLogDetail.new(params[:client_user_id],params[:service_user_id],params[:limit], params[:offset]).results
  end

  def get_revision_info
    render :json =>  Revision.find_revision_notes(params)
  end

  private

  def check_client
    params[:client_user_id] = session[:is_service_user] && session[:client_id] ?  session[:client_id] : current_user.id
    params[:service_user_id] = session[:is_service_user] && session[:client_id] ?   current_user.id : ''
  end
end