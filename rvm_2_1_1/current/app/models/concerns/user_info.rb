module UserInfo
  extend ActiveSupport::Concern
  included do

    def session_info
      {:user_id => self.id, :tenant_id => self.tenant_id, :tenant_name => self.tenant.try(:name), :company_id => self.company ? self.company.id : self.client.company.id,
       :role_id => self.role_id, :role_name => self.role.try(:name)}.stringify_keys!
    end

    def update_session(session_id)
      session = Session.where(session_id: session_id).first
      if session
        info = ActiveSupport::JSON.decode( Base64.decode64(session.data) )
        content = info.merge!({"user_info" => self.session_info })
        encrypted = Base64.encode64( ActiveSupport::JSON.encode(content) )
        session.update_attributes(data: encrypted)
      end
    end

    def update_alert_config
      AlertScript.new.create_alert_config(self) if DEFAULTS["default_alert_events"] != self.alert_events.map(&:name)
    end

    def update_client_settings
      ClientSetting.get_column_value("customer_records_count",self)
    end

    def create_default_schedule
      if ScheduleType.where(user_id: self.id).count == 0
        schedule = ScheduleType.create(name: "default schedule", user_id: self.id, is_active: true)
        ScheduleSlot.create(slot: (Time.now.in_time_zone("Kolkata") + 10.minutes).strftime("%I:%M %p"), schedule_type_id: schedule.id) if schedule
      end
    end

    def users
      self.parent_id == 0 ? User.where(parent_id: self.id, tenant_id: nil) : User.where(parent_id: self.parent_id,tenant_id: nil)
    end

    def update_avatar_url
      self.avatar_url = self.avatar.url(:thumb)
      self.save(validate: false)
    end

    def remove_avatar_url
      self.avatar_url = nil
      self.save(validate: false)
    end

    def default_url?
      self.avatar.url == "/avatars/original/missing.png" ? true : false
    end

    def tenant
      Tenant.where(id: self.tenant_id).first
    end

    def tenant_logo
      tenant = Tenant.where(id: self.tenant_id).first
      tenant && tenant.logo.url != "/logos/original/missing.png" ? tenant.logo.url : ''
    end

    def client
      User.where(id: self.parent_id).first
    end

    def is_tenant_user?
      self.parent_id == 0 ? false : true
    end

    def permissions
      Permission.define_permissions(self)
    end

    def tenant_regions
      TenantRegion.where(user_id: self.parent_id == 0 ? self.id : self.parent_id)
    end

    def tenant_types
      TenantType.where(user_id: self.parent_id == 0 ? self.id : self.parent_id)
    end

    def tenant_region
      tenant = Tenant.where(id: self.tenant_id).first
      tenant ? tenant.tenant_region.try(:id) : []
    end

    def industry
      self.parent_id == 0 ? self.company.try(:industry) : self.client.try(:company).try(:industry)
    end

    def overall_plans
      self.parent_id == 0 ? self.client_pricing_plans : (self.tenant_id ? self.tenant.client_pricing_plans : self.client.client_pricing_plans)
    end

    def is_trial_user?
      self.overall_plans.count == 1 && (self.overall_plans.first && self.overall_plans.first.pricing_plan.try(:name)) == 'Trial'
    end

    def update_pricing_plan(params)
      params[:start_date] = Date.today.strftime("%d/%m/%Y")
      params[:end_months] = 1
      date_list = ClientPricingPlan.get_start_end_date(params)
      plan = PricingPlan.where(name: 'Trial').first
      date_list.each do |list|
        client_plan = ClientPricingPlan.new(client_id: self.id, client_type: 'User', email_count: plan.email_count, sms_count: plan.sms_count,
               customer_records_count: plan.customer_records_count, campaigns_count: plan.campaigns_count, fb_boost_budget: plan.fb_boost_budget,
               pricing_plan_id: plan.id, is_active: Date.parse("#{list[:start_date]}") == Date.today, start_date: list[:start_date], exp_date: Date.today + 14.days)
        if client_plan.save
          client_plan.create_or_update_channel_list(plan.pricing_plan_channels.map(&:channel_id))
        end
      end
    end
  end
end