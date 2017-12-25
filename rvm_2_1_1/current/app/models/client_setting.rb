class ClientSetting < ActiveRecord::Base
  serialize :language_ids, Array
  belongs_to :user
  has_many :client_languages
  has_many :languages, :through => :client_languages
  belongs_to :pricing_plan
  after_save :reload_client_settings

  CLIENT_SETTING_EXD_COLUMNS = ["id","created_at","updated_at","pricing_plan_id","user_id"]
  CLIENT_SETTING_COLUMNS = self.column_names

   def self.define_client_settings(user)
    client_settings = {}
    client_setting = user.client_setting
    if client_setting.present?
      plan = client_setting.pricing_plan
      CLIENT_SETTING_COLUMNS.each do |column|
       client_settings.merge!({"#{plan.name}:#{column}" => client_setting.send("#{column}")})  unless CLIENT_SETTING_EXD_COLUMNS.include?(column)
      end
      client_settings.merge!({"#{plan.name}:languages" => client_setting.languages.map(&:id)})
    end
    client_settings
   end

  def self.get_current_user_settings(column,user)
     ClientSetting.create_client_setting(user) if user.client_setting.blank? && self.valid_email?(user.email)
     $_SESSION[:client_settings] = self.define_client_settings(user) if $_SESSION[:client_settings].blank?
     if user.client_setting.present?
       plan_name = user.client_setting.pricing_plan.name
       client_value = $_SESSION[:client_settings]["#{plan_name}:#{column}"]
       client_value.present? ? client_value : $pricing_plans["#{plan_name}:#{column}"]
     end
  end

  def self.create_client_setting(user)
   unless $pricing_plans.blank?
     plan = PricingPlan.where("business_type_id =?", user.business_type_id).last
     associate_params = { pricing_plan_id: plan.id, user_id:user.id }
     CLIENT_SETTING_COLUMNS.each do |column|
     associate_params.merge!("#{column}" => $pricing_plans["#{plan.plan_name}:#{column}"])  unless CLIENT_SETTING_EXD_COLUMNS.include?(column)
     end
     ClientSetting.create(associate_params)
   end
  end

  def self.get_column_value(column,user)
    ClientSetting.get_current_user_settings(COLUMN_NAME["column_settings"][column],user)
  end

private

  def reload_client_settings
     $_SESSION[:client_settings] = ClientSetting.define_client_settings(self.user) if $_SESSION
  end

  def self.valid_email?(email)
    reg = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
    reg.match(email) ? true : false
  end

end
