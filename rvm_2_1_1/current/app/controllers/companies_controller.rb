class CompaniesController < ApplicationController
  before_filter :authenticate_user_web_api, except: [:get_company_info]
  respond_to :json

  def index
    company,tags,industry_types,user_config = Company.get_company_data(current_user)
    render json: { data: company, tags: tags, attachment: company_attachment(company),industry_types: industry_types, config: user_config }
  end

  def create
    company = Company.update_details(params["company"]["data"],params["company"]["tags"],current_user,company_params)
    render json: company.errors.blank? ? { data: company, attachment: company_attachment(company) } : {error: company.errors }
  end

  def get_tags
    render :json => IndustryTag.tags_list(params)
  end

  def get_company_info
    begin
      @current_user = User.where(id: params[:user_id]).first
      if @current_user
        response = { status: 200, response: Company.get_info(@current_user)}
      else
        response = { status: 400, error: "User ID should not be blank"}
      end
    rescue Exception => e
      response = { status: 400, error: "Error: #{e}"}
    end
    render :json => response
  end

  private

  def company_params
    params.require(:company).permit(:name,:logo_url,:address,:area,:description,:company_type_id,:industry_id,:website_url,:facebook_url,:twitter_url,:linkedin_url,:redirect_url,:user_id,:lat,:lng,:thank, :reply, :engage).merge(user_id: current_user.id)
  end

  def company_attachment(company)
      company = company ? Company.where(id: company.id).first : nil
      company && company.attachment ? company.attachment.image.url(:square) : ''
  end

end
