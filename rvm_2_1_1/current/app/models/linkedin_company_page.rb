class LinkedinCompanyPage < ActiveRecord::Base
  belongs_to :user_social_channel

  def self.create_linkedin_pages(attr,social_channel)
    create(user_id: attr['user_id'],company_logo: attr['profile_image'],name: attr['name'], company_id: attr['company_id'],user_social_channel_id: social_channel.id)
  end

end