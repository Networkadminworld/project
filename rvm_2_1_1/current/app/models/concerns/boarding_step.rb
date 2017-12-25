module BoardingStep
  extend ActiveSupport::Concern
  included do

    def social_account_status
      if self.user_social_channels.where(active: true).count == 1
        UserActionList.update_status(self, "Add your first social account",true)
      elsif self.user_social_channels.where(active: true).count >= 2
        UserActionList.update_status(self, "Add another social channel",true)
      end
    end

    def remove_social_status
      if self.user_social_channels.where(active: false).count == self.user_social_channels.count
        UserActionList.update_status(self, "Add your first social account",false)
      elsif self.user_social_channels.where(active: true).count == 1
        UserActionList.update_status(self, "Add another social channel",false)
      end
    end

    def add_customer_status
      UserActionList.update_status(self, "Add a customer",true)
    end

    def remove_customer_status
      if self.business_customer_infos.count == 0
        UserActionList.update_status(self, "Add a customer", false)
        UserActionList.update_status(self, "Upload customer data", false)
      end
    end

    def power_share_status
      UserActionList.update_status(self, "Do your first PowerShare",true) if self.campaigns.count >= 1
    end

    def upload_customer_status
      UserActionList.update_status(self, "Upload customer data",true)
    end

    def customise_branding_status
      UserActionList.update_status(self, "Customise your branding theme",true)
    end

    def add_tags_status
      user = self.is_tenant_user? ? self.client : self
      UserActionList.update_status(user, "Add tags for your business",true) if user.tags.count >= 1
    end

    def add_user_status
      UserActionList.update_status(self, "Add a user",true) if User.get_all_users(self).count > 0
    end

    def add_tenant_status
      UserActionList.update_status(self, "Add a tenant",true) if Tenant.where(client_id: self.id).count > 0
    end

    def add_same_channel_status
      counts = Hash.new(0)
      social_channels = self.user_social_channels.map(&:channel)
      mobile_channels = self.user_mobile_channels.map(&:channel)
      social_channels.each { |name| counts[name] += 1 }
      mobile_channels.each { |name| counts[name] += 1 }
      if counts["facebook"] >= 2 || counts["twitter"] >= 2 || counts["linkedin"] >= 2 || counts["sms"] >= 2 || counts["email"] >= 2
        UserActionList.update_status(self, "Add another account with same channel",true)
      end
    end

    def add_more_tags_status
      user = self.is_tenant_user? ? self.client : self
      UserActionList.update_status(user, "Add more tags",true) if user.tags.count >= 5
    end

    def add_company_status
      user = self.is_tenant_user? ? self.client : self
      UserActionList.update_status(user, "Add complete company info",true) unless user.company.empty?
    end
  end
end