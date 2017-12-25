class Alert < ActiveRecord::Base
  scope :find_id, ->(name) { where(name: name).first.try(:id) }
  has_many :alert_events
end