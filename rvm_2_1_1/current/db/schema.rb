# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.


ActiveRecord::Schema.define(version: 20160818112228) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "action_lists", force: true do |t|
    t.string   "action"
    t.float    "weight"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "addresses", force: true do |t|
    t.string   "line1"
    t.string   "line2"
    t.string   "city"
    t.string   "state"
    t.integer  "pincode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "alert_channels", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "alert_configs", force: true do |t|
    t.text     "email"
    t.text     "sms"
    t.text     "business_app"
    t.text     "consumer_app"
    t.integer  "alert_event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_html",        default: false
  end

  add_index "alert_configs", ["alert_event_id"], name: "index_alert_configs_on_alert_event_id", using: :btree

  create_table "alert_event_channels", force: true do |t|
    t.boolean  "is_active"
    t.integer  "alert_event_id"
    t.integer  "alert_channel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "alert_event_channels", ["alert_channel_id"], name: "index_alert_event_channels_on_alert_channel_id", using: :btree
  add_index "alert_event_channels", ["alert_event_id"], name: "index_alert_event_channels_on_alert_event_id", using: :btree

  create_table "alert_events", force: true do |t|
    t.string   "name"
    t.boolean  "is_set_on"
    t.integer  "user_id"
    t.integer  "company_id"
    t.integer  "alert_id"
    t.integer  "alert_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_default"
  end

  add_index "alert_events", ["alert_id"], name: "index_alert_events_on_alert_id", using: :btree
  add_index "alert_events", ["alert_type_id"], name: "index_alert_events_on_alert_type_id", using: :btree
  add_index "alert_events", ["user_id"], name: "index_alert_events_on_user_id", using: :btree

  create_table "alert_logs", force: true do |t|
    t.text     "event_params"
    t.string   "event_post_id"
    t.boolean  "is_viewed"
    t.integer  "user_id"
    t.integer  "alert_event_id"
    t.integer  "alert_channel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "alert_logs", ["alert_channel_id"], name: "index_alert_logs_on_alert_channel_id", using: :btree
  add_index "alert_logs", ["alert_event_id"], name: "index_alert_logs_on_alert_event_id", using: :btree
  add_index "alert_logs", ["user_id"], name: "index_alert_logs_on_user_id", using: :btree

  create_table "alert_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "alerts", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "answer_analyses", force: true do |t|
    t.integer  "answer_id",       null: false
    t.integer  "question_id",     null: false
    t.integer  "sentiment_score", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answer_analyses", ["answer_id"], name: "index_answer_analyses_on_answer_id", using: :btree
  add_index "answer_analyses", ["question_id"], name: "analyses_question_id", using: :btree

  create_table "answer_options", force: true do |t|
    t.integer  "question_id", null: false
    t.hstore   "options",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answer_options", ["question_id"], name: "index_answer_options_on_question_id", using: :btree

  create_table "answers", force: true do |t|
    t.integer  "customers_info_id"
    t.integer  "question_id"
    t.string   "provider"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "comments"
    t.text     "free_text"
    t.integer  "question_option_id"
    t.integer  "question_type_id"
    t.string   "option"
    t.integer  "date"
    t.integer  "month"
    t.integer  "year"
    t.integer  "hour"
    t.boolean  "is_business_user"
    t.boolean  "is_deactivated"
    t.boolean  "is_other",           default: false
    t.integer  "uuid"
  end

  add_index "answers", ["customers_info_id"], name: "index_answers_on_customers_info_id", using: :btree
  add_index "answers", ["question_id"], name: "answers_index", using: :btree
  add_index "answers", ["question_id"], name: "index_answers_on_question_id", using: :btree
  add_index "answers", ["question_option_id"], name: "index_answers_on_question_option_id", using: :btree
  add_index "answers", ["question_type_id"], name: "index_answers_on_question_type_id", using: :btree

  create_table "attachments", force: true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "attachable_type"
    t.integer  "attachable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments", ["attachable_id", "attachable_type"], name: "index_attachments_on_attachable_id_and_attachable_type", using: :btree
  add_index "attachments", ["attachable_id"], name: "index_attachments_on_attachable_id", using: :btree

  create_table "backlog_email_lists", force: true do |t|
    t.text     "email_array",    default: "{}"
    t.string   "bitly_url"
    t.text     "subject"
    t.text     "message"
    t.string   "sender_email"
    t.string   "question_image"
    t.string   "ref_message_id"
    t.string   "status"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email_type"
    t.string   "attach_path"
    t.string   "attach_type"
    t.string   "attach_name"
    t.boolean  "is_html"
    t.integer  "question_id"
  end

  create_table "beacons", force: true do |t|
    t.string   "name"
    t.string   "uid"
    t.boolean  "status"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "billing_info_details", force: true do |t|
    t.integer  "user_id"
    t.string   "billing_name"
    t.string   "billing_email"
    t.string   "billing_address"
    t.string   "billing_city"
    t.string   "billing_state"
    t.string   "billing_country"
    t.integer  "billing_zip",     limit: 8
    t.string   "billing_phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "billing_info_details", ["user_id"], name: "index_billing_info_details_on_user_id", using: :btree

  create_table "business_customer_infos", force: true do |t|
    t.string   "mobile"
    t.string   "customer_name"
    t.string   "email"
    t.string   "gender"
    t.integer  "age"
    t.integer  "user_id"
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.string   "area"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted"
    t.string   "custom_field"
    t.string   "status",             default: false
    t.integer  "consumer_id"
    t.boolean  "is_active_consumer"
  end

  add_index "business_customer_infos", ["consumer_id"], name: "index_business_customer_infos_on_consumer_id", using: :btree
  add_index "business_customer_infos", ["country"], name: "index_business_customer_infos_on_country", using: :btree
  add_index "business_customer_infos", ["email"], name: "index_business_customer_infos_on_email", using: :btree
  add_index "business_customer_infos", ["user_id"], name: "index_business_customer_infos_on_user_id", using: :btree

  create_table "campaign_activity_stats", force: true do |t|
    t.string   "post_id"
    t.string   "channel"
    t.integer  "campaign_id"
    t.integer  "views"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "connections"
    t.integer  "reach"
    t.integer  "share_medium_id"
  end

  create_table "campaign_channels", force: true do |t|
    t.integer  "campaign_id"
    t.integer  "share_medium_id"
    t.integer  "user_channel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "post_id"
    t.integer  "connections"
    t.integer  "reach"
  end

  add_index "campaign_channels", ["campaign_id"], name: "index_campaign_channels_on_campaign_id", using: :btree
  add_index "campaign_channels", ["share_medium_id"], name: "index_campaign_channels_on_share_medium_id", using: :btree
  add_index "campaign_channels", ["user_channel_id"], name: "index_campaign_channels_on_user_channel_id", using: :btree

  create_table "campaign_customers", force: true do |t|
    t.integer  "campaign_channel_id"
    t.integer  "campaign_id"
    t.integer  "business_customer_info_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "campaign_customers", ["business_customer_info_id"], name: "index_campaign_customers_on_business_customer_info_id", using: :btree
  add_index "campaign_customers", ["campaign_channel_id"], name: "index_campaign_customers_on_campaign_channel_id", using: :btree
  add_index "campaign_customers", ["campaign_id"], name: "index_campaign_customers_on_campaign_id", using: :btree

  create_table "campaign_customisations", force: true do |t|
    t.string   "background"
    t.string   "question_text"
    t.string   "answer_text"
    t.string   "button_text"
    t.string   "button_background"
    t.integer  "font_style_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaign_details", force: true do |t|
    t.text     "campaign_data"
    t.text     "campaign_short_urls"
    t.integer  "campaign_id"
    t.integer  "share_medium_id"
    t.integer  "template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "campaign_details", ["campaign_id"], name: "index_campaign_details_on_campaign_id", using: :btree
  add_index "campaign_details", ["share_medium_id"], name: "index_campaign_details_on_share_medium_id", using: :btree
  add_index "campaign_details", ["template_id"], name: "index_campaign_details_on_template_id", using: :btree

  create_table "campaign_types", force: true do |t|
    t.string   "campaign_type"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaigns", force: true do |t|
    t.string   "label"
    t.datetime "exp_date"
    t.string   "campaign_end_url"
    t.string   "hash_tag"
    t.string   "media_url"
    t.string   "media_thumb_url"
    t.boolean  "two_way_campaign"
    t.boolean  "is_active"
    t.boolean  "is_embed_media"
    t.datetime "schedule_on"
    t.integer  "user_id"
    t.integer  "campaign_type_id"
    t.integer  "share_medium_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.boolean  "is_archived",      default: false
    t.string   "slug"
    t.boolean  "is_power_share"
    t.text     "campaign_uuid"
    t.integer  "service_user_id"
    t.string   "time_zone"
  end

  add_index "campaigns", ["service_user_id"], name: "index_campaigns_on_service_user_id", using: :btree
  add_index "campaigns", ["slug"], name: "index_campaigns_on_slug", using: :btree

  create_table "category_types", force: true do |t|
    t.string   "category_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "channels", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "client_languages", force: true do |t|
    t.integer  "client_setting_id"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_languages", ["client_setting_id"], name: "index_client_languages_on_client_setting_id", using: :btree
  add_index "client_languages", ["language_id"], name: "index_client_languages_on_language_id", using: :btree

  create_table "client_pricing_plans", force: true do |t|
    t.integer  "client_id"
    t.string   "client_type"
    t.integer  "email_count"
    t.integer  "sms_count"
    t.integer  "customer_records_count"
    t.integer  "campaigns_count"
    t.float    "fb_boost_budget"
    t.integer  "pricing_plan_id"
    t.boolean  "is_active"
    t.datetime "start_date"
    t.datetime "exp_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_reach"
  end

  create_table "client_settings", force: true do |t|
    t.integer  "user_id",                          null: false
    t.integer  "pricing_plan_id",                  null: false
    t.integer  "tenant_count"
    t.integer  "customer_records_count"
    t.integer  "language_count"
    t.integer  "business_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "email_hourly_quota",     limit: 8
    t.integer  "questions_count"
    t.integer  "video_photo_count"
    t.integer  "sms_count"
    t.integer  "call_count"
    t.integer  "email_count"
  end

  add_index "client_settings", ["pricing_plan_id"], name: "index_client_settings_on_pricing_plan_id", using: :btree
  add_index "client_settings", ["user_id"], name: "index_client_settings_on_user_id", using: :btree

  create_table "companies", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "area"
    t.text     "description"
    t.integer  "company_type_id"
    t.integer  "industry_id"
    t.string   "website_url"
    t.string   "facebook_url"
    t.string   "twitter_url"
    t.string   "linkedin_url"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "lat"
    t.float    "lng"
    t.string   "redirect_url"
    t.integer  "piwik_id"
  end

  create_table "company_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "consumers", force: true do |t|
    t.string   "first_name",      limit: nil
    t.string   "last_name",       limit: nil
    t.string   "user_id",         limit: nil
    t.string   "auth_provider",   limit: nil
    t.string   "api_key",         limit: nil
    t.uuid     "uuid"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "device_id",       limit: nil
    t.string   "password_digest", limit: nil
    t.string   "token",           limit: nil
    t.string   "dob",             limit: nil
    t.string   "gender",          limit: nil
    t.string   "mobile",          limit: nil
    t.string   "image_url",       limit: nil
    t.boolean  "is_active",                   default: true
  end

  create_table "contact_groups", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contact_groups", ["user_id"], name: "index_contact_groups_on_user_id", using: :btree

  create_table "conversation_lists", force: true do |t|
    t.integer  "consumer_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cookie_tokens", force: true do |t|
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "counts_stores", force: true do |t|
    t.integer  "question_id",                                                                                                                                                                                                                                                                                                                                                            null: false
    t.string   "vrtype",                                                                                                                                                                                                                                                                                                                                                                 null: false
    t.integer  "norm_date",                                                                                                                                                                                                                                                                                                                                                              null: false
    t.string   "country"
    t.hstore   "counts_key",  default: {"f"=>"0", "m"=>"0", "fb"=>"0", "lk"=>"0", "qr"=>"0", "tw"=>"0", "sms"=>"0", "tkc"=>"0", "af00"=>"0", "af17"=>"0", "af25"=>"0", "af30"=>"0", "af35"=>"0", "af40"=>"0", "af45"=>"0", "af50"=>"0", "am00"=>"0", "am17"=>"0", "am25"=>"0", "am30"=>"0", "am35"=>"0", "am40"=>"0", "am45"=>"0", "am50"=>"0", "call"=>"0", "mail"=>"0", "embed"=>"0"}, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "counts_stores", ["counts_key"], name: "index_counts_stores_on_counts_key", using: :gin
  add_index "counts_stores", ["question_id"], name: "index_counts_stores_on_question_id", using: :btree

  create_table "cron_logs", force: true do |t|
    t.integer  "last_run_id"
    t.string   "log_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "currencies", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "salutation"
    t.string   "landline"
    t.string   "mobile"
    t.integer  "address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers_contact_groups", id: false, force: true do |t|
    t.integer "business_customer_info_id"
    t.integer "contact_group_id"
  end

  add_index "customers_contact_groups", ["business_customer_info_id"], name: "index_customers_contact_groups_on_business_customer_info_id", using: :btree
  add_index "customers_contact_groups", ["contact_group_id"], name: "index_customers_contact_groups_on_contact_group_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",    default: 0
    t.integer  "attempts",    default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "campaign_id"
    t.integer  "user_id"
    t.boolean  "share_now"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "delivery_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "devices", force: true do |t|
    t.string   "device_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "distribute_pricing_plans", force: true do |t|
    t.string   "plan_name",             null: false
    t.boolean  "form_builder"
    t.boolean  "offline_mode"
    t.boolean  "nrts_results"
    t.integer  "surveys_count"
    t.integer  "responses_count"
    t.boolean  "tell_the_world"
    t.boolean  "multilingual"
    t.boolean  "professional_template"
    t.boolean  "multitenant_structure"
    t.boolean  "download_reports"
    t.boolean  "sentiment_analysis"
    t.string   "media_content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_activities", force: true do |t|
    t.integer  "opens"
    t.integer  "clicks"
    t.string   "subject"
    t.string   "campaign_name"
    t.integer  "question_id"
    t.integer  "user_id"
    t.integer  "business_customer_info_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "enterprise_api_endpoints", force: true do |t|
    t.string  "subdomain"
    t.string  "login_path"
    t.string  "logout_path"
    t.string  "forgot_pw_path"
    t.string  "change_pw_path"
    t.integer "user_id"
  end

  create_table "enterprise_contacts", force: true do |t|
    t.string  "name"
    t.string  "path"
    t.integer "enterprise_api_endpoint_id"
    t.boolean "tenant_can_access"
    t.text    "params"
  end

  create_table "executive_business_mappings", force: true do |t|
    t.integer  "user_id"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "executive_business_mappings", ["company_id"], name: "index_executive_business_mappings_on_company_id", using: :btree
  add_index "executive_business_mappings", ["user_id"], name: "index_executive_business_mappings_on_user_id", using: :btree

  create_table "executive_tenant_mappings", force: true do |t|
    t.integer  "user_id"
    t.integer  "tenant_id"
    t.integer  "client_id"
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "executive_tenant_mappings", ["tenant_id"], name: "index_executive_tenant_mappings_on_tenant_id", using: :btree
  add_index "executive_tenant_mappings", ["user_id"], name: "index_executive_tenant_mappings_on_user_id", using: :btree

  create_table "ezetap_configs", force: true do |t|
    t.integer  "company_id"
    t.integer  "tenant_id"
    t.string   "account_id"
    t.string   "charge_group_id"
    t.string   "app_key"
    t.string   "app_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "features", force: true do |t|
    t.integer  "parent_id",       null: false
    t.string   "controller_name", null: false
    t.string   "action_name"
    t.string   "title",           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "font_styles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "funnel_marketing_states", force: true do |t|
    t.string   "action_name"
    t.text     "note"
    t.date     "appointment_at"
    t.string   "result"
    t.integer  "funnel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "funnel_sources", force: true do |t|
    t.string   "name"
    t.integer  "campaign_id"
    t.integer  "web_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "funnel_states", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "funnel_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "funnels", force: true do |t|
    t.integer  "item_id"
    t.integer  "quantity"
    t.boolean  "is_valid"
    t.integer  "funnel_state_id"
    t.integer  "delivery_type_id"
    t.integer  "customer_id"
    t.integer  "company_id"
    t.json     "spec_details"
    t.integer  "tracking_id"
    t.integer  "payment_mode_id"
    t.integer  "funnel_source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "funnel_type_id"
    t.string   "campaign_id"
    t.integer  "delivery_boy_id"
    t.integer  "rating"
    t.integer  "funnel_marketing_state_id"
    t.string   "lead_title"
    t.string   "funnel_channel"
  end

  create_table "industry_tags", force: true do |t|
    t.string   "industry"
    t.string   "tag"
    t.datetime "added_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "industry_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inq_campaigns", force: true do |t|
    t.string   "uuid"
    t.integer  "user_id"
    t.string   "name"
    t.string   "state"
    t.string   "hash_tag"
    t.string   "campaign_type"
    t.text     "redirect_url"
    t.text     "campaign_url"
    t.text     "preview_data"
    t.text     "override_preview"
    t.text     "cards"
    t.text     "bitly_url"
    t.datetime "valid_till"
    t.datetime "scheduled_on"
    t.datetime "added_on"
    t.integer  "inq_campaign_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invites", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "invite_code"
    t.datetime "invite_expired_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", force: true do |t|
    t.string   "name"
    t.float    "price"
    t.boolean  "is_active"
    t.integer  "specs_id"
    t.integer  "company_id"
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sku_id"
  end

  create_table "languages", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "likes", force: true do |t|
    t.integer  "consumer_id"
    t.integer  "campaign_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "linkedin_company_pages", force: true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.string   "company_logo"
    t.integer  "user_social_channel_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listeners", force: true do |t|
    t.string   "client_id"
    t.integer  "user_id"
    t.string   "email"
    t.string   "username"
    t.string   "password"
    t.string   "status"
    t.boolean  "is_active",    default: false
    t.boolean  "is_requested", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "company_name"
  end

  add_index "listeners", ["user_id"], name: "index_listeners_on_user_id", using: :btree

  create_table "payment_modes", force: true do |t|
    t.string   "provider"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", force: true do |t|
    t.integer  "role_id",      null: false
    t.boolean  "access_level", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "feature_id"
  end

  add_index "permissions", ["role_id"], name: "index_permissions_on_role_id", using: :btree

  create_table "pricing_category_types", force: true do |t|
    t.integer  "category_type_id"
    t.integer  "pricing_plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pricing_category_types", ["category_type_id"], name: "index_pricing_category_types_on_category_type_id", using: :btree
  add_index "pricing_category_types", ["pricing_plan_id"], name: "index_pricing_category_types_on_pricing_plan_id", using: :btree

  create_table "pricing_plan_channels", id: false, force: true do |t|
    t.integer "plannable_id"
    t.integer "channel_id"
    t.integer "id"
    t.string  "plannable_type"
  end

  create_table "pricing_plans", force: true do |t|
    t.string   "name",                                  null: false
    t.string   "country",                default: "IN", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sms_count"
    t.integer  "email_count"
    t.float    "amount"
    t.integer  "campaigns_count"
    t.float    "fb_boost_budget"
    t.integer  "currency_id"
    t.boolean  "is_default"
    t.integer  "customer_records_count"
    t.integer  "total_reach"
    t.boolean  "is_active"
  end

  create_table "qr_code_campaigns", force: true do |t|
    t.integer  "qr_code_id"
    t.integer  "campaign_id"
    t.string   "campaign_short_url"
    t.string   "campaign_long_url"
    t.boolean  "is_scheduled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "campaign_slug"
    t.boolean  "is_active"
  end

  add_index "qr_code_campaigns", ["campaign_slug"], name: "index_qr_code_campaigns_on_campaign_slug", using: :btree

  create_table "qr_codes", force: true do |t|
    t.string   "name"
    t.string   "short_url"
    t.boolean  "status"
    t.boolean  "is_default"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "slug"
    t.string   "url"
    t.boolean  "is_active"
  end

  add_index "qr_codes", ["slug"], name: "index_qr_codes_on_slug", using: :btree
  add_index "qr_codes", ["url"], name: "index_qr_codes_on_url", using: :btree

  create_table "question_options", force: true do |t|
    t.integer  "question_id"
    t.string   "option"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order"
    t.boolean  "is_other"
    t.boolean  "is_deactivated"
  end

  add_index "question_options", ["question_id"], name: "index_question_options_on_question_id", using: :btree

  create_table "question_response_logs", force: true do |t|
    t.integer  "question_id"
    t.string   "provider"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "cookie_token_id"
    t.boolean  "is_processed",              default: true
    t.integer  "business_customer_info_id"
  end

  add_index "question_response_logs", ["cookie_token_id"], name: "index_question_response_logs_on_cookie_token_id", using: :btree
  add_index "question_response_logs", ["question_id"], name: "index_question_response_logs_on_question_id", using: :btree
  add_index "question_response_logs", ["user_id"], name: "index_question_response_logs_on_user_id", using: :btree

  create_table "question_styles", force: true do |t|
    t.integer  "question_id"
    t.string   "background"
    t.string   "page_header"
    t.string   "submit_button"
    t.string   "question_text"
    t.string   "button_text"
    t.string   "answers"
    t.string   "font_style"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_styles", ["question_id"], name: "index_question_styles_on_question_id", using: :btree

  create_table "question_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_view_logs", force: true do |t|
    t.integer  "question_id"
    t.string   "provider"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "cookie_token_id"
    t.boolean  "is_processed",              default: true
    t.integer  "business_customer_info_id"
  end

  add_index "question_view_logs", ["cookie_token_id"], name: "index_question_view_logs_on_cookie_token_id", using: :btree
  add_index "question_view_logs", ["question_id"], name: "index_question_view_logs_on_question_id", using: :btree
  add_index "question_view_logs", ["user_id"], name: "index_question_view_logs_on_user_id", using: :btree

  create_table "questions", force: true do |t|
    t.integer  "user_id"
    t.integer  "category_type_id"
    t.string   "expiration_id"
    t.string   "question"
    t.boolean  "include_other"
    t.boolean  "include_text"
    t.boolean  "include_comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",             default: "Inactive"
    t.text     "thanks_response"
    t.datetime "expired_at"
    t.string   "qrcode_status"
    t.string   "embed_url"
    t.string   "video_url"
    t.integer  "question_type_id"
    t.integer  "video_type"
    t.string   "slug"
    t.string   "language",           default: "English"
    t.boolean  "private_access",     default: false
    t.string   "short_url"
    t.string   "twitter_short_url"
    t.string   "linkedin_short_url"
    t.string   "qrcode_short_url"
    t.string   "sms_short_url"
    t.integer  "view_count",         default: 0
    t.integer  "response_count",     default: 0
    t.string   "video_url_thumb"
    t.integer  "tenant_id"
    t.boolean  "embed_status",       default: false
  end

  add_index "questions", ["category_type_id"], name: "index_questions_on_category_type_id", using: :btree
  add_index "questions", ["expiration_id"], name: "index_questions_on_expiration_id", using: :btree
  add_index "questions", ["question_type_id"], name: "index_questions_on_question_type_id", using: :btree
  add_index "questions", ["slug"], name: "index_questions_on_slug", unique: true, using: :btree
  add_index "questions", ["tenant_id"], name: "qs_tenant_id", using: :btree
  add_index "questions", ["user_id"], name: "index_questions_on_user_id", using: :btree

  create_table "response_cookie_infos", force: true do |t|
    t.integer  "response_token_id"
    t.string   "response_token_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cookie_token_id"
  end

  add_index "response_cookie_infos", ["cookie_token_id"], name: "res_cookie_token_id", using: :btree
  add_index "response_cookie_infos", ["response_token_id"], name: "index_response_cookie_infos_on_response_token_id", using: :btree
  add_index "response_cookie_infos", ["response_token_type"], name: "res_response_token_type", using: :btree

  create_table "response_customer_infos", force: true do |t|
    t.string   "mobile"
    t.string   "customer_name"
    t.string   "email"
    t.boolean  "response_status"
    t.boolean  "view_status"
    t.string   "gender"
    t.string   "question_id"
    t.string   "provider"
    t.date     "date_of_birth"
    t.integer  "age"
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.string   "area"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cookie_token_id"
    t.integer  "user_id"
    t.boolean  "is_deleted"
  end

  add_index "response_customer_infos", ["cookie_token_id"], name: "index_response_customer_infos_on_cookie_token_id", using: :btree
  add_index "response_customer_infos", ["question_id"], name: "index_response_customer_infos_on_question_id", using: :btree
  add_index "response_customer_infos", ["user_id"], name: "index_response_customer_infos_on_user_id", using: :btree

  create_table "revisions", force: true do |t|
    t.text     "content"
    t.boolean  "is_updated"
    t.integer  "campaign_id"
    t.integer  "created_by"
    t.integer  "created_for"
    t.integer  "company_id"
    t.integer  "tenant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "revisions", ["campaign_id"], name: "index_revisions_on_campaign_id", using: :btree
  add_index "revisions", ["company_id"], name: "index_revisions_on_company_id", using: :btree
  add_index "revisions", ["created_by"], name: "index_revisions_on_created_by", using: :btree
  add_index "revisions", ["created_for"], name: "index_revisions_on_created_for", using: :btree
  add_index "revisions", ["tenant_id"], name: "index_revisions_on_tenant_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name",                              null: false
    t.boolean  "is_default",        default: false, null: false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "profile"
    t.boolean  "visible_to_tenant"
  end

  add_index "roles", ["user_id"], name: "index_roles_on_user_id", using: :btree

  create_table "s3_configs", force: true do |t|
    t.text     "identity_name"
    t.text     "identity_pool_name"
    t.string   "identity_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedule_slots", force: true do |t|
    t.string   "slot"
    t.integer  "schedule_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedule_types", force: true do |t|
    t.string   "name"
    t.boolean  "is_active"
    t.text     "schedule_days", default: "---\nMONDAY: true\nTUESDAY: true\nWEDNESDAY: true\nTHURSDAY: true\nFRIDAY: true\nSATURDAY: true\nSUNDAY: true\n"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "share_details", force: true do |t|
    t.integer  "customer_records_count", default: 0, null: false
    t.integer  "sms_count",              default: 0, null: false
    t.integer  "email_count",            default: 0, null: false
    t.integer  "user_id",                default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "campaigns_count"
    t.float    "fb_boost_budget"
    t.boolean  "is_current"
    t.integer  "client_pricing_plan_id"
    t.integer  "total_reach"
  end

  add_index "share_details", ["user_id"], name: "index_share_details_on_user_id", using: :btree

  create_table "share_mediums", force: true do |t|
    t.string   "share_type"
    t.boolean  "is_active",  default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "share_questions", force: true do |t|
    t.string   "email_address"
    t.string   "provider"
    t.text     "social_id"
    t.text     "social_token"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",             default: false
    t.string   "user_name"
    t.text     "user_profile_image"
  end

  add_index "share_questions", ["social_id"], name: "index_share_questions_on_social_id", using: :btree
  add_index "share_questions", ["user_id"], name: "index_share_questions_on_user_id", using: :btree

  create_table "share_summaries", force: true do |t|
    t.integer  "customer_records_count", default: 0, null: false
    t.integer  "sms_count",              default: 0, null: false
    t.integer  "email_count",            default: 0, null: false
    t.integer  "user_id",                default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fb_reach"
    t.integer  "campaign_id"
    t.integer  "share_detail_id"
  end

  add_index "share_summaries", ["user_id"], name: "index_share_summaries_on_user_id", using: :btree

  create_table "speakups", force: true do |t|
    t.string   "business_name", limit: nil
    t.string   "message",       limit: nil
    t.integer  "consumer_id"
    t.string   "line1",         limit: nil
    t.string   "line2",         limit: nil
    t.string   "city",          limit: nil
    t.string   "pincode",       limit: nil
    t.string   "lat",           limit: nil
    t.string   "lng",           limit: nil
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "specifications", force: true do |t|
    t.json     "attrs"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", force: true do |t|
    t.integer  "client_id"
    t.integer  "consumer_id"
    t.boolean  "is_active"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "business_type", limit: nil
  end

  create_table "tags", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "temp_biz_customers", force: true do |t|
    t.string   "mobile"
    t.string   "customer_name"
    t.string   "email"
    t.string   "gender"
    t.integer  "age"
    t.integer  "user_id"
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.string   "area"
    t.boolean  "is_deleted"
    t.string   "custom_field"
    t.string   "status",             default: "f"
    t.integer  "consumer_id"
    t.boolean  "is_active_consumer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "temp_biz_customers", ["email"], name: "index_temp_biz_customers_on_email", using: :btree
  add_index "temp_biz_customers", ["user_id"], name: "index_temp_biz_customers_on_user_id", using: :btree

  create_table "temp_business_customer_infos", force: true do |t|
    t.string   "mobile"
    t.string   "customer_name"
    t.string   "email"
    t.string   "gender"
    t.integer  "age"
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.string   "area"
    t.string   "custom_field"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tenant_regions", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "user_id"
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tenant_types", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "is_active"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tenants", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.integer  "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",         default: true
    t.string   "redirect_url"
    t.string   "from_number"
    t.float    "lat"
    t.float    "lng"
    t.string   "phone"
    t.string   "contact_number"
    t.string   "email"
    t.string   "website_url"
    t.string   "facebook_url"
    t.string   "twitter_url"
    t.string   "linkedin_url"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer  "tenant_region_id"
    t.integer  "tenant_type_id"
    t.text     "tenant_info"
  end

  create_table "transaction_details", force: true do |t|
    t.integer  "user_id"
    t.integer  "pricing_plan_id"
    t.float    "amount"
    t.string   "transaction_id"
    t.string   "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expiry_date"
    t.string   "order_id"
    t.boolean  "active",           default: false
    t.string   "action"
    t.string   "payment_status"
    t.text     "zaakpay_response"
    t.string   "response_dec"
    t.integer  "response_code"
    t.string   "tracking_id"
    t.string   "bank_ref_no"
    t.string   "failure_message"
    t.string   "payment_mode"
    t.string   "card_name"
    t.integer  "status_code"
    t.string   "status_message"
    t.string   "currency"
    t.integer  "request_plan_id"
  end

  add_index "transaction_details", ["order_id"], name: "index_transaction_details_on_order_id", using: :btree
  add_index "transaction_details", ["pricing_plan_id"], name: "index_transaction_details_on_pricing_plan_id", using: :btree
  add_index "transaction_details", ["profile_id"], name: "index_transaction_details_on_profile_id", using: :btree
  add_index "transaction_details", ["transaction_id"], name: "index_transaction_details_on_transaction_id", using: :btree
  add_index "transaction_details", ["user_id"], name: "index_transaction_details_on_user_id", using: :btree

  create_table "user_action_lists", force: true do |t|
    t.boolean  "completed"
    t.integer  "user_id"
    t.integer  "action_list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_channels", force: true do |t|
    t.text     "channel_type"
    t.integer  "channel_id"
    t.integer  "share_medium_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_channels", ["channel_id"], name: "index_user_channels_on_channel_id", using: :btree
  add_index "user_channels", ["share_medium_id"], name: "index_user_channels_on_share_medium_id", using: :btree

  create_table "user_configs", force: true do |t|
    t.text     "engage"
    t.text     "listen"
    t.text     "others"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_invites", force: true do |t|
    t.string  "email"
    t.integer "user_id"
    t.boolean "is_onboarded"
  end

  create_table "user_location_channels", force: true do |t|
    t.integer  "channel_id"
    t.string   "channel_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_location_channels", ["channel_id", "channel_type"], name: "index_user_location_channels_on_channel_id_and_channel_type", using: :btree

  create_table "user_mobile_channels", force: true do |t|
    t.string   "channel"
    t.integer  "contact_group_id"
    t.integer  "user_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_mobile_channels", ["contact_group_id"], name: "index_user_mobile_channels_on_contact_group_id", using: :btree

  create_table "user_social_channels", force: true do |t|
    t.string   "channel"
    t.text     "social_id"
    t.text     "social_token"
    t.string   "email"
    t.text     "name"
    t.text     "profile_image"
    t.integer  "user_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "connections"
    t.boolean  "valid_oauth"
    t.boolean  "is_page"
    t.integer  "admin_id"
  end

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "authentication_token"
    t.text     "uid"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                  default: false
    t.boolean  "subscribe",              default: false
    t.datetime "exp_date"
    t.boolean  "is_active"
    t.integer  "failed_attempts"
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.integer  "role_id"
    t.integer  "tenant_id"
    t.boolean  "is_csv_processed",       default: true
    t.string   "security_token"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "avatar_url"
    t.string   "mobile"
    t.integer  "currency_id"
    t.string   "invite_code"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["parent_id"], name: "index_users_on_parent_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree
  add_index "users", ["tenant_id"], name: "index_users_on_tenant_id", using: :btree

end
