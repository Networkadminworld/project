class AddIndexToTables < ActiveRecord::Migration
  def self.up
    add_index :response_cookie_infos, :cookie_token_id, :name=>'res_cookie_token_id'
    add_index :response_cookie_infos, :response_token_type, :name=>'res_response_token_type'
    add_index :questions, :tenant_id, :name=>'qs_tenant_id'
    add_index :answer_analyses, :question_id, :name=>'analyses_question_id'
    add_index :answers, :question_id, :name=>'answers_index'

  end

  def self.down
    remove_index :response_cookie_infos, 'res_cookie_token_id'
    remove_index :response_cookie_infos, 'res_response_token_type'
    remove_index :questions, 'qs_tenant_id'
    remove_index :units, 'analyses_question_id'
    remove_index :answers, 'answers_index'
  end
end