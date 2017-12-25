class AddIndexToFkey < ActiveRecord::Migration
  def self.up
    add_index :transaction_details, :user_id
    add_index :transaction_details, :bussiness_type_id
    add_index :transaction_details, :transaction_id
    add_index :transaction_details, :profile_id
    add_index :transaction_details, :order_id
    add_index :attachments, :attachable_id
    add_index :question_styles, :question_id
    add_index :answers, :customers_info_id
    add_index :answers, :question_id
    add_index :answers, :answer_type_id
    add_index :billing_infos, :user_id
    add_index :share_questions, :social_id
    add_index :share_questions, :user_id
    add_index :questions, :user_id
    add_index :questions, :category_type_id
    add_index :questions, :expiration_id
    add_index :questions, :answer_type_id
    add_index :users, :business_type_id
    add_index :users, :parent_id
    #add_index :question_view_counts, :question_id
    #add_index :customers_infos, :user_id
    #add_index :customers_infos, :question_id
    #add_index :customer_info_questions, :customers_info_id
  end

  def self.down
    remove_index :transaction_details, :user_id
    remove_index :transaction_details, :bussiness_type_id
    remove_index :transaction_details, :transaction_id
    remove_index :transaction_details, :profile_id
    remove_index :transaction_details, :order_id
    remove_index :attachments, :attachable_id
    remove_index :question_styles, :question_id
    remove_index :answers, :customers_info_id
    remove_index :answers, :question_id
    remove_index :answers, :answer_type_id
    remove_index :billing_infos, :user_id
    remove_index :share_questions, :social_id
    remove_index :share_questions, :user_id
    remove_index :questions, :user_id
    remove_index :questions, :category_type_id
    remove_index :questions, :expiration_id
    remove_index :questions, :answer_type_id
    remove_index :users, :business_type_id
    remove_index :users, :parent_id
    #remove_index :question_view_counts, :question_id
    #remove_index :customers_infos, :user_id
    #remove_index :customers_infos, :question_id
    #remove_index :customer_info_questions, :customers_info_id
  end
end