class PowerShareController < ApplicationController
	include MetaDataCollection
  skip_before_action :authenticate_user_web_api, only: [:campaign_share,:show, :remove_schedule, :fetch_meta_data]
  before_action :authenticate_user, except: [:campaign_share,:show,:remove_schedule,:get_campaign_channels, :fetch_meta_data]
  before_action :check_role_level_permissions, only: [:social_accounts, :share_content]
  before_action :identify_user, only: [:campaign_share, :remove_schedule, :get_campaign_channels, :get_reach]
  before_action :check_valid_pricing_plan, only: [:campaign_share]

  layout "application_angular"

	def social_accounts
    social_info,mobile,in_location = UserChannel.all_channels(current_user)
    company_name = current_user.company.try(:name)
    from_email = current_user.from_email
		render :json => { social_accounts: social_info, mobile_accounts: mobile, in_location_accounts: in_location, default_tags: default_search_tags, company: company_name, sender_email: from_email }
  end

  def get_reach
    reach = UserChannel.reach_calculation(@current_user,params)
    render :json => {current_reach: reach, reaches: in_percentage(reach,params)}
  end

  def fetch_meta_data
    twitter, open_graph = fetch preview_params["url"]
    render :json => {twitter: twitter, open_graph: open_graph, long_url: preview_params["url"]}
  end

  def share_content
    begin
      Campaign.create_power_share(current_user,preview_params)
      response = { status: 200, success: "Your post has been #{!preview_params[:share_now] ? "scheduled" : "shared" } successfully", is_queue: preview_params[:share_now]}
    rescue Exception => e
      remove_blank_campaign(current_user)
      response = { status: 400, error: "Error: #{e}"}
    end
    render :json => response
  end

  def scheduled_campaigns
    scheduled_list = Campaign.scheduled_camp_list(current_user,params)
    render :json => scheduled_list
  end

  def reschedule_share
    scheduled_list = Campaign.reschedule_share(current_user,preview_params.merge!({offset: 0, limit: 10 }))
    render :json => { status: 200, success: "Your post has been rescheduled successfully", campaigns_list: scheduled_list, is_shared: preview_params[:share_now] }
  end

  def power_share_history
    history_list = Campaign.history(current_user,params)
    render :json => history_list
  end

  def remove_post
    Campaign.remove_post(current_user,params)
    render :json => { status: 200 }
  end

  def campaign_share
    begin
      if @current_user && @error_msg.blank?
        params[:is_power_share] = false
        check_for_url_content(params)
        campaign_info
        response = { status: 200, success: "Your post has been #{!params[:share_now] ? "scheduled" : "shared" } successfully", campaign_id: @campaign.id, shorten_url: @campaign.short_url }
      else
        response = { status: 400, error: @error_msg}
      end
    rescue Exception => e
      remove_blank_campaign(@current_user)
      response = { status: 400, error: "Error: #{e}"}
    end
    render :json => response
  end

  def remove_schedule
    begin
      if @current_user
        Campaign.remove_post(@current_user,params)
        response = { status: 200, success: "Your scheduled post has been removed successfully." }
      else
        response = { status: 400, error: "User ID should not be blank"}
      end
    rescue Exception => e
      response = { status: 400, error: "Error: #{e}"}
    end
    render :json => response
  end

  def get_campaign_channels
    begin
      if @current_user
        response = { status: 200, data: Campaign.channel_list(@current_user,params) }
      else
        response = { status: 400, error: "User ID should not be blank"}
      end
    rescue Exception => e
      response = { status: 400, error: "Error: #{e}"}
    end
    render :json => response
  end

  def post_info
    render :json => Campaign.campaign_post_info(params[:post_id],current_user)
  end

  private

  def identify_user
    if params[:action] == 'get_reach'
      @current_user = session[:is_service_user] && session[:client_id] ?  User.where(id: session[:client_id]).first : current_user
    else
      @current_user = User.where(id: params[:user_id]).first
    end
  end

  def campaign_info
    campaign = Campaign.where(campaign_uuid: params[:campaign_uuid]).first
    if campaign.blank?
      @campaign = params[:is_test_share] ? Campaign.share_campaign(params) : Campaign.create_power_share(@current_user,params)
    else
      @campaign = params[:is_test_share] ? Campaign.share_campaign(params) : Campaign.edit_campaign(campaign,@current_user,params)
    end
  end

  def preview_params
    params.required(:power_share).permit!
    params[:power_share][:share_now] = (params[:power_share][:share_now] == "false" || !params[:power_share][:share_now]) ? false : true
    params[:power_share][:is_power_share] = true
    check_for_url_content(params[:power_share])
  end

  def in_percentage(reach,params)
    total = 0
    reach.each { |key, value| total += value.to_i }
    current_reach = []
    if total > 0
      current_reach << {:channel => "LinkedIn", :value => ((reach["ln"].to_f/ total.to_f) * 100).round(2) } if params[:ln_accounts]
      current_reach << {:channel => "Twitter", :value => ((reach["tw"].to_f/ total.to_f) * 100).round(2) } if params[:tw_accounts]
      current_reach << {:channel => "Facebook", :value => ((reach["fb"].to_f/ total.to_f) * 100).round(2) } if params[:fb_accounts]
      current_reach << {:channel => "Email", :value => ((reach["email"].to_f/ total.to_f) * 100).round(2) } if params[:email_accounts]
      current_reach << {:channel => "SMS", :value => ((reach["sms"].to_f/ total.to_f) * 100).round(2) } if params[:sms_accounts]
      current_reach << {:channel => "Opinify", :value => ((reach["op"].to_f/ total.to_f) * 100).round(2) } if params[:opinify_accounts]
      current_reach.sort_by! { |k| k[:value].to_f }
    else
      current_reach << reach
    end
    current_reach.reverse
  end

  def listen_feed_text
    config = UserConfig.where(user_id: current_user.id).first
    json = {}
    json["autoReplyText"] = { engage: '', reply: '', thank: '' }.stringify_keys!
    json["autoReplyText"] = config.listen["auto_response"] if config && config.listen
    json
  end

  def check_for_url_content(params)
    if params[:content] && params[:content].match(/(?:(ftp|http|https):\/\/)(\w*:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&&#37;@!\-\/]))?/) && params[:share_url].nil?
      params[:share_url] = params[:content].split(/\s+/).find_all { |u| u =~ /^https?:/ }.last
      params[:content] = params[:content].gsub(params[:share_url], "http://inquir.ly/1HFSuj7")
      params[:sms_content] = params[:content].gsub(params[:share_url], "http://inquir.ly/1HFSuj7") if params[:sms_content] && params[:is_power_share] == true
      if params[:sms_content] && params[:is_power_share] != true
        params[:sms_content] = params[:sms_content].include?("http://inquir.ly/1HFSuj7") ? params[:sms_content] : params[:sms_content] + "http://inquir.ly/1HFSuj7"
      end
    end
    params
  end

  def authenticate_user
    render :json => unauthorized if current_user.nil?
  end

  def remove_blank_campaign(user)
    if user.campaigns.last.campaign_channels.blank?
      user.campaigns.last.destroy
    end
  end

  def check_valid_pricing_plan
    @error_msg = ''
    schedule_date = (params[:share_now] == 'false' || !params[:share_now]) ? params[:schedule_on] : Time.zone.now
     if @current_user.blank?
       @error_msg = "User ID should not be blank"
     else
       @error_msg = ShareDetail.check_share_counts(@current_user,schedule_date,params)
     end
  end
end