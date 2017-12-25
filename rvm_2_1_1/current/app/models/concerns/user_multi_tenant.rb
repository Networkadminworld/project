module UserMultiTenant
  extend ActiveSupport::Concern
  included do

	 def self.create_corp_user(params)
    update_params(params) if params[:jb_user]
		user_details = where(id: params[:parent_id]).first
		user = User.new(email: params[:email], first_name: params[:first_name], mobile: params[:mobile],
                    last_name: params[:last_name], is_active: true,exp_date: user_details.exp_date,
                    tenant_id: params[:tenant_id],role_id: params[:role_id],password: params[:password],
                    password_confirmation: params[:password_confirmation], parent_id: user_details.id,
                    confirmed_at: Time.now, step: "Multitenant", currency_id: params[:currency_id])
   	[user,params[:password],user_details]
    end

   def self.update_params(params)
     params[:parent_id] = User.where(email: params[:admin_email]).first.try(:id)
     params[:tenant_id] = Tenant.where(name: params[:tenant_name]).first.try(:id)
     params[:role_id] = Role.where(name: params[:user_type].titlecase,is_default: true).first.try(:id)
     params[:first_name] = params[:name]
     params[:password_confirmation] = params[:password]
     params[:last_name] = ""
     if params[:is_update]
       params[:email] = (params[:old_email].downcase != params[:new_email].downcase) ? params[:new_email].downcase : params[:old_email].downcase
     else
       params[:email] = params[:new_email].downcase
     end
     params
   end

  def self.reset_user_password(params)
	user = where(id: params[:user_id]).first
	user.step = 'Multitenant'
	user.update_attributes(password: params[:password], password_confirmation: params[:password_confirmation])
	user.save
	InviteUser.reset_user_password(user,user.client.try(:email),params[:password]).deliver if user.errors.messages.blank? && user.is_active
	user
  end

  def self.reset_password(params)
    user = where(email: params[:email].downcase).first
    admin_email = where(id: user.parent_id).first.email
    user.step = 'Multitenant'
    user.update_attributes(password: params[:password], password_confirmation: params[:password_confirmation])
    user.save(:validate => false)
    InviteUser.reset_user_password(user,admin_email,params[:password]).deliver if user.is_active
    user
  end

  def self.change_status(params)
    user = where(id: params[:user_id]).first
    user.is_active = params[:is_active]
    user.save(:validate => false)
    params[:is_active] ? InviteUser.user_deactivation(user,user.client.try(:email)).deliver : InviteUser.user_deactivation(user,user.client.try(:email)).deliver
    user.is_active
  end

  def self.update_corp_user(user,params)
    update_params(params) if params[:jb_user]
    is_updated = user.is_active && (user.tenant_id != params[:tenant_id].to_i || user.role_id != params[:role_id].to_i || user.email != params[:email] || user.first_name != params[:first_name] || user.last_name != params[:last_name])
    user.first_name = params[:first_name]
    user.last_name  = params[:last_name]
    user.email = params[:email]
    user.mobile = params[:mobile]
    user.tenant_id = params[:tenant_id].blank? ? nil : params[:tenant_id].to_i
    user.role_id = params[:role_id].to_i
    user.currency_id = params[:currency_id]
    user.step = 'Multitenant'
    user.skip_reconfirmation!
    user.save
    if user.errors.messages.blank?
      InviteUser.updated_user_details(user).deliver if is_updated
      return true
    end
  end

  def self.update_company_name(user, params)
     all_users = User.get_all_users(user)
     update_admin_company_name(user,params[:user][:company_name]) if user.parent_id != 0
     all_users.each do |u|
       u.company_name = params[:user][:company_name]
       u.save(:validate => false)
       InviteUser.delay.updated_user_details(u) if u.is_active
     end
  end

  def self.update_admin_company_name(user,company_name)
    admin = where(id: user.parent_id).first
    admin.company_name = company_name
    admin.save(:validate => false)
    InviteUser.admin_company_details(admin, user).deliver if admin.is_active
  end
end
 
 def fetch_tenant_users
   User.where(parent_id: self.id)
 end

 def same_url_update_user(user,tenant_url,params)
   tenant_url.each do|i|
     i.redirect_url = params[:user][:redirect_url]
     i.save(:validate => false)
     user_ten = User.where(tenant_id: i.id)
     user_ten.each do|o|
       o.redirect_url = params[:user][:redirect_url]
       o.save(:validate => false)
     end
   end
 end

  def same_number_update_user(user,tenant_no,params)
    tenant_no.each do|i|
      i.from_number = params[:user][:from_number]
      i.save(:validate => false)
      user_ten = User.where(tenant_id: i.id)
      user_ten.each do|o|
        o.from_number = params[:user][:from_number]
        o.save(:validate => false)
      end
    end
  end
end
