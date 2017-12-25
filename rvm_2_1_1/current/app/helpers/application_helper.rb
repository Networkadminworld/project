module ApplicationHelper

  def selected_business(user,biz)
    user.executive_business_mappings.map(&:company_name).include?(biz.name) ? 'selected' : ''
  end

  def selected_channels(plan,channel,params)
    if params[:action] == 'new'
      params["channels_id"] && params["channels_id"].include?(channel.id.to_s)
    else
      plan.pricing_plan_channels.map(&:channel_id).include?(channel.id)
    end
  end

  def selected_country(plan)
    plan.new_record? ? 'IN' : plan.country
  end

  def selected_industry(company,industry)
    company.industry_id == industry["id"] ? 'selected' : ''
  end

  def upgrade_plan_start_date(user_id)
    user = User.where(id: user_id).first
    if user.is_trial_user?
      exp_date = Date.today.strftime("%Y/%m/%d")
    else
      exp_date = user.client_pricing_plans.map(&:exp_date).max
      exp_date = (exp_date + 1.day).strftime("%Y/%m/%d")
    end
    exp_date
  end

  def country_name(country_code)
    Country.find_country_by_alpha2(country_code).name || ''
  end

  def find_plan_name(plan_id)
    plan_id ? PricingPlan.where(id: plan_id).first.try(:name) : ''
  end

  def plan_color(client_plan)
    style = "font-size: 15px;cursor:pointer;"
    plan = client_plan.pricing_plan.name
    case plan.downcase
      when 'loudest'
        style += 'color: gold'
      when 'louder'
        style += 'color: silver'
      when 'loud'
        style += 'color: brown'
      when 'trial'
        style += 'color: red'
      else
        style += 'color: green'
    end
    style
  end
end
