class EnterpriseApiEndpoint < ActiveRecord::Base
  scope :subdomain, lambda { |domain| where(subdomain: domain).first }
end