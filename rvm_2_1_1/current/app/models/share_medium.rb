class ShareMedium < ActiveRecord::Base
  self.table_name = "share_mediums"
  scope :_id, lambda { |type| where(share_type: type).first.try(:id) }
end