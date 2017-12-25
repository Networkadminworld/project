require 'restclient'
class UserSocialChannel < ActiveRecord::Base
  has_many :user_channels, :foreign_key => "channel_id", dependent: :destroy
  belongs_to :user
  scope :fb_reach, lambda { |user| where(user_id: user.id, active: true, channel: "facebook").sum(:connections) }
  scope :tw_reach, lambda { |user| where(user_id: user.id, active: true, channel: "twitter").sum(:connections) }
  scope :ln_reach, lambda { |user| where(user_id: user.id, active: true, channel: "linkedin").sum(:connections) }

  after_create :create_user_channel

  def self.accounts(user)
    list = []
    unless user.nil?
      accounts = where(user_id: user.id, channel: DEFAULTS["social_providers"], active: true)
      accounts.each do |account|
        json = {}
        json["id"] = account.id
        json["name"] = account.name
        json["profile_image"] = account.profile_image
        json["active"] = account.active
        json["channel"] = account.channel
        json["social_id"] = account.social_id
        json["expiry_in"] = (Date.parse("#{account.updated_at}") + 60.days ).mjd - Date.today.mjd
        json["class_name"] = account.class.model_name.name
        list << json
      end
    end
    list.to_json
  end

  def self.account_exist?(user,response)
    where(user_id: user.id, social_id: social_uid(response), channel: response.provider, email: email_address(response)).first
  end

  def self.existing_fb_accounts(user,response)
    existing_accounts = []
    pages_list = []
    fb_user = FbGraph2::User.me(response.credentials.token)
    pages_list << fb_user.accounts unless fb_user.accounts.blank?
    pages_list << fb_user.accounts.next unless fb_user.accounts.next.blank?
    pages_list << fb_user.accounts.next.next unless fb_user.accounts.next.next.blank?
    pages_list << fb_user.accounts.next.next.next unless fb_user.accounts.next.next.next.blank?
    if pages_list.count > 0
      pages_list.each do |accounts|
        accounts.each do |account|
          attributes = account.raw_attributes
          page = where(user_id: user.id,name: attributes['name'],social_id: attributes['id'],active: true).last
          existing_accounts << attributes['id'] if page
          existing_accounts << social_uid(response) if fb_account(user,response)
        end
      end
    else
      existing_accounts << social_uid(response) if fb_account(user,response)
    end
    existing_accounts
  end

  def self.fb_account(user,response)
    where(user_id: user.id, social_id: social_uid(response), channel: response.provider, email: email_address(response),active: true).first
  end

  def self.create_account(user,response,image)
    create(user_id: user.id, channel: response.provider, email: email_address(response), social_id: social_uid(response),
        social_token: response.credentials.token, name: profile_name(response), profile_image: image, active: true,
        is_page: response.provider == 'facebook' ? false : nil)
  end

  def self.create_pages(attr)
    find_or_initialize_by(user_id: attr['user_id'],social_id: attr['social_id']).
        update_attributes!(user_id: attr['user_id'], social_token: attr['social_token'], name: attr['name'], profile_image: attr['profile_image'],
                           social_id: attr['social_id'], channel: 'facebook', active: true, is_page: attr['is_page'], admin_id: attr['admin_id'])
  end

  def create_user_channel
    medium_id = ShareMedium.where(share_type: "Social").first.try(:id)
    UserChannel.create_user_channels(medium_id,self.id,self.user_id,"UserSocialChannel")
    user = User.find self.user_id
    user.social_account_status
    user.add_same_channel_status
  end

  def self.queued_social_channels(user)
    queued_list = Delayed::Job.where(user_id: user.id, failed_at: nil).map(&:campaign_id)
    campaigns = Campaign.where(id: queued_list)
    social_channel = []
    campaigns.each do |campaign|
      share_channels = campaign.social_channels
      share_channels.includes(:user_channel).each do |c_channel|
          social_channel << c_channel.user_channel.user_social_channel if c_channel.user_channel && c_channel.user_channel.user_social_channel
      end
    end
    social_channel
  end

  def self.email_address response
    response.provider == "facebook" ? response.info.email : response.info.name
  end

  def self.profile_name response
    case response.provider
      when 'facebook'
        response.info.name
      when 'google_oauth2'
        response.info.email
      else
        response.info.nickname
    end
  end

  def self.social_uid response
    case response.provider
      when 'facebook', 'linkedin'
        response.uid
      when 'twitter'
        response.credentials.secret
      when 'google_oauth2'
        response.extra.raw_info.link
      else
        ''
    end
  end

  def self.calculate_reach(user,channel_id,channel)
    where(id: channel_id, user_id: user.id, active: true, channel: channel).sum(:connections)
  end

  def self.create_fb(response)
    find_or_initialize_by(user_id: response['user_id'],social_id: response['social_id']).
        update_attributes!(user_id: response['user_id'], social_token: response['social_token'], name: response['name'],email:response['email'],
        profile_image: response['profile_image'], social_id: response['social_id'], channel: 'facebook', is_page: false, active: true)
  end

  def self.create_linkedin(response,is_page)
    social_channel = find_or_initialize_by(user_id:response['user_id'],social_id: response['social_id'],name: response['name'])
    social_channel.update_attributes!(user_id: response['user_id'], social_token: response['social_token'], name: response['name'],email:response['email'],
                                      profile_image: response['profile_image'], social_id: response['social_id'], channel: 'linkedin', is_page: is_page, active: true)
    LinkedinCompanyPage.create_linkedin_pages(response,social_channel) if is_page
  end

  def update_auth_props(response)
    self.update_attributes!(user_id: response[:user_id], social_token: response[:social_token], name: response[:name],email:response[:email],
      profile_image: response[:profile_image], social_id: response[:social_id], channel: response[:channel], active: true)
  end

  def get_social_channel
    {
        id: self.id,
        name: self.name,
        profile_image: self.profile_image,
        active: self.active,
        channel: self.channel,
        social_id: self.social_id,
        class_name: self.class.model_name.name
    }
  end

end