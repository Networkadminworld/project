class InqCampaignsController < ApplicationController
  before_action :check_client_user, only: [:user_channels]
  before_action :authenticate_user_web_api, only: [:user_channels]

  def user_channels
    social_info,mobile,in_location = UserChannel.all_channels(@_current_user)
    company_name = @_current_user.company.try(:name)
    from_email = @_current_user.from_email
    render :json => { social_accounts: social_info, mobile_accounts: mobile,
                      in_location_accounts: in_location, default_tags: default_tags,
                      company: company_name, sender_email: from_email, industry: @_current_user.industry }
  end

  def update_campaign_state
    begin
      Campaign.update_campaign_status(params)
      response = { status: 200, message: 'Campaign state updated successfully.'}
    rescue Exception => e
      response = { status: 400, error: "Error: #{e}"}
    end
    render :json => response
  end

  private

  def check_client_user
    @_current_user = session[:is_service_user] && session[:client_id] ?  User.where(id: session[:client_id]).first : current_user
  end

  def default_tags
    tags = []
    user_company_tags.each do |tag|
      temp = {}
      temp["text"] = tag.name
      tags << temp
    end
    tags.reject! { |tag| tag.empty? }
    tags
  end

  def user_company_tags
    if @_current_user .client
      @_current_user.client.company && @_current_user.client.company.tags ? @_current_user.client.company.tags : []
    else
      @_current_user.company && @_current_user.company.tags ? @_current_user.company.tags : []
    end
  end

end