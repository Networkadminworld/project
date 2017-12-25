class AddBusinessCustomerInfoIdToQuestionViewLog < ActiveRecord::Migration
  def change
    add_column :question_view_logs, :business_customer_info_id, :integer
    add_column :question_response_logs, :business_customer_info_id, :integer
  end
end
