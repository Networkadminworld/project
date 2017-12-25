class UserLocationChannel < ActiveRecord::Base
  belongs_to :channel, polymorphic: true, :dependent => :destroy
  belongs_to :user
  after_create :create_user_channel

  def self.get_location_channels(user)
    list = []
    loc_channels = where(user_id: user.id).order(:id => :desc)
    loc_channels.each do |location|
      json = {}
      if location.channel.try(:status)
        json["id"] = location.id
        json["name"] = location.channel.try(:name)
        json["active"] = location.channel.try(:status)
        json["image"] = location.channel.try(:image) ? location.channel.try(:image).url : ''
        json["channel"] = location.channel_type.downcase
        json["class_name"] = location.class.model_name.name
      end
      list << json unless json.blank?
    end
    list.to_json
  end

  def get_location_channel
    {
        id: self.id,
        name: self.channel.try(:name),
        profile_name: self.channel.try(:name),
        active: self.channel.try(:status),
        image: self.channel.try(:image) ? self.channel.try(:image).url : '',
        channel: self.channel_type.downcase,
        class_name: self.class.model_name.name
    }
  end

  private

  def create_user_channel
    UserChannel.create_user_channels(ShareMedium._id("In-location"),self.id,self.user_id,"UserLocationChannel")
  end
end