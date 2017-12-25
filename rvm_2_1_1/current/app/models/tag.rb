class Tag < ActiveRecord::Base
  belongs_to :company
  belongs_to :user

  def self.create_tags(tags,company,user_id)
    tags.collect{|i| i['text']}.each do |tag|
        Tag.create(:name => tag, :company_id => company.id, :user_id => user_id)
     end
  end
end
