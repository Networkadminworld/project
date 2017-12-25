class Rest::SessionsController < ::Devise::SessionsController
	include ResponseStatus
  include HashConverter
	respond_to :json
	
	def create
	  resource = User.find_by_email(params[:email])
	  respond_to do |format|
      if resource.present? && resource.valid_password?(params[:password])
        if resource.confirmed? &&  !resource.locked_at && resource.is_active
          resource.devices.create(device_id: params[:deviceID]) if params[:deviceID] && Device.new_device?(params[:deviceID],resource)
          sign_in(:user, resource)
          resource.update_session(session.id)
          format.json { render :json => success({resCode: 200, resMessage: "SUCCESS"},
              HashConverter.to_camel_case(
                  { email_id: resource.email,
                    unique_id: resource.uid,
                    user_id: resource.id,
                    user_name: resource.full_name,
                    user_security_token: session.id,
                    business_name: resource.company.try(:name),
                    business_image_url: company_image(resource.company),
                    profile_image_url: resource.profile_image,
                    business_location: resource.company.try(:area),
                    role_name: resource.role.try(&:name),
                    role_id: resource.role.try(:id),
                    permissions: resource.permissions }.stringify_keys!))}
        else
          error_message = resource && resource.locked_at ? "Your account is locked. Please check your email." : "Your email address is either incorrect or not yet confirmed. Please update or confirm your e-mail address."
          format.json { render :json => failure({resCode: 3001, resMessage: error_message})}
        end
      else
        if resource && resource.locked_at
          msg = "Your account is locked. Please check your email."
        elsif resource && !resource.is_active
          msg = "Your account is deactivated. Please contact #{resource.client ? resource.client.email : ENV["ADMIN_EMAIL"]} for the access."
        else
          msg = "Invalid email or password."
        end
        format.json { render :json => failure({resCode: 3001, resMessage: msg }) }
      end
	  end
  end

  private

  def company_image company
	  company && company.attachment ? company.attachment.image.url : nil
  end
end
