class UserChannel < ActiveRecord::Base
   belongs_to :user_social_channel, :class_name => "UserSocialChannel", :foreign_key => "channel_id"
   belongs_to :user_mobile_channel, :class_name => "UserMobileChannel", :foreign_key => "channel_id"
   belongs_to :user_location_channel, :class_name => "UserLocationChannel", :foreign_key => "channel_id"
   belongs_to :user
   has_many :campaign_channel

   def self.all_channels(user)
     social_info = JSON.parse(UserSocialChannel.accounts(user))
     mobile_info = JSON.parse(UserMobileChannel.get_channels(user))
     in_location = JSON.parse(UserLocationChannel.get_location_channels(user))
     [social_info,mobile_info,in_location]
   end

   def self.create_user_channels(medium_id,channel_id,user_id,type)
      create(share_medium_id: medium_id, channel_id: channel_id, user_id: user_id, channel_type: type)
   end

   def self.reach_data(user)
     json = {}
     json["reach"] =  social_reach(user) + mobile_reach(user) + location_reach(user)
     json
   end

   def self.social_reach(user)
     json = []
     user.user_social_channels.each do |channel|
         json1 = {}
         json1["id"] = channel.id
         json1["channel"] = channel.channel
         json1["reach"] = UserSocialChannel.calculate_reach(user,channel.id,channel.channel).to_i
         json << json1
     end
     json
   end

   def self.mobile_reach(user)
     json = []
     user.user_mobile_channels.each do |channel|
         json2 = {}
         json2["id"] = channel.id
         json2["channel"] = channel.channel
         json2["reach"] = channel.channel == "sms" ? ContactGroup.all_contacts(user,channel.id,"sms") : ContactGroup.all_contacts(user,channel.id,"email")
         json << json2
     end
     json
   end

   def self.location_reach(user)
     json = []
     user.user_location_channels.each do |channel|
       json3 = {}
       json3["id"] = channel.id
       json3["channel"] = channel.channel_type.downcase
       json3["reach"] = '0'
       json << json3
     end
     json
   end

   def self.reach_calculation(user,params)
     json = {}
     json["sms"] = params[:sms_accounts].nil? ? "0" : ContactGroup.all_contacts(user,params[:sms_accounts],"sms").to_s
     json["email"] = params[:email_accounts].nil? ?  "0" : ContactGroup.all_contacts(user,params[:email_accounts],"email").to_s
     json["op"] = params[:opinify_accounts].nil? ?  "0" : ContactGroup.all_contacts(user,params[:opinify_accounts],"opinify").to_s
     json["fb"] = params[:fb_accounts].nil? ? "0" : UserSocialChannel.calculate_reach(user,params[:fb_accounts],"facebook").to_s
     json["tw"] = params[:tw_accounts].nil? ? "0" : UserSocialChannel.calculate_reach(user,params[:tw_accounts],"twitter").to_s
     json["ln"] = params[:ln_accounts].nil? ? "0" : UserSocialChannel.calculate_reach(user,params[:ln_accounts],"linkedin").to_s
     json
   end
end