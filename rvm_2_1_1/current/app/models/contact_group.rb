class ContactGroup < ActiveRecord::Base
  has_and_belongs_to_many :business_customer_infos,
                          :association_foreign_key => 'business_customer_info_id',
                          :class_name => 'BusinessCustomerInfo',
                          :join_table => 'customers_contact_groups'
	belongs_to :user
  validates :name, :uniqueness => {:scope => :user_id, :message => "Group Name already exists."}

  def self.create_default_group(user_id)
    create(name: "All Customers", user_id: user_id)
  end

  def self.is_default_group?(group_id,user_id)
    where(id: group_id, user_id: user_id).first.try(:name) == "All Customers" ? true : false
  end

  def self.group_id(user_id)
    default_group = ContactGroup.where(name: "All Customers", user_id: user_id).first
    default_group = ContactGroup.create_default_group(user_id) unless default_group
    default_group.id
  end

  def self.update_group(params,user)
    group = where(id: params[:id],user_id: user.id).first
    group.update_attributes!(name: params[:name])
  end

  def self.remove_group(params, user)
    group = where(id: params[:id],user_id: user.id).first
    group.destroy
  end

  def self.remove_group_customer(params,user)
    group = where(id: params[:group_id],user_id: user.id).first
    updated_contacts = group.business_customer_infos.reject{ |obj| obj.id == params[:customer_id].to_i }
    group.business_customer_infos = updated_contacts
  end

  def self.group_list(user)
    groups = where(user_id: user)
    results = []
    groups.each do |group|
      json = {}
      json["id"] = group.id
      json["name"] = group.name
      json["contacts"] = group.business_customer_infos.count
      results << json
    end
    results
  end

  def self.all_contacts(user,ids,type)
    contact_group_ids = UserMobileChannel.where(id: ids).map(&:contact_group_id)
    groups = where(id: contact_group_ids, user_id: user.id).map(&:id)
    if type == "email"
      groups ? CustomersContactGroup.email_customers_count(groups) : 0
    elsif type == "sms"
      groups ? CustomersContactGroup.sms_customers_count(groups) : 0
    elsif type == "opinify"
      groups ? CustomersContactGroup.opinify_customers_count(groups) : 0
    end
  end

  def add_or_remove_email_channel
    if CustomersContactGroup.email_customers_count([self.id]) > 0
      UserMobileChannel.create_channels('email',self.id,self.user_id)
    else
      UserMobileChannel.remove_channels('email',self.id,self.user_id)
    end
  end

  def add_or_remove_sms_channel
    if CustomersContactGroup.sms_customers_count([self.id]) > 0
      UserMobileChannel.create_channels('sms',self.id,self.user_id)
    else
      UserMobileChannel.remove_channels('sms',self.id,self.user_id)
    end
  end

  def add_or_remove_opinify
    if CustomersContactGroup.opinify_customers_count([self.id]) > 0
      UserMobileChannel.create_channels('opinify',self.id,self.user_id)
    else
      UserMobileChannel.remove_channels('opinify',self.id,self.user_id)
    end
  end
end