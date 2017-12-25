class AddIndexForeignKey < ActiveRecord::Migration
  def up
    add_index :response_cookie_infos, :response_token_id
    add_index :answers, :question_option_id
    add_index :answers, :question_type_id
    add_index :answers, :multiple_response_id
    add_index :questions, :question_type_id
    add_index :response_customer_infos, :question_id
    add_index :question_options, :question_id
    add_index :business_customer_infos, :question_id
    add_index :business_customer_infos, :user_id
  end

  def down
    remove_index :response_cookie_infos, :response_token_id
    remove_index :answers, :question_option_id
    remove_index :answers, :question_type_id
    remove_index :answers, :multiple_response_id
    remove_index :questions, :question_type_id
    remove_index :response_customer_infos, :question_id
    remove_index :question_options, :question_id
    remove_index :business_customer_infos, :question_id
    remove_index :business_customer_infos, :user_id
  end
end
