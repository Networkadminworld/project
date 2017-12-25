module OmniauthSocialStrategy
  extend ActiveSupport::Concern
  included do

    def existing_fb_details(user,omniauth_response)
      existing_accounts = []
      pages_list = []
      fb_user = FbGraph2::User.me(omniauth_response.credentials.token)
      pages_list << fb_user.accounts unless fb_user.accounts.blank?
      pages_list << fb_user.accounts.next unless fb_user.accounts.next.blank?
      pages_list << fb_user.accounts.next.next unless fb_user.accounts.next.next.blank?
      pages_list << fb_user.accounts.next.next.next unless fb_user.accounts.next.next.next.blank?
      if pages_list.count > 0
        pages_list.each do |accounts|
          accounts.each do |account|
            attributes = account.raw_attributes
            page = UserSocialChannel.where(user_id: user.id,name: attributes['name'],social_id: attributes['id'],active: true).last
            existing_accounts << attributes['id'] if page
            existing_accounts << UserSocialChannel.social_uid(omniauth_response) if current_account_exist?(user,omniauth_response)
          end
        end
      else
        existing_accounts << UserSocialChannel.social_uid(omniauth_response) if current_account_exist?(user,omniauth_response)
      end
      [fb_user,existing_accounts]
    end

    def existing_ln_details(user,response,access_token)
      exist_account = []
      company_ids = []
      exist_company_page_ids = []
      company_list = JSON.parse(RestClient.get("https://api.linkedin.com/v1/companies?oauth2_access_token=#{access_token}&format=json&is-company-admin=true"))
      if company_list["_total"] > 0
        existing_social_ids = UserSocialChannel.where(channel: response.provider, is_page: true, active: true).map(&:id)
        if existing_social_ids
          company_list["values"].each { |value| company_ids << value["id"]}
          LinkedinCompanyPage.where(user_social_channel_id: existing_social_ids, user_id: user.id).each do |link_page|
            exist_company_page_ids << link_page.company_id if company_ids.include?(link_page.company_id)
          end
        end
        exist_account = response.uid if current_account_exist?(user,response)
      else
        exist_account = response.uid if current_account_exist?(user,response)
      end
      [exist_account,exist_company_page_ids,company_list]
    end

    private

    def current_account_exist?(user,response)
      UserSocialChannel.where(user_id: user.id, social_id: response.uid, channel: response.provider, active: true).first
    end

  end
end