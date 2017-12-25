require 'rest_client'
class Company < ActiveRecord::Base
  include CompanyInfo
  include MandrillApi
  validates :name, presence: {:message => "Please enter company name."},  :if => Proc.new { |obj| obj.name != "" && obj.name != nil}
  validates :name, uniqueness: true, allow_nil: false
  has_many :tags, dependent: :destroy
  belongs_to :user
  belongs_to :industry_tag,foreign_key: "industry_id"
  has_one :attachment, :as => :attachable, dependent: :destroy

  after_save :update_piwik_id
  after_update :update_mandrill_sub_account

  def self.business_list
    company_names = []
    list = []
    all.select(:id,:name).each do |biz|
      unless company_names.include?(biz.name)
        list << biz
        company_names << biz.name
      end
    end
    list
  end

  def self.get_company_data(user)
    client_id = user.parent_id == 0 ? user.id : user.parent_id
    company = where(user_id: client_id).first
    industry_types = IndustryTag.get_all(company)
    user_config = UserConfig.where(user_id: client_id).first
    tags = []
    unless company.nil?
      company.tags.each do |tag|
        temp = {}
        temp["text"] = tag.name
        tags << temp
      end
    end
    [company,tags,industry_types,user_config]
  end
  
  def self.piwik_info(user)
    piwik_info =[]
    company = where(user_id: user.id).first
    piwik_info << company.piwik_id
  end

  def self.update_details(image,tags,user,params)
    client = user.parent_id == 0 ? user : user.client
    company = Company.where(user_id: client.id).first_or_initialize
    params[:user_id] = client.id
    company.update_attributes(params.except(:thank, :engage, :reply))
    if image
       company.attachment.destroy if company.attachment.present?
       Attachment.create_attachment(company.id,image,"Company")
    end
    if tags
      company.tags.destroy_all if company.tags
      tags.is_a?(String) ? Tag.create_tags(JSON.parse(tags),company,client.id) : Tag.create_tags(tags,company,client.id)
    end
    update_listen_config(client,params)
    on_boarding_steps(client)
    company
  end

  def self.update_listen_config(client,params)
    config = UserConfig.where(user_id: client.id).first_or_initialize
    config.update_attributes(listen: { "auto_response" =>  { "engage" => params[:engage], "reply" => params[:reply],"thank" => params[:thank] } })
  end

  def self.on_boarding_steps(client)
    client.add_tags_status
    client.add_more_tags_status
    client.add_company_status
  end

  def self.get_info(user)
    if user.parent_id == 0
      parent_company_info(user)
    else
      if user.tenant_id
        tenant_info(user)
      else
        non_tenant_user_info(user)
      end
    end
  end

  def logo
    self.attachment ? self.attachment.image.url(:original) : ''
  end

  def empty?
    status = false
    self.attributes.each do |k,v|
      status = true if k != "tags" && k != "company_type_id" && (v.nil? || v == [] || v == "")
    end
    status
  end

  def industry
    IndustryTag.where(id: self.industry_id).first.try(:industry)
  end

#  def update_piwik_id
#    changes = self.changes
#    if changes[:name] && !self.piwik_id
#      company_name = ENV['CUSTOM_URL'] == "http://app.ezeees.com/" ? self.name.upcase.gsub(" ","-") : "local-" + self.name.upcase.gsub(" ","-")
#      url = "http://analytics.ezeees.com/index.php?module=API&method=SitesManager.addSite&token_auth=1964858ac6d6942bd93ea3e21af70c3b&siteName=#{company_name}&urls=http://app.ezeees.com"
#      response = RestClient.post(url, {:content_type => :xml})
#      self.update_attributes(piwik_id: Hash.from_xml(response.gsub("\n", ""))["result"].to_i)
#    elsif changes[:name] && self.piwik_id
#      company_name = ENV['CUSTOM_URL'] == "http://app.ezeees.com" ? self.name.upcase.gsub(" ","-") : "local-" + self.name.upcase.gsub(" ","-")
#      url  = "http://analytics.ezeees.com/index.php?module=API&method=SitesManager.updateSite&token_auth=1964858ac6d6942bd93ea3e21af70c3b&idSite=#{self.piwik_id}&siteName=#{company_name}"
#      RestClient.post(url, {:content_type => :xml})
#    end
#  end
####################
#    def update_piwik_id
#    changes = self.changes
#    if changes[:name] && !self.piwik_id
#      company_name = self.name.upcase.gsub(" ","-")
#      url = "http://analytics.ezeees.com/index.php?module=API&method=SitesManager.addSite&token_auth=75e2d094d66292a46b9f6f1f53e827a5&siteName=#{company_name}&urls=http://app.ezeees.com"
#      response = RestClient.post(url, {:content_type => :xml})
#      self.update_attributes(piwik_id: Hash.from_xml(response.gsub("\n", ""))["result"].to_i)
#    elsif changes[:name] && self.piwik_id
#      company_name = self.name.upcase.gsub(" ","-")
#      url  = "http://analytics.ezeees.com/index.php?module=API&method=SitesManager.updateSite&token_auth=75e2d094d66292a46b9f6f1f53e827a5&idSite=#{self.piwik_id}&siteName=#{company_name}"
#      RestClient.post(url, {:content_type => :xml})
#    end
#  end
##################
  def update_piwik_id
    changes = self.changes
    if changes[:name] && !self.piwik_id
      company_name = self.name.upcase.gsub(" ","-")
      url = "#{ENV['PIWIK_URL']}index.php?module=API&method=SitesManager.addSite&token_auth=#{ENV['PIWIK_TOKEN']}&siteName=#{company_name}&urls=#{ENV['PIWIK_CLIENT_DOMIAN']}"
      response = RestClient.post(url, {:content_type => :xml})
      self.update_attributes(piwik_id: Hash.from_xml(response.gsub("\n", ""))["result"].to_i)
    elsif changes[:name] && self.piwik_id
      company_name = self.name.upcase.gsub(" ","-")
      url  = "#{ENV['PIWIK_URL']}index.php?module=API&method=SitesManager.updateSite&token_auth=#{ENV['PIWIK_TOKEN']}&idSite=#{self.piwik_id}&siteName=#{company_name}"
      RestClient.post(url, {:content_type => :xml})
    end
  end
  def update_mandrill_sub_account
    Company.update_sub_account(self) if Rails.env.production? && !self.name.blank?
  end
end
