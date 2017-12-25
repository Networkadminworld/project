class Rest::PowerShareController < PowerShareController
	respond_to :json
	include ResponseStatus
  include HashConverter
  include SharedCampaigns
  skip_before_action :authenticate_user
	before_action :valid_session_data, except: [:get_campaigns,:get_s3_config,:get_session_info]
	
	def social_accounts
    location_list = []
	  social_info,mobile_info,in_location = UserChannel.all_channels(current_user)
    in_location.each { |loc| location_list << loc.reject!{ |k| k == "image" } }
    tags = []
    default_search_tags.each {|tag| tags << tag["text"]}
	  render :json => success({resCode: 10001, resMessage: "SUCCESS"}, {
        socialAccounts: HashConverter.to_camel_case(social_info),
        mobileAccounts: HashConverter.to_camel_case(mobile_info),
        locationAccounts: HashConverter.to_camel_case(in_location),
        replyText: listen_feed_text,
        searchText: tags})
  end

  def power_share
    Campaign.create_power_share(current_user,share_params)
    render :json => success({resCode: 10001, resMessage: "SUCCESS"})
  end

  def get_share_queue
    queue_list = Campaign.scheduled_camp_list(current_user,paginate_params)
    render :json => success({resCode: 10001, resMessage: "SUCCESS"}, HashConverter.to_camel_case(queue_list))
  end

  def get_share_history
    history = Campaign.history(current_user,paginate_params)
    render :json => success({resCode: 10001, resMessage: "SUCCESS"}, HashConverter.to_camel_case(history))
  end

  def get_reach_data
    render :json => success({resCode: 10001, resMessage: "SUCCESS"},  UserChannel.reach_data(current_user) )
  end

  def delete_post
    params[:campaign_id] = params[:postID]
    Campaign.remove_post(current_user, params)
    render :json => success({resCode: 10001, resMessage: "SUCCESS"})
  end

  def reschedule_post
    schedule_params = {id: params["postID"], schedule_on: params["shareDate"], share_now: params["shareNow"]}
    Campaign.reschedule_share(current_user,schedule_params)
    render :json => success({resCode: 10001, resMessage: "SUCCESS"})
  end

  def get_s3_config
    s3 = S3Service.new
    params = { pool_name: "Inq_BusinessApp", type: "BusinessApp" }
    render :json => success({resCode: 10001, resMessage: "SUCCESS"}, s3.get_config(params))
  end

  def get_recipients
    render :json => success({ resCode: 1001, resMessage: "SUCCESS"}, HashConverter.to_camel_case(User.fetch_user_list(params)))
  end

  def get_session_info
    user = User.where(id: params[:user_id]).first
    render :json => success({resCode: 10001, resMessage: "SUCCESS"}, user ? user.session_info : [])
  end

  def get_campaigns
    beacon_campaigns
  end

  def update_campaign_state
    begin
      params[:is_api_request] = true
      Campaign.update_campaign_status(params)
      response = success({resCode: 10001, resMessage: "SUCCESS"})
    rescue Exception => e
      response = failure({resCode: 20001, resMessage: "SERVER ERROR"})
    end
    render :json => response
  end

  def get_approval_post
    campaigns = Campaign.fetch_approval_campaigns(current_user,paginate_params)
    render :json => success({resCode: 10001, resMessage: "SUCCESS"}, HashConverter.to_camel_case(campaigns))
  end
	
	private

  def share_params
    params[:og_meta_data] = {}
    params[:content] = params[:shareText]
    params[:og_meta_data][:image] = params[:imageURL]
    params[:share_url] = params[:shareUrls]
    params[:social_channels] = params[:socialChannels]
    params[:mobile_channels] = params[:mobileChannels]
    params[:location_channels] = params[:locationChannels]
    params[:schedule_on] = params[:shareDate]
    params[:share_now] = params[:shareNow]
    params[:is_upload_image] = true
    params[:campaign_type] = "powershare"
    params[:is_power_share] = true
    params[:add_to_queue] = params[:addToQueue]
    params
  end

  def paginate_params
    params[:offset] = (params[:pageNo] - 1) * params[:noOfItems]
    params[:limit] = params[:noOfItems]
    params
  end
	
	def valid_session_data
    session = Session.find_by_session_id(request.headers["HTTP_USERSECURITYTOKEN"])
    if session
      user_id = session.data ? ActiveSupport::JSON.decode( Base64.decode64(session.data) )["warden.user.user.key"][0].first : nil
      user =  User.where(id: user_id, email: params[:emailID]).first
      user ? @current_user = user : invalid_token({res_code: 30010, res_message: 'Invalid token'})
    else
      invalid_token({res_code: 30010, res_message: 'Invalid token'})
    end
	end
end