class ClientLanguage < ActiveRecord::Base
	belongs_to :client_setting
	belongs_to :language
	after_save :reload_client_settings

  def self.create_new_record(user,language_ids)
    user.client_setting.update_attributes(language_ids:language_ids) unless language_ids.empty?
  end

  private

  def reload_client_settings
    $_SESSION[:client_settings] = ClientSetting.define_client_settings(self.client_setting.user) if $_SESSION
  end

end
