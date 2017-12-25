class ExecutiveTenantMapping < ActiveRecord::Base

  def self.get_tenant_ids(user_id)
    where(user_id: user_id, is_active: true).map(&:tenant_id)
  end

  def self.map_tenant(params)
    params[:tenant_ids].each do |id|
      check_exist = is_already_mapped?(id,params[:user_id])
      if check_exist.blank?
         create(:user_id => params[:user_id],:tenant_id => id,:is_active => true)
      else
        unless check_exist.is_active
          check_exist.update_attributes(is_active: true)
        end
     end
    end
    remove_already_mapped(params[:user_id],params[:tenant_ids])
    User.where(id: params[:user_id]).first
  end

  def self.is_already_mapped?(id,user_id)
     where(user_id:user_id,tenant_id: id).first
  end

  def self.already_mapped_user(user)
    where(user_id:user,is_active: true).pluck(:tenant_id)
  end

  def self.remove_already_mapped(user_id,t_ids)
     ids = t_ids.blank? ? where(user_id:user_id).pluck(:id) : where(user_id:user_id).where("tenant_id NOT in(#{t_ids.join(",")})").pluck(:id)
     ids.each do |i|
       self.find(i).update_attributes(is_active: false)
     end
  end
end
