module UserValidation
  extend ActiveSupport::Concern
  included do
    scope :find_user, lambda { |id| where('id=?', id) }
    scope :fetch_trial_expire_user, lambda { where('subscribe=? AND exp_date < ? AND is_active = ? ', false,Time.now.utc,true) }
    scope :fetch_subscribed_expire_user, lambda { where('subscribe=? AND exp_date < ? AND is_active = ? ', true,Time.now.utc,true) }
    scope :tenant_name, lambda { |t_id| Tenant.where(id: t_id).first.try(:name) }
    scope :role_name, lambda { |r_id| Role.where(id: r_id).first.try(:name) }
    scope :get_all_users, lambda { |user| user.parent_id == 0 ? where(parent_id: user.id) : where(parent_id: user.parent_id)}

    devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :token_authenticatable, :omniauthable, :confirmable, :lockable #:validatable,


    has_many :transaction_details
    has_many :business_customer_infos
    belongs_to :role
    has_many :tenants, foreign_key: :client_id
    belongs_to :tenant
    has_many :corporate_user, class_name: "User",foreign_key: "parent_id"
    has_many :executive_tenant_mappings
    has_one :company, dependent: :destroy
    has_many :contact_groups
    has_many :user_channels
    has_many :campaigns
    has_many :service_campaigns, foreign_key: :service_user_id
    has_one  :user_config
    has_many :devices, dependent: :destroy
    has_many :user_action_lists
    has_many :action_lists, through: :user_action_lists
    has_many :user_social_channels, dependent: :destroy
    has_many :user_mobile_channels, dependent: :destroy
    has_many :tags
    has_many :beacons
    has_many :user_location_channels, dependent: :destroy
    has_many :alert_events, dependent: :destroy
    has_many :alert_logs, dependent: :destroy
    has_many :executive_business_mappings, dependent: :destroy
    has_many :schedule_types
    has_many :client_pricing_plans, as: :client
    has_one  :currency

    has_attached_file :avatar,
                      :styles => { medium: "300x300>", thumb: "100x100>" },
                      :storage => :s3,
                      :s3_credentials => {
                          :bucket => ENV['AWS_BUCKET'],
                          :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
                          :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
                      }
    validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

    validates_confirmation_of :password, :message => "Your passwords should match."

    validates :first_name, :presence => {:message => " Please enter first name."}, :format => {:with => /[a-zA-Z]/, :message => "First Name should have atleast one alphabet"}, :if => Proc.new { |at| at.step != "5"}
    validates :last_name, :presence => {:message => "Please enter last name."}, :format => {:with => /[a-zA-Z]/, :message => "Last Name should have atleast one alphabet"}, :if => Proc.new { |at| at.step != "5" && at.step != "Multitenant" }
    validates_format_of :first_name,:with => /\A[A-Za-z0-9 .&]*\z/, :message => "First Name should not have special characters", :if => Proc.new { |at| at.step != "5"}
    validates_format_of :last_name, :with => /\A[A-Za-z0-9 .&]*\z/, :message => "Last Name should not have special characters", :if => Proc.new { |at| at.step != "5"}

    validates :email, :presence => {:message => "Please enter email address."}
    validates :email, :uniqueness => {:message => "Email address already exists."}
    validates_format_of :email, :with => /\A[A-Za-z0-9._%+-]+@(?:[A-Za-z0-9-]{2,22}\.){1,2}[A-Za-z]{2,4}\Z/, :message => "Please enter a valid email address.",:if => Proc.new { |at| at.step != "4"}

    validates :password, :presence => {:message => "Please enter Password"}, if: :validate_proc_method?

    validates_format_of :password,:with => /\A(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,16}\z/, message: "Password length should be 6-16 characters and must contain at least 1 number, 1 small letter, 1 capital letter.", if: :validate_proc_method?
    validates :password_confirmation, :presence => {:message => "Please enter confirm password."}, if: :validate_proc_method?
    validates :current_password, :presence => {:message => "Please enter current password."}, :if => Proc.new { |at| at.step == "password_enabled" }

    validates :first_name, :length => {:within => 2..20, :message => "First name should be min 2 and max 20 characters."}, :if => Proc.new { |at| at.step != "5"}
    validates :last_name, :length => {:within => 2..20, :message => "Last name should be min 2 and max 20 characters."}, :if => Proc.new { |at| at.step != "5" && at.step != "Multitenant"}
    validates :role_id, :presence => {:message => "Select a Role Name."}, :if => Proc.new { |at| at.step == "Multitenant"}
    validates :mobile, :length => {:within => 8..15, :message => "Mobile number length should be min 8 and max 15 characters."}, :if => Proc.new { |at| !at.mobile.nil? && at.mobile != '' && at.step != "5" && at.step != "Multitenant" && at.step != nil}
    validates_format_of :mobile, :with => /\d[0-9]\)*\z/, :if => Proc.new { |at| !at.mobile.nil? && at.mobile != '' && at.step != "5" && at.step != "Multitenant" && at.step != nil}


    def self.user_status_result(pres,resource_params,current_user,params,resource)
      if pres
        result = resource.update_with_password(resource_params)
      elsif !pres && params[:hidden_pass] == "password_enabled"
        result = resource.update_without_password(resource_params.merge(:step => "2"))
      elsif !['facebook', 'linkedin', 'twitter', 'google_oauth2'].include? current_user[:provider]
        result = resource.update_with_password(resource_params.merge(:step => "provider"))
      else
        result = resource.update_without_password(resource_params.merge(:step => "3"))
      end
      return result
    end

  end

  def validate_proc_method?
      if self.step.to_i == 5 || self.step.to_s == "provider" || self.step.blank?
        true
      elsif self.step.to_i  == 2
        false
      end
  end

  def active_pricing_plan
    ClientPricingPlan.where(client_id: self.id, client_type: 'User', is_active: true).first
  end

end
