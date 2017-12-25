class UserConfig < ActiveRecord::Base
  belongs_to :user
  serialize :engage, JSON
  serialize :listen, JSON

  def self.mobile_info(user,params)
    config = where(user_id: user.id).first_or_initialize
    config.update_attributes(engage: {"mobile_config"=>{"reply_email"=> params[:reply_email], "from_email"=> params[:from_email], "from_name"=> params[:from_name]}})
  end

  def self.create_s3_config(user,identity_id,identity_pool_id)
    config = where(user_id: user.id).first
    if config
      config.engage.merge!({"s3_config" => {"identity_id" => identity_id, "identity_pool_id" => identity_pool_id }})
      config.save
    else
      create(user_id: user.id, engage: {"s3_config" => {"identity_id" => identity_id, "identity_pool_id" => identity_pool_id }})
    end
  end
end