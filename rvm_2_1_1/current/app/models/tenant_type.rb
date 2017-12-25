class TenantType < ActiveRecord::Base
  has_many :tenants
  before_save :downcase_name

  validates_presence_of :name
  validates :name, :uniqueness => {:scope => :user_id}

  def self.create_new(user,params,description)
    params.merge!(description: description)
    type = create(params)
    type.errors.try(:messages).blank?  ? user.tenant_types : { errors: type.errors.try(:messages) }
  end

  def downcase_name
    self.name.downcase! if self.name
  end

end