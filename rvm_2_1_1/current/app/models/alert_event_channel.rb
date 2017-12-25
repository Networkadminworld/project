class AlertEventChannel < ActiveRecord::Base
  belongs_to :alert_event
  belongs_to :alert_channel

  def channel_name
    self.alert_channel.try(:name)
  end

  def self.change_status(params)
    where(id: params[:id]).first.update_attributes(is_active: params[:is_active])
  end
end