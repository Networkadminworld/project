module ClientWizard
  extend ActiveSupport::Concern
  included do

    def plan_settings
      @pricing_plan = PricingPlan.where(id: params[:plan_id]).first
      @channels = Channel.all
    end

    def client_company
      @company = find_client.company ? find_client.company : Company.new
    end

    def client_pricing_plan
      @pricing_plans =  PricingPlan.all.order(:id)
      @client_pricing_plans = find_client.client_pricing_plans
      @active_plan = find_client.active_pricing_plan if @client_pricing_plans
      @expiry_months = (1..DEFAULTS["max_expiry_months"]).to_a
    end

    def save_client
      user = User.new(user_form_params)
      if user.valid?
        user.skip_confirmation!
        user.save
        BusinessCustomerInfo.sub_account_create(user)
        render :json => { status: 200, id: user.id }
      else
        render :json => { status: 400, errors: user.errors }
      end
    end

    def save_client_company
      company = Company.new(company_form_params)
      if company.valid?
        company.save
        company.save_tags(params[:tag_values])
        render :json => { status: 200, id: company.id, user_id: company.user_id }
      else
        render :json => { status: 400, errors: company.errors}
      end
    end

    def save_client_pricing_plan
      ClientPricingPlan.save_client_plan(pricing_plan_form_params)
      render :json => { status: 200 }
    end

    def update_client_company
      tag_lists = []
      params[:tag_values] && params[:tag_values].each do |tag|
        tags = {}
        tags["text"] = tag
        tag_lists << tags
      end
      company = Company.update_details(nil,tag_lists,find_client,company_form_params)
      render :json => { status: 200, id: company.id, user_id: company.user_id }
    end

    def client_plan_details
      @current_plan = find_client.active_pricing_plan
      @exp_date = find_client.client_pricing_plans.all.map(&:exp_date).max.strftime("%Y/%m/%d")
      @channels = Channel.where(id: @current_plan.pricing_plan_channels.map(&:channel_id))
    end

    private

    def user_form_params
      params.required(:user).permit(:first_name, :last_name, :email, :mobile, :password, :password_confirmation,:role_id)
    end

    def company_form_params
      params.required(:company).permit(:id, :name, :address, :industry_id, :tag_values, :user_id)
    end

    def pricing_plan_form_params
      params.required(:pricing_plan).permit(:id, :start_date, :end_months, :client_id, :client_type, :action)
    end

    def find_client
      User.where(id: params[:company] ? params[:company][:user_id] : params[:client_id]).first
    end

  end
end