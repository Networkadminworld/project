class CustomersController < ApplicationController
  before_filter :authenticate_user_web_api

  def index
    render :json => BusinessCustomerInfo.build_business_customer_json(current_user,params)
	end

	def create
    render :json => BusinessCustomerInfo.insert_customer(customer_params,current_user,params[:contact_groups],params[:is_consumer])
  end

	def update
    render :json => BusinessCustomerInfo.update_customer(customer_params.merge({id: params[:id]}),current_user,params[:contact_groups],params[:is_consumer])
  end

	def destroy
		render :json => BusinessCustomerInfo.remove_customer(params,current_user)
  end

  def remove_social_account
    render :json => BusinessCustomerInfo.remove_social_account(params,current_user)
  end

  def get_customer_email
    @customer_email = @current_user.business_customer_infos.pluck(:email) if @current_user.business_customer_infos
    @customer_email.present? ? (render json: success({ customer_email:@customer_email})) : (render json: failure({ errors: "No customer details found" }))
  end

  def all_countries
    country_list = []
    Country.all.each do |country|
      country_list << [country.first, country.last]
    end
    render :json => country_list
  end

  def states
    states_list = []
    country = BusinessCustomerInfo.check_country(params[:name])
    states = country.nil? ? [] : country.states
    states.each do |state|
      states_list << [state.last["name"], state.last["names"]]
    end
    render :json => states_list
  end

  def update_config
    config = UserConfig.mobile_info(current_user,params)
    render :json => config
  end

  def update_group_info
    render :json => BusinessCustomerInfo.update_group(current_user,params)
  end

  def contact_groups
    render :json => ContactGroup.group_list(current_user)
  end

  def group_customers
    render :json => BusinessCustomerInfo.build_group_customer_json(current_user,params)
  end

  def update_group_name
    render :json => ContactGroup.update_group(params,current_user)
  end

  def remove_group
    render :json => ContactGroup.remove_group(params,current_user)
  end

  def remove_group_customer
    render :json => ContactGroup.remove_group_customer(params,current_user)
  end

  private

  def customer_params
    params.require(:customer).permit(:customer_name, :email, :mobile, :age, :gender, :country, :city, :state, :area,:custom_field)
  end
end
