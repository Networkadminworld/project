class AddIndexToQuestionLogs < ActiveRecord::Migration
  def change
    add_index :answer_analyses, :answer_id
    add_index :answer_options, :question_id
    add_index(:attachments, [:attachable_id, :attachable_type])
    add_index :billing_info_details, :user_id
    add_index :business_customer_infos, :cookie_token_id
    add_index :client_languages, :client_setting_id
    add_index :client_languages, :language_id
    add_index :client_settings, :pricing_plan_id
    add_index :client_settings, :user_id
    add_index :counts_stores, :question_id
    add_index :executive_tenant_mappings, :user_id
    add_index :executive_tenant_mappings, :tenant_id
    add_index :permissions, :role_id
    add_index :pricing_category_types, :category_type_id
    add_index :pricing_category_types, :pricing_plan_id
    add_index :question_response_logs, :question_id
    add_index :question_response_logs, :user_id
    add_index :question_response_logs, :cookie_token_id
    add_index :question_view_logs, :question_id
    add_index :question_view_logs, :user_id
    add_index :response_customer_infos, :cookie_token_id
    add_index :response_customer_infos, :user_id
    add_index :roles, :user_id
    add_index :share_details, :user_id
    add_index :share_summaries, :user_id
    add_index :users, :role_id
    add_index :users, :tenant_id
  end
end