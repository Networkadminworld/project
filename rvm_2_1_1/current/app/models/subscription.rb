class Subscription < ActiveRecord::Base
  belongs_to :consumer 
  belongs_to :user, foreign_key: "client_id"

  def self.is_subscribed(business_id,consumer_id,type)
    where(client_id: business_id,consumer_id: consumer_id,business_type: type).first.try(:is_active)
  end

  def self.add_subscription(business_id,consumer_id,type)
    create(client_id: business_id,consumer_id: consumer_id,business_type: type, is_active: true)
  end
end
