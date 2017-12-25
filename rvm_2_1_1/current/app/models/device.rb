class Device < ActiveRecord::Base
  belongs_to :user

  def self.new_device? device_id,user
    where(device_id: device_id, user_id: user.id).blank?
  end
end