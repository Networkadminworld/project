module ServiceUser
  extend ActiveSupport::Concern
  included do

    def update_businesses(params)
      unless params[:businesses].blank?
        params[:businesses].each do |id|
           mapping = ExecutiveBusinessMapping.where(user_id: self.id, company_id: id.to_i).first_or_initialize
           mapping.update_attributes(company_id: id.to_i, user_id: self.id)
        end
      end
    end

    def self.create_service_user(params)
      admin_details = where(id: params[:parent_id]).first
      user = new(first_name: params[:first_name], last_name: params[:last_name], email: params[:email],is_active: true,
             mobile: params[:mobile],password: params[:password],password_confirmation: params[:password_confirmation],role_id: params[:role_id],parent_id: admin_details.id, confirmed_at: Time.now)
      [user,params[:password],admin_details]
    end

    def self.update_service_user(user,params)
      is_updated = user.is_active && (user.role_id != params[:role_id].to_i || user.email != params[:email] || user.first_name != params[:first_name] || user.last_name != params[:last_name])
      user.first_name = params[:first_name]
      user.last_name  = params[:last_name]
      user.email = params[:email]
      user.mobile = params[:mobile]
      user.role_id = params[:role_id].to_i
      user.skip_reconfirmation!
      user.step = 'Multitenant'
      user.save
      if user.errors.messages.blank?
     #   params.merge!({businesses: business_ids})
        user.update_businesses(params)
        InviteUser.updated_user_details(user).deliver if is_updated
      end
    end

    def self.engagement_info(params,user)
      user = where(id: params[:client_id]).first if params[:client_id].present?
      all_channels = ['all channels'] + user.user_social_channels.map(&:channel).uniq + user.user_mobile_channels.map(&:channel).uniq +
            user.user_location_channels.map(&:channel).uniq
      all_campaigns = user.campaigns.select(:id, :label)
      [all_campaigns,all_channels]
    end
  end
end
