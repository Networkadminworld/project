class TenantRegion < ActiveRecord::Base
  has_many :tenants
  before_save :downcase_name

  validates_presence_of :name
  validates :name, :uniqueness => {:scope => :user_id}


  def self.create_new(user,params,description)
    params.merge!(description: description)
    region = create(params)
    region.errors.try(:messages).blank?  ? user.tenant_regions : { errors: region.errors.try(:messages) }
  end

  def downcase_name
    self.name.downcase! if self.name
  end
end