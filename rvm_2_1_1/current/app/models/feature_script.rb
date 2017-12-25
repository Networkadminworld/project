class FeatureScript
	
	def initialize
		@features = Feature.all
		@users = User.all.where.not(email: ["inq-admin@inquirly.com",ENV["ADMIN_EMAIL"],"inq-analyst@inquirly.com"])
	end
	
	def update_new(value,controller_name,action_name,parent_id)
		if @features.where(title: value, controller_name: controller_name,action_name: action_name).first.blank?
			new_feature = Feature.create(parent_id: parent_id, title: value, controller_name: controller_name,action_name: action_name)
      insert_block(new_feature)
		else
			exist_feature = Feature.where(title: value, controller_name: controller_name,action_name: action_name).first
      insert_block(exist_feature)
		end
  end

  def insert_block(feature)
    @users.each do |user|
      if user.role_id && Permission.where(role_id: user.role_id,feature_id: feature.id).blank?
        Permission.create(role_id: user.role_id, access_level: false, feature_id: feature.id)
      end
    end
  end
end
