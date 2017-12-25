class AlertType < ActiveRecord::Base
  scope :find_id, ->(name) { where(name: name).first.try(:id) }
end