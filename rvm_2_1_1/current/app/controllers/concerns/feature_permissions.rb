module FeaturePermissions
  extend ActiveSupport::Concern
  included do

    def edit
      @parent_features = Feature.get_parent_features
    end

    def update
      features = params[:parent_feature].merge!(params[:sub_feature])
      features.each do |key, value|
        Permission.update_or_create(key.to_i,params[:id].to_i,value.to_i)
      end
      flash[:notice] = 'Permissions were successfully updated.'
      redirect_to admin_permissions_path
    end
  end
end