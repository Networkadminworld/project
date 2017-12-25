class Admin::PricingPlansController < InheritedResources::Base
  before_action :check_admin_user
  before_filter :authenticate_user_web_api
  before_action :load_channels, only: [:new, :create, :edit, :update]
  layout 'admin_layout'

  def index
    @pricing_plans = PricingPlan.all.order(:id).paginate(:page => params[:page], :per_page => 10)
    respond_to do |format|
      format.html
      format.json { render json: @pricing_plans }
    end
  end

  def show
    @pricing_plan = PricingPlan.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @pricing_plan }
    end
  end

  def new
    @pricing_plan = PricingPlan.new
    respond_to do |format|
      format.html
      format.json { render json: @pricing_plan }
    end
  end

  def edit
    @pricing_plan = PricingPlan.find(params[:id])
  end

  def create
    @pricing_plan = PricingPlan.new(pricing_params)
    respond_to do |format|
      if @pricing_plan.save
        @pricing_plan.create_or_update_channel_list(params[:channels_id])
        format.html { redirect_to admin_pricing_plans_path, notice: 'Pricing plan was successfully created.' }
        format.json { render json: @pricing_plan, status: :created, location: @pricing_plan }
      else
        format.html { render action: "new" }
        format.json { render json: @pricing_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @pricing_plan = PricingPlan.find(params[:id])
    respond_to do |format|
      if @pricing_plan.update_pricing_details(pricing_params, params[:channels_id])
        format.html { redirect_to admin_pricing_plans_path, notice: 'Pricing plan successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pricing_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def pricing_params
    params.require(:pricing_plan).permit(:name, :country, :email_count,:sms_count,:campaigns_count,:customer_records_count,:fb_boost_budget,:currency_id, :is_default, :total_reach)
  end

  def load_channels
    @channels = Channel.all
  end

end