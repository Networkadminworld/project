class PaymentsController < ApplicationController
  layout 'admin_layout', :only => [:new]
  before_action :plan_details, :only => [:new]
  before_action :authenticate_user_web_api
  
  def update_payment_details
    if params[:user][:email].present? && params[:user][:action_name].present? && params[:user][:amount].present?
      user_detail = User.where(email: params[:user][:email].downcase).first
      if user_detail.parent_id == 0 || user_detail.parent_id == nil
        biz_type_id = params[:user][:plan_name].present? ? params[:user][:plan_name] : user_detail.business_type_id
        user_detail.account_subscribe(biz_type_id,params[:user][:exp_date])
        TransactionDetail.create(:user_id => user_detail.id, :amount => params[:user][:amount], :business_type_id => biz_type_id, :transaction_id => SecureRandom.hex(10), :expiry_date => params[:user][:exp_date], :active => true, :action => params[:user][:action_name], :payment_status => "completed", :order_id => SecureRandom.hex(32))
        InviteUser.payment_success(user_detail.email,user_detail.first_name).deliver
        flash[:notice] = APP_MSG["admin"]["payment_success"]
      else
        flash[:notice] = APP_MSG["admin"]["wrong_user"]
      end
    else
      flash[:notice] = APP_MSG["admin"]["payment_error"]
    end
    redirect_to "/payments/new"
  end

  def get_user_emails
    user = User.users_list(params[:term])
    render :json => user
  end
  
  private
  
  def plan_details
     @plans = PricingPlan.all.order("amount desc")
  end
end