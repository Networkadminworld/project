class Role < ActiveRecord::Base
   has_many :permissions, dependent: :destroy
   has_one :user
   validates :name, :presence => { :message => "Role name shouldn't be blank" }
   validates :name, :uniqueness => {:scope => :user_id,:message=>"Role already exists"}
   DEFAULT_ROLES = DEFAULTS['internal_roles']
   TENANT_ROLES = DEFAULTS['tenant_roles']


  def self.get_role(user)
    plan_name = PricingPlan.find_pricing_plan(user.business_type_id).first.plan_name
    plan_name.include?("#{DEFAULTS['signup_plan_individual']}") ? where(name: DEFAULTS['signup_role_individual']).first.id : where(name: DEFAULTS['signup_role_other']).first.id
  end

  def self.roles_and_custom_roles(user)
    where("user_id is NULL and name NOT IN (?)",Role::DEFAULT_ROLES) + where(user_id: user.parent_id == 0 ? user.id : user.parent_id)
  end

  def self.get_tenant_roles(current_user)
   user_id = current_user.parent_id == 0 ? current_user.id : current_user.parent_id
   where("user_id = ? or user_id is null",user_id).where.not(name: Role::DEFAULT_ROLES)
  end

  def self.client_roles(user)
    if user.parent_id == 0
      where(user_id: user.id).order(created_at: :asc)
    elsif user.parent_id != 0 && user.tenant_id
      where(user_id: user.parent_id, visible_to_tenant: true).order(created_at: :asc)
    else
      where(user_id: user.parent_id).order(created_at: :asc)
    end
  end

  def self.create_role(client_user_id,params)
    params[:user_id] = client_user_id
    params[:name] = params[:name].downcase if params[:name]
    role = Role.create(params)
    if role.errors.try(:messages).blank?
      Permission.default_permissions(role)
      { :status  => 200 }
    else
      { :status  => 400, errors: role.errors }
    end
  end

  def self.update_role(client_user_id,params)
    role = where(id: params[:id],user_id: client_user_id).first
    params[:name] = params[:name].downcase if params[:name]
    status = role.update_attributes(params)
    status ? { :status  => 200 } : { :status  => 400, errors: role.errors }
  end

  def service_user_role
    !Role.where(id: self.id, name: 'Customer-Service-Executive', is_default: true).first.blank?
  end

end
