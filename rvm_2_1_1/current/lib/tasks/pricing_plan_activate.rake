require 'csv'

namespace :user do
  task :pricing_plan_activate => :environment  do |t, args|
    users = User.all
    users.each do |user|
      user.client_pricing_plans.each do |pricing_plan|
        if pricing_plan.start_date == ActiveSupport::TimeZone["GMT"].parse(Time.now.strftime("%Y-%m-%d 12am"))
          user.client_pricing_plans.update_all(is_active: false)
          pricing_plan.update_attributes(is_active: true)
        end
      end
    end
  end

  task :update_pricing_plans => :environment do |t, args|
    file = "#{Rails.root}/public/live_pricing_plan_details.xlsx - live_users.csv"

    # Insert all Channels

    Channel.delete_all
    channel_list = %w(facebook twitter linkedin email sms qrcode beacon tablet inquirly)
    channel_list.each do |channel|
      Channel.create(name: channel)
    end

    # Insert Pricing Plans

    PricingPlan.delete_all
    list_of_plans = %w(Trial Loud Louder Loudest Enterprise)
    list_of_plans.each do |plan|
      new_plan = PricingPlan.new(name: plan, customer_records_count: PLAN[plan]["customer_records_count"], campaigns_count: PLAN[plan]["campaigns_count"],
                         sms_count: PLAN[plan]["sms_count"], email_count: PLAN[plan]["email_count"], total_reach: PLAN[plan]["total_reach"],
                         fb_boost_budget: PLAN[plan]["fb_boost_budget"], is_default: true)
      if new_plan.save
        channels_id = Channel.where(name: PLAN[plan]["channels"]).map(&:id)
        new_plan.create_or_update_channel_list(channels_id)
      end
    end


    # Map pricing Plan with User

    CSV.foreach(file, :headers => true, :header_converters => :symbol, :skip_blanks => true, :encoding => 'ISO-8859-1', :converters => :all) do |row|
      hash_val = Hash[row.headers[0..-1].zip(row.fields[0..-1])]
      if hash_val[:email] && hash_val[:plan_name]
        user = User.where(email: hash_val[:email]).first
        plan = PricingPlan.where(name: hash_val[:plan_name]).first
        if user && plan
          params = {id: plan.id, client_id: user.id, client_type: "User", start_date: hash_val[:start_date].present? ? hash_val[:start_date] : Date.today, end_months: hash_val[:no_of_months]}
          ClientPricingPlan.save_client_plan(params)
        end
      end
    end
  end
end