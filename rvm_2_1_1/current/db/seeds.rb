
 # Default Role

  roles =  ['Individual','Inquirly-Admin','Inquirly-Analyst','Super-Admin','Executive']
  roles.each do |role|
   Role.where(name: role,is_default: true).first_or_create
  end

  # Default Features

  FEATURE_PERMISSIONS.keys.each do |feature|
    feature_split =  feature.split("-")
    parent = Feature.where(parent_id: 0 ,controller_name: "#{feature_split[0]}",action_name: "#{feature_split[0]}",title: "#{feature_split[1]}").first_or_create
    FEATURE_PERMISSIONS[feature] && FEATURE_PERMISSIONS[feature].each do |sub_feature|
      sub_split = sub_feature[0].split("-")
      Feature.where(parent_id: parent.id ,controller_name: "#{sub_split[0]}",action_name: "#{sub_split[0]}",title: "#{sub_split[1]}").first_or_create
    end
  end

  # Default role permissions

  PERMISSIONS.keys.each do |key|
    PERMISSIONS[key].each do |actions|
      permission_params = {}
      role = Role.where(name: key).first
      feature = Feature.where(controller_name: actions[0]).first
      access_level = actions[1] == 1 ? true : false
      permission_params.merge!("role_id" => role.id)
      permission_params.merge!("access_level" => access_level)
      permission_params.merge!("feature_id" => feature.id)
      Permission.where(permission_params).first_or_create
    end
  end

  # To create default pricing plans

  # Admin

# unless User.where("admin",true).exists?
#   resource = User.new(:first_name => "Admin", :last_name => "Admin", :email => "admin@inquirly.com", :password => "@Dmin1@#", :password_confirmation => "@Dmin1@#", :admin => true, :confirmed_at => Time.now, :step => "1", :is_active => true, :subscribe => true, :role_id => 24)
#   resource.save(:validate => false)
# end

#  # Inquirly-Admin role
#
#  inq_admin = User.where("email = ?","inq-admin@inquirly.com")
#  unless inq_admin.exists?
#    resource = User.new(:first_name => "Inquirly", :last_name => "Admin", :email => "inq-admin@inquirly.com", :password => "admin123", :password_confirmation => "admin123", :admin => true, :confirmed_at => Time.now, :step => "1", :is_active => true, :business_type_id => 4, :subscribe => true, :role_id => 2)
#    resource.save(:validate => false)
#  end
#
#  # Inquirly-Analyst role
#
#  inq_analyst = User.where("email = ?","inq-analyst@inquirly.com")
#  unless inq_analyst.exists?
#    resource = User.new(:first_name => "Inquirly", :last_name => "Analyst", :email => "inq-analyst@inquirly.com", :password => "admin123", :password_confirmation => "admin123", :admin => true, :confirmed_at => Time.now, :step => "1", :is_active => true, :business_type_id => 4, :subscribe => true, :role_id => 3)
#    resource.save(:validate => false)
#  end

  # Company Type

  company_type = ["Consultant", "Online Business", "Telemarketing", "Child Care Services", "Elementary & Secondary Education", "Tutoring Services", "Architect", "Building Construction", "Contractor", "Alcohol/Tobacco Sales", "Bakery", "Restaurant/Bar", "Accountant", "Auditing", "Investor"]
  company_type.each do |type|
    CompanyType.create(name: type)
  end

  # Share Type

	share_type = ["Social", "Mobile", "In-location", "Others"]
	share_type.each do |type|
		ShareMedium.create(share_type: type, is_active: true)
	end
	
	# Campaign Type

	campaign_type = ["Sales", "Engage", "Opinions", "Powershare"]
	campaign_type.each do |type|
		CampaignType.create(name: type)
  end

  # Pipeline Sates

  funnel_states = ["NEW","CONFIRMED","PENDING_DELIVERY","CANCELLED","FAILED","ASSIGNED",
                   "DISPATCHED","ENGAGED","SHIPPED","IN_TRANSIT","ARRIVED_AT_LOCATION","EN_ROUTE_DELIVERY","DELIVERED"]


  funnel_states.each do |item|
    FunnelState.create(:name=> item)
  end


  funnel_states = ["IN_NEGOTIATION","CUSTOMER_CONTACTED","CLOSED","REJECT"]

  funnel_states.each do |item|
    FunnelState.create(:name=> item)
  end


  funnel_types = ["FEEDBACK","SALES-PIPELINE", " MARKETING-PIPELINE"]

  funnel_types.each do |item|
    FunnelType.create(:name => item )
  end

  funnel_sources =  ["CAMPAIGN","CALL_CENTER","TENANT","WEB","SMS"]

  funnel_sources.each do |item|
    FunnelSource.create(:name=> item)
  end
