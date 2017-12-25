class CreatePricingPlanSchemas < ActiveRecord::Migration
  def change
    remove_column :pricing_plans, :business_type_id, :integer
    remove_column :pricing_plans, :language_count, :integer
    remove_column :pricing_plans, :expired_date, :datetime
    remove_column :pricing_plans, :question_suggestions, :integer
    remove_column :pricing_plans, :questions_count, :integer
    remove_column :pricing_plans, :video_photo_count, :integer
    remove_column :pricing_plans, :qr_share, :integer
    remove_column :pricing_plans, :call_count, :integer
    remove_column :pricing_plans, :social_share, :boolean
    remove_column :pricing_plans, :embed_share, :boolean
    remove_column :pricing_plans, :listener, :boolean
    remove_column :pricing_plans, :redirect_url, :boolean
    remove_column :pricing_plans, :from_number, :boolean
    remove_column :pricing_plans, :listener_slots, :boolean
    remove_column :pricing_plans, :crawler_slots, :boolean
    remove_column :pricing_plans, :email_alerts, :boolean
    remove_column :pricing_plans, :tenant_count, :integer
    remove_column :pricing_plans, :customer_records_count, :integer

    add_column :pricing_plans, :campaigns_count, :integer
    add_column :pricing_plans, :fb_boost_budget, :float
    add_column :pricing_plans, :currency_id, :integer
    add_column :pricing_plans, :is_default, :boolean
    add_column :pricing_plans, :customer_records_count, :integer
    add_column :pricing_plans, :total_reach, :integer
    add_column :pricing_plans, :is_active, :boolean

    rename_column :pricing_plans, :plan_name, :name

    create_table :channels do |t|
      t.string :name
      t.timestamps
    end

    create_table :pricing_plans_channels, id: false do |t|
      t.integer :pricing_plan_id, index: true
      t.integer :channel_id, index: true
    end

    create_table :currencies do |t|
      t.string :name
      t.timestamps
    end

    remove_column :users, :company_name, :string
    remove_column :users, :business_type_id, :integer
    remove_column :users, :provider, :string
    remove_column :users, :twitter_oauth_token,  :string
    remove_column :users, :twitter_oauth_secret,  :string
    remove_column :users, :linkedin_token,  :string
    remove_column :users, :linkedin_secret_token,  :string
    remove_column :users, :role,  :string
    remove_column :users, :fb_status,  :string
    remove_column :users, :twitter_status, :string
    remove_column :users, :linkedin_status, :string
    remove_column :users, :email_content, :string
    remove_column :users, :sms_content, :string
    remove_column :users, :call_content, :string
    remove_column :users, :redirect_url, :string
    remove_column :users, :from_number, :string
    remove_column :users, :distribute_pricing_plan_id, :integer
    remove_column :users, :currency_code, :string

    add_column :users, :currency_id, :integer
    add_column :users, :invite_code, :string

    create_table :client_pricing_plans do |t|
      t.integer :client_id
      t.string  :client_type
      t.integer :email_count
      t.integer :sms_count
      t.integer :customer_records_count
      t.integer :campaigns_count
      t.float   :fb_boost_budget
      t.integer :pricing_plan_id
      t.boolean :is_active
      t.datetime :start_date
      t.datetime :exp_date
      t.timestamps
    end

    remove_column :share_details, :questions_count, :integer
    remove_column :share_details, :video_photo_count, :integer
    remove_column :share_details, :call_count, :integer

    add_column :share_details, :campaigns_count, :integer
    add_column :share_details, :fb_boost_budget, :float
    add_column :share_details, :is_current, :boolean

    remove_column :share_summaries, :questions_count, :integer
    remove_column :share_summaries, :video_photo_count, :integer
    remove_column :share_summaries, :call_count, :integer
    remove_column :share_summaries, :last_shared_date, :datetime

    add_column :share_summaries, :fb_reach, :integer
    add_column :share_summaries, :campaign_id, :integer
    add_column :share_summaries, :share_detail_id, :integer

    create_table :user_invites do |t|
      t.string  :email
      t.integer :user_id
      t.boolean :is_onboarded
    end

    rename_column :transaction_details, :business_type_id, :pricing_plan_id

  end
end
