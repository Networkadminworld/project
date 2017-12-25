class UserMobileChannel < ActiveRecord::Base
  belongs_to :user
  belongs_to :contact_group

  after_create :create_user_channel

  def self.create_channels(channel,contact_group_id,user_id)
    create(channel: channel, contact_group_id: contact_group_id, user_id: user_id, active: true) if is_new_channel(channel,contact_group_id,user_id)
  end

  def self.is_new_channel(channel,contact_group_id,user_id)
    where(channel: channel, contact_group_id: contact_group_id, user_id: user_id).blank? ? true : false
  end

  def self.remove_channels(channel,contact_group_id,user_id)
    where(channel: channel, contact_group_id: contact_group_id, user_id: user_id).first.destroy unless is_new_channel(channel,contact_group_id,user_id)
  end

  def self.get_channels(user)
    list = []
    accounts = where(user_id: user.id).order(:id => :desc)
    accounts.includes(:contact_group).each do |account|
      group = ContactGroup.where(id: account.contact_group_id).first
      if group && group.business_customer_infos.count > 0
        json = {}
        json["id"] = account.id
        json["name"] = group.name
        json["active"] = account.active
        json["channel"] = account.channel
        json["class_name"] = account.class.model_name.name
        list << json
      end
    end
    list.to_json
  end

  def create_user_channel
    UserChannel.create_user_channels(ShareMedium._id("Mobile"),self.id,self.user_id,"UserMobileChannel")
  end

  def get_mobile_channel
    {
        id: self.id,
        name: self.contact_group.try(:name),
        profile_name: self.contact_group.try(:name),
        active: self.active,
        channel: self.channel,
        class_name: self.class.model_name.name
    }
  end
end