module CommandCenter
  class EngagementInfo
    attr_reader :client_user_id, :service_user_id

    def initialize(client_user_id, service_user_id)
      @client_user = User.where(id: client_user_id).first
      @service_user = User.where(id: service_user_id).first
    end

    def over_the_time
      all_channels = ['all channels'] + @client_user.user_social_channels.map(&:channel).uniq + @client_user.user_mobile_channels.map(&:channel).uniq +
          @client_user.user_location_channels.map(&:channel_type).uniq
      campaigns = @client_user.present? && @service_user.nil? ? client_user_info : service_user_info
      company_attachment = @client_user.tenant_id ? tenant_logo(@client_user) : company_logo(@client_user)
      company_name = @client_user.tenant_id ? tenant_name(@client_user) : company_name(@client_user)
      [all_channels,campaigns,company_attachment,company_name, @client_user.email]
    end

    def service_user_info
      @client_user.campaigns.where(service_user_id: @service_user.id).joins(:inq_campaign).where("inq_campaigns.state IN ('ACTIVE','EXPIRED')").select(:id, :label)
    end

    def client_user_info
      @client_user.campaigns.joins(:inq_campaign).where("inq_campaigns.state IN ('ACTIVE','EXPIRED')").select(:id, :label)
    end

    def company_logo(user)
      user = user.parent_id == 0 ? user : user.client
      user.company && user.company.attachment ? user.company.attachment.image.url(:square) : ''
    end

    def tenant_logo(user)
      user.tenant && user.tenant.logo_url ? user.tenant.logo_url : ''
    end

    def company_name(user)
      user = user.parent_id == 0 ? user : user.client
      user.company ? user.company.try(:name) : ''
    end

    def tenant_name(user)
      user.tenant ? user.tenant.try(:name) : ''
    end

  end
end