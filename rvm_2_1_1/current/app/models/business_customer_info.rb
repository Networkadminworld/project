class BusinessCustomerInfo < ActiveRecord::Base
  include CsvUploadStatus
  include CsvImport
  include CustomerInfo
  include MandrillApi
  include CsvProcess
  include ValidateCsv
  include CsvFilter
  include CustomerGroupInfo

  validates_presence_of :email, :if => Proc.new { |c| c.email.blank? && c.mobile.blank? }
  validates :email, :uniqueness => {:scope => :user_id}, :if => Proc.new { |c| !c.email.blank?  }
  validates_presence_of :mobile, :if => Proc.new { |c| c.email.blank? }
  validates_format_of :email, :with => /\A[A-Za-z0-9._%+-]+@(?:[A-Za-z0-9-]{2,22}\.){1,2}[A-Za-z]{2,4}\Z/, :if => Proc.new { |c| !c.email.blank? }
  validates_format_of :mobile, :with => /\A[0-9]+\Z/, :if => Proc.new { |c| !c.mobile.blank? }
  validates :age, numericality: { only_integer: true }, :if => Proc.new { |c| !c.age.blank? }
  validates_presence_of :country, :if => Proc.new { |c| !c.mobile.blank? }
  belongs_to :user
  has_many :campaigns
  has_many :campaign_channels
  belongs_to :consumer
  has_and_belongs_to_many :contact_groups,
                          :association_foreign_key => 'contact_group_id',
                          :class_name => 'ContactGroup',
                          :join_table => 'customers_contact_groups',
                          :after_add => :create_mobile_channels,
                          :after_remove => :remove_mobile_channels
  after_create :update_share_detail
  before_save :email_downcase
  after_save :update_in_all_customers
  after_update :update_mobile_channels

  CUSTOMER_INFO = ["BusinessCustomerInfo"]

  def self.insert_customer_info(file,group_id,user)
    csv_insert(file,group_id,user)
  end

  def self.create_csv_to_export(error_hash_value, user)
    all_data = error_hash_value
    tmp_file_path = "/tmp/customer_info_#{ user.id }.csv"
    CSV.open(tmp_file_path, "wb") do |csv|
      csv << all_data.first.keys
      all_data.each do |hash|
        csv << hash.values
      end
    end
  end

  def self.build_business_customer_json(user,params)
    customer_list =  customers_list(user,params)
    business_customers = customer_list.paginate(:page => params[:page], :per_page => params[:per_page].to_i).order(:id => :desc)
    business_customer_infos = {}
    business_customer_infos["customers_list"] = []
    business_customer_infos["customers_list"] << business_customers.to_json
    business_customer_infos["num_results"] = customer_list.count
    business_customer_infos
   { customers_list: business_customer_infos, groups:  user.contact_groups ? ContactGroup.group_list(user).to_json : [],
        config:  user.user_config && user.user_config.engage ? user.user_config.try(:engage)['mobile_config'] : '',is_csv_processed: user.is_csv_processed }
  end

  def self.customers_list(user,params)
    if params[:search_text].blank?
      where("user_id =? and is_deleted is NULL #{filter_business_customers(params)}", user.id)
    else
      where("(email ILIKE ? or mobile ILIKE ? or customer_name ILIKE ?) and user_id =?
          and is_deleted is NULL #{filter_business_customers(params)}", "%#{params[:search_text]}%","%#{params[:search_text]}%","%#{params[:search_text]}%",user.id)
    end
  end

  def self.filter_business_customers(params)
    condition = {}
    real_filters = []
    params[:logic] = " and "
    filters = JSON.parse(params[:filter_condition])
    filters.each { |filter| real_filters << filter if filter["value"].present? }
    (0..real_filters.count-1).each { |f| condition[f] = real_filters[f] }
    filter_condition(condition,params[:logic])
  end

  def self.insert_customer(user_data,user,contact_groups,is_consumer)
    user_data["mobile"] = self.add_country_code(user_data["mobile"],user_data["country"])
    contact = user.business_customer_infos.create(user_data)
    user.add_customer_status
    update_group_and_status(contact,contact_groups) if contact.errors.try(:messages).blank?
    create_consumer_id(user_data,contact,user) if contact.errors.try(:messages).blank? && is_consumer
    contact.errors.try(:messages).blank? ? [] : { errors: contact.errors.try(:messages) }
  end

  def self.create_consumer_id(user_data,contact,user)
    Consumer.invite_consumer(user_data,user)
    consumer = Consumer.check_consumer_subscribed(contact)
    contact.update_attributes(consumer_id: consumer.id,is_active_consumer: consumer.is_active) if consumer
  end

  def self.group_list(contact_groups,user_id)
    contact_groups.blank? || contact_groups.nil? ? ContactGroup.where(id: ContactGroup.group_id(user_id)) : ContactGroup.where(id: contact_groups)
  end

  def self.update_group_and_status(contact,contact_groups)
    groups = group_list(contact_groups,contact.user_id)
    groups.each do |group|
      contact.contact_groups << group unless contact.contact_groups.include?(group)
    end
  end

  def self.update_customer(params,user,contact_groups,is_consumer)
    biz_user = where(id: params[:id], user_id: user.id).first
    params[:mobile] = update_country_code(params,biz_user.country,biz_user.mobile)
    customer = biz_user.update_attributes(params)
    update_group_and_status(biz_user,contact_groups) if customer
    update_consumer_id(biz_user,is_consumer,user) if customer
    customer ? [] : { errors: biz_user.errors.try(:messages) }
  end

  def self.update_consumer_id(contact,is_consumer,user)
    if contact.consumer_id && !is_consumer
      contact.update_attributes(consumer_id: nil)
    elsif !contact.consumer_id  && is_consumer
      consumer = Consumer.check_consumer_subscribed(contact)
      if consumer.blank?
        user_data = {:email => contact.email, :customer_name => contact.customer_name, :gender => contact.gender, :mobile => contact.mobile }.stringify_keys!
        Consumer.invite_consumer(user_data,user)
        consumer = Consumer.check_consumer_subscribed(contact)
        contact.update_attributes(consumer_id: consumer.id, is_active_consumer: consumer.is_active)
      else
        contact.update_attributes(consumer_id: consumer.id, is_active_consumer: consumer.is_active)
      end
    end
  end

  def self.add_country_code(mobile,country,is_csv = nil)
     country = check_country(country)
     c_code = country ? country.country_code : ''
     mobile_number = mobile.blank? ? "" : "#{c_code}#{mobile}"
     mobile_number
  end

  def self.update_country_code(params,country,mobile_num)
    if country
      country = check_country(country)
      existing_c_code = country ? country.country_code : ''
      m_number = (params[:mobile] == mobile_num) ? mobile_num.remove(existing_c_code) : params[:mobile]
    else
      m_number = params[:mobile]
    end
    add_country_code(m_number,params[:country])
  end

  def self.to_csv
    CSV.generate do |csv|
      column_names = ["customer_name", "email", "age", "gender", "mobile", "country", "state", "city", "area", "custom_field"]
      csv << column_names
      all.each do |customer|
        csv << customer.attributes.values_at(*column_names)
      end
    end
  end

  def self.sub_account_create(user)
    create_mandrill_sub_account(user)
  end

  def self.check_country(country)
    Country.find_country_by_alpha2(country) || Country.find_country_by_name(country)
  end

  def self.update_group(user,params)
    update_group_value(user,params)
  end

  def self.build_group_customer_json(user,params)
    group =  ContactGroup.where(id: params[:group_id]).first
    business_customers = group.business_customer_infos.paginate(:page => params[:page], :per_page => params[:per_page].to_i).order(:id => :desc)
    business_customer_infos = {}
    business_customer_infos["customers_list"] = []
    business_customer_infos["customers_list"] << business_customers.to_json
    business_customer_infos["num_results"] = group.business_customer_infos.count
    business_customer_infos
    { customers_list: business_customer_infos }
  end

  def self.remove_social_account(params,user)
    account = UserSocialChannel.where(id: params[:id]).first
    if account
      account.update(active: false)
      user.remove_social_status
    end
    { status: account ? 200 : 403 }
  end

  def self.remove_customer(params,user)
    where(id:params[:id]).first.destroy
    user.remove_customer_status
    { status: 200 }
  end

  def self.update_reject_list(event_data)
    event_data.each do |data|
      where(email: data["msg"]["email"]).update_all(status: data["msg"]["state"]) if data["msg"]
    end
  end

  private

  def self.remaining_upload_limit(user)
    if user.parent_id != 0
      user_ids = User.where(parent_id: user.parent_id).map(&:id)
      user_lists = user_ids << user.parent_id
      user_count = total_records_count(user_lists)
    elsif user.parent_id == 0
      user_ids = User.where(parent_id: user.id).map(&:id)
      user_lists = user_ids << user.id
      user_count = total_records_count(user_lists)
    else
      user_count = total_records_count([user.id])
    end
    already_uploaded_count(user, user_count)
  end

  def self.already_uploaded_count(user, count)
    response = PricingPlan.fetch_client_config({client_id: user.id})
    response[:status] == 200 ? response[:response][:plan_detail]["customer_records_count"] - count : 0
  end

  def self.total_records_count(user_ids)
    where(user_id: user_ids).count
  end

end