require 'digest/md5'
class User < ActiveRecord::Base
  attr_accessor :step, :password_enabled, :current_password
  include UserValidation
  include UserMultiTenant
  include BoardingStep
  include UserInfo
  include ServiceUser
  before_create :assign_role
  scope :share_detail, lambda { |user| ShareDetail.where('user_id = ?', user.id) }

  def transaction_detail
    self.transaction_details.last
  end

  def self.check_user_auth_confirmed(authentication_token)
    User.where("authentication_token=? and confirmed_at is not null",authentication_token).first unless authentication_token.blank?
  end

  def self.inq_test_user
     parent = where(email: "admin@inquirly.com").first
     where(parent_id: parent.id, role_id: Role.where(name: "Inq-Test-User").first.try(:id), is_active: true).first
  end

  def self.update_avatar(user,avatar)
    user = where(id: user.id)[0]
    if avatar
       user.avatar = avatar
       user.save(validate: false)
    end
    user.update_avatar_url
    { data: user, profile_img: user.avatar.url(:medium), profile_top:  user.avatar.url(:thumb)}
  end

  def self.remove_avatar(params)
    user = where(id: params[:user_id].to_i)[0]
    user.avatar = nil
    user.remove_avatar_url
    user.save(validate: false)
  end

  def assign_role
    self.role_id = Role.where(name: 'Client-Admin').first.try(:id) if self.role_id.nil?
    self.parent_id =  0 if self.parent_id.nil?
    self.uid = Digest::MD5.hexdigest(self.email)
  end

  def self.change_role(current_user)
    role = current_user
    role.role_id = Role.find_by_name("Individual").id
    role.save(:validate=> false)
  end

  def self.users_list(email)
    where("(email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ? OR mobile ILIKE ? ) AND email NOT IN (?) AND parent_id = 0", "%#{email}%", "%#{email}%", "%#{email}%", "%#{email}%",DEFAULTS["internal_emails"]).map(&:email)
  end

  def update_csv_process(status)
    update_columns(:is_csv_processed => status)
  end

  def self.user_list(user,per_page,search_text)
    if search_text.blank?
      user.parent_id != 0 && user.tenant_id ? where(parent_id: user.parent_id, tenant_id: user.tenant_id).limit(per_page.to_i) :
        where(parent_id: user.parent_id == 0 ? user.id : user.parent_id).limit(per_page.to_i)
    else
      searched_user_list(user,per_page,search_text)
    end
  end

  def self.searched_user_list(user,per_page,term)
    if user.parent_id != 0 && user.tenant_id
      where("(email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ? OR mobile ILIKE ? ) AND parent_id = #{user.parent_id} AND tenant_id = #{user.tenant_id}","%#{term}%","%#{term}%","%#{term}%","%#{term}%").limit(per_page.to_i)
    else
      where("(email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ? OR mobile ILIKE ? ) AND parent_id = #{user.parent_id == 0 ? user.id : user.parent_id}","%#{term}%","%#{term}%","%#{term}%","%#{term}%").limit(per_page.to_i)
    end
  end
  
  def ensure_secured_token!
    self.security_token = SecureRandom.hex
    self.save(validate: false)
  end

  def from_email
    self.user_config && self.user_config.engage && self.user_config.engage["mobile_config"] && self.user_config.engage["mobile_config"]["from_email"] ? self.user_config.engage["mobile_config"]["from_email"] : self.email
  end

  def from_name
    self.user_config &&  self.user_config.engage && self.user_config.engage["mobile_config"] && self.user_config.engage["mobile_config"]["from_name"] ? self.user_config.engage["mobile_config"]["from_name"] : self.company.try(:name)
  end

  def reply_email
    self.user_config && self.user_config.engage && self.user_config.engage["mobile_config"] && self.user_config.engage["mobile_config"]["reply_email"] ? self.user_config.engage["mobile_config"]["reply_email"] : self.email
  end

  def update_industry(industry)
    industry = IndustryTag.where(id: industry.to_i).first
    company = Company.new(user_id: self.id, industry_id: industry.id)
    company.save(validate: false)
    tags = IndustryTag.where(industry: industry.industry).map(&:tag)
    tags.each { |tag| Tag.create(name: tag, company_id: company.id, user_id: self.id) }
  end
  
  def create_action_list
    removed_items = self.parent_id == 0 ? ["Add user", "Add a tenant"] : ["Add user", "Add a tenant", "Add complete company info"]
    action_lists = ActionList.where.not(action: removed_items).map(&:id)
    lists = action_lists - self.user_action_lists.map(&:action_list_id)
    lists.each do |list|
      UserActionList.create(user_id: self.id, action_list_id: list, completed: false)
    end
  end

  def self.fetch_user_list(params)
    client = where(email: params[:emailID]).first
    tenants = client.parent_id == 0 ? Tenant.where(client_id: client.id) : Tenant.where(client_id: client.parent_id)
    tenant_users = []
    if tenants.count == 0 && client.users.count > 0
      list = client_user_collection(client)
    else
      tenants.each do |tenant|
       json = {}
       json[:tenant_name] = tenant.try(:name)
       json[:tenant_id] = tenant.try(:id)
       json[:image_url] = tenant.company_profile_img
       json[:user] = user_collection(tenant,client)
       tenant_users << json.stringify_keys!
      end
      client_users = client.users.count > 0 ? client_user_collection(client) : []
      list = tenant_users + client_users
    end
    list
  end

  def self.client_user_collection(client)
    collection = []
    json = {}
    json[:tenant_name] = ""
    json[:tenant_id] = ""
    json[:image_url] = ""
    json[:user] = user_collection(client,client)
    collection << json.stringify_keys!
  end

  def self.user_collection(obj,client)
    collection = []
    obj.users.each do |user|
      if user.id != client.id
        json = {}
        json[:user_name] = user.full_name
        json[:unique_id] = user.uid
        json[:profile_image_url] = user.profile_image
        collection << json.stringify_keys!
      end
    end
    collection
  end

  def full_name
    (self.try(:first_name) || '') + ' ' + (self.try(:last_name) || '')
  end

  def profile_image
    self.avatar && !self.default_url? ? self.avatar.url(:medium) : ''
  end
end
