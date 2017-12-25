class CampaignCustomer < ActiveRecord::Base
  belongs_to :campaign_channel
  belongs_to :campaign
  belongs_to :business_customer_info
end