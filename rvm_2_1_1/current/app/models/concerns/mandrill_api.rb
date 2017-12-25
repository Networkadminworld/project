module MandrillApi
  extend ActiveSupport::Concern
  included do
    def self.create_mandrill_sub_account(user)
      user = User.where(id: user.id)
      user.each do |u|
        begin
          mandrill = Mandrill::API.new ENV["MANDRILL_API_KEY"]
          id = "cust-#{u.id}"
          name = u.parent_id == 0 ? u.company.try(:name) : u.client.company.try(:name)
          notes = "signed up on #{u.created_at}"
          mandrill.subaccounts.add id, name, notes
        rescue Mandrill::Error => e
          MANDRILL_LOGGER.info("A mandrill error occurred(sub_account add): #{e.class} - #{e.message}")
        end
      end
    end

    def self.update_sub_account(company)
      user = User.where(id: company.user_id).first
      begin
        mandrill = Mandrill::API.new ENV["MANDRILL_API_KEY"]
        id = "cust-#{user.id}"
        name = user.parent_id == 0 ? user.company.try(:name) : user.client.company.try(:name)
        notes = "signed up on #{user.created_at}"
        mandrill.subaccounts.update id, name, notes
      rescue Mandrill::Error => e
        MANDRILL_LOGGER.info("A mandrill error occurred(sub_account add): #{e.class} - #{e.message}")
      end
    end
  end
end