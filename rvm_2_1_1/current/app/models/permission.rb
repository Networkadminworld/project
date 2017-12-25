class Permission < ActiveRecord::Base
   belongs_to :role
   belongs_to :feature

   def self.define_permissions(user)
    permissions = {}
    permissions_lists = Permission.find_by_sql("SELECT permissions.access_level,features.controller_name from permissions,features
             where features.id = permissions.feature_id and permissions.role_id = #{user.role_id}")
    permissions_lists.each do |permission|
      permissions["#{permission.controller_name}"] = {} if permissions["#{permission.controller_name}"].nil?
      permissions["#{permission.controller_name}"] = permission.access_level
    end
    permissions
   end

   def self.check_controller_permission(controller,user,permissions)
    permissions.keys.include?(controller) ? true : false
   end

   def self.check_action_permission(action,controller,permissions)
    permissions[controller][action]
   end

   def self.check_user_role_permissions(controller,action,current_user,permissions)
     if Permission.check_controller_permission(controller,current_user,permissions)
        Permission.check_action_permission(action,controller,permissions)
      else
       false
     end
    end

  def self.check_feature_permission(feature_id,role_id)
    permission = where(role_id: role_id,feature_id: feature_id)
    permission.blank? ? false : permission[0].access_level
  end

  def self.update_or_create(feature_id,role_id,access_level)
    permission = where(feature_id: feature_id, role_id: role_id).first
    if permission.blank? && access_level != 0
      self.create(feature_id: feature_id, role_id: role_id,access_level: access_level)
    elsif permission && permission.access_level != access_level
      permission.update(access_level: access_level)
    end
  end

  def self.update_permissions(params)
    params["permission"].each do |permission|
      permissions = where(feature_id: permission["feature_id"], role_id: params["role_id"]).first
      permissions.update(access_level: permission["access_level"])
    end
  end

  def self.default_permissions(role)
    features = Feature.all
    features.each do |feature|
      unless feature.controller_name == "jb_pipeline" || feature.controller_name == "coolberryz_pipeline"
        access = feature.parent_id == 0 && feature.sub_features.count > 0 ? true : false
        create(feature_id: feature.id, role_id: role.id, access_level: access)
      end
    end
    jb_admin = User.where(email: "admin.jb@inquirly.com").first
    if jb_admin && jb_admin.id == role.user_id
      feature = Feature.where(controller_name: "jb_pipeline").first
      create(feature_id: feature.id, role_id: role.id, access_level: true) if feature
    end
    coolberryz_admin = User.where(email: "inquirly@coolberryz.com").first
    if coolberryz_admin && coolberryz_admin.id == role.user_id
      feature = Feature.where(controller_name: "coolberryz_pipeline").first
      create(feature_id: feature.id, role_id: role.id, access_level: true) if feature
    end
  end

  def self.role_permissions(params)
    feature_id = Permission.where(role_id: params[:role_id]).map(&:feature_id)
    main_feature = Feature.where(id: feature_id, parent_id: 0)
    sub_feature = Feature.where(id: feature_id).where.not(parent_id: 0)
    list = []
    main_feature.each do |feature|
      json = {}
      json["id"] = feature.id
      json["title"] = feature.title
      json["access_level"] = Permission.access(params[:role_id],feature.id)
      json["sub_features"] = []
      sub_features = sub_feature.where(parent_id: feature.id)
      sub_features.each do |s_feature|
          sub_json = {}
          sub_json["id"] = s_feature.id
          sub_json["title"] = s_feature.title
          sub_json["access_level"] = Permission.access(params[:role_id],s_feature.id)
          json["sub_features"] << sub_json
      end
      list << json
      end
    list
  end

  def self.access(role_id, feature_id)
    Permission.where(role_id: role_id, feature_id: feature_id).first.access_level
  end
end
