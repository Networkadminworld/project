class AccountController < ApplicationController
  before_filter :authenticate_user_web_api, except: [:invite_user]
  respond_to :json
  before_action :set_csrf, only: [:invite_user]

  def payment_details
    transactions = TransactionDetail.build_transactions(current_user.id,params)
    current_plan = PricingPlan.find_pricing_plan(current_user.business_type_id).first.try(:plan_name)
    plan_expiry_date = current_user.exp_date.strftime("#{current_user.exp_date.day.ordinalize} of %b, %Y")
    render :json => { payment_history: transactions.to_json, current_plan: current_plan, expiry_date: plan_expiry_date }
  end

  def user_settings
     user_details = User.where(id: current_user.id).first
     profile_image = user_details.avatar ? user_details.avatar.url(:medium) : ''
     render :json => { details: user_details, profile: profile_image, is_tenant_user: user_details.is_tenant_user?, currencies: Currency.all.to_json }
  end


  def update_password
    user = User.find(current_user.id)
    if user.update_with_password(user_params)
      render :json => { success: "Well done! You password has been changed successfully." }
    else
      render :json => { errors: user.errors }
    end
  end

  def update_user_details
    user = User.where(id: params[:user][:id]).first
    if user
      prev_unconfirmed_email = user.respond_to?(:unconfirmed_email) ? user.unconfirmed_email : nil
      resource_params = update_params.merge(:step => "3")
      if user.update_without_password(resource_params)
        flash_key = update_needs_confirmation?(user, prev_unconfirmed_email) ? "Your email address has been updated successfully. Please check your email and click on the confirmation link to confirm your new email address." : "Your account was updated successfully."
        render json:  {account: user, success: flash_key }
      else
        render json: {errors: user.errors }
      end
    else
      render json: failure_token_missing
    end
  end

  def upload_profile_image
    render json: User.update_avatar(current_user,params["file"])
  end

  def destroy_profile_image
    render json: User.remove_avatar(params)
  end

  def user_details
    user_attachment = current_user.avatar && !current_user.default_url? ? current_user.avatar.url(:thumb) : ''
    company_attachment = (current_user.tenant_id && current_user.tenant_id!=0) ? tenant_logo(current_user) : company_logo(current_user)
    render :json => { id: current_user.id,
                      first_name: current_user.first_name,
                      last_name: current_user.last_name,
                      user_attachment: user_attachment,
                      area: area(current_user),
                      address: address(current_user),
                      company_attachment: company_attachment,
                      industry: current_user.parent_id == 0 ?
                              current_user.company.industry_tag.try(:industry) : current_user.client.company.industry_tag.try(:industry),
                      permissions: session[:user_permissions],
                      is_service_user: session[:is_service_user],
               }
  end

  def user_permissions
    render :json => session[:user_permissions]
  end

  def invite_user
    render json: Invite.send_invite(params)
  end

  private

  def user_params
    params.required(:user).permit(:current_password, :password, :password_confirmation)
  end

  def update_params
    params.required(:user).permit(:id, :first_name, :last_name, :email, :mobile, :currency_id)
  end

  def update_needs_confirmation?(resource, previous_email)
    resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation? && previous_email != resource.unconfirmed_email
  end

  def set_csrf
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def company_logo(user)
    user = user.parent_id == 0 ? user : user.client
    user.company && user.company.attachment ? user.company.attachment.image.url(:square) : ''
  end

  def tenant_logo(user)
    user.tenant && user.tenant.logo_url ? user.tenant.logo_url : ''
  end

  def address(user)
    if user.tenant_id
      user.tenant.try(:address)
    elsif user.parent_id == 0
      user.company.try(:address)
    else
      user.client.company.try(:address)
    end
  end

  def area(user)
    if user.tenant_id
      ''
    elsif user.parent_id == 0
      user.company.try(:area)
    else
      user.client.company.try(:area)
    end
  end
end
