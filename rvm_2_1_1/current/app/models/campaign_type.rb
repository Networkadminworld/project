class CampaignType < ActiveRecord::Base
  has_many :campaigns
  scope :get_id, lambda { |name| where(name: name.capitalize).first.try(:id) }

  def self.list
    camp_type = CampaignType.all.select("id,name")
    camp_list = []
    camp_type.each do |type|
      json = {}
      json["id"] = type.id
      json["name"] = type.name
      camp_list << json
    end
    camp_list
  end
end