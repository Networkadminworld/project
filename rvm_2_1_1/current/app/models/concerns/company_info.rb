module CompanyInfo
  extend ActiveSupport::Concern
  included do

    def self.parent_company_info(user)
      {
          company_name: user.company.name,
          company_logo: user.company.logo,
          facebook_url: user.company.facebook_url || '',
          twitter_url: user.company.twitter_url || '',
          linkedin_url: user.company.linkedin_url || '',
          website_url: user.company.website_url || '',
          industry: user.company.industry_tag.try(:industry),
          sender_email: user.from_email
      }
    end

    def self.tenant_info(user)
      {
          company_name: user.tenant.try(:name) || user.client.company.name || '',
          company_logo: user.tenant_logo || user.client.company.logo || '',
          facebook_url: user.tenant.try(:facebook_url) || user.client.company.facebook_url || '',
          twitter_url: user.tenant.try(:twitter_url) || user.client.company.twitter_url || '',
          linkedin_url: user.tenant.try(:linkedin_url) || user.client.company.linkedin_url || '',
          website_url: user.tenant.try(:website_url) || user.client.company.website_url || '',
          industry: user.client.company.industry_tag.try(:industry),
          sender_email: user.from_email
      }
    end

    def self.non_tenant_user_info(user)
      {
          company_name: user.client.company.name || '',
          company_logo: user.client.company.logo || '',
          facebook_url: user.client.company.facebook_url || '',
          twitter_url:  user.client.company.twitter_url || '',
          linkedin_url: user.client.company.linkedin_url || '',
          website_url: user.client.company.website_url || '',
          industry: user.client.company.industry_tag.try(:industry),
          sender_email: user.from_email
      }
    end

    def self.business_details(params)
      list = []
      case params[:type]
        when 'business'
          user = User.where(id: params[:id]).first
          businesses = Company.where(id: user.executive_business_mappings.map(&:company_id))
          businesses.select(:id,:name,:user_id).each do |biz|
            list << {  id:   biz.id, name: biz.name, tenant_count: Tenant.where(client_id: biz.user_id).count }
          end
        when 'tenants'
          tenants = Tenant.where(client_id: where(id: params[:company_id]).first.try(:user_id))
          tenants.select(:id,:name).each do |tenant|
            list << {id: tenant.id, name: tenant.name} if tenant.users.count > 0
          end
        when 'users'
          user_id = where(id: params[:company_id]).first.try(:user_id)
          users = params[:tenant_id].blank? ? User.where(id: user_id) + User.where(tenant_id: nil,parent_id: user_id) : User.where(tenant_id: params[:tenant_id])
          users.each do |user|
            list << { id: user.id,email: user.email}
          end
        else
      end
      list
    end

    def save_tags(tags)
      tags.each do |tag|
        Tag.create(:name => tag, :company_id => self.id, :user_id => self.user_id)
      end if tags
    end
  end
end