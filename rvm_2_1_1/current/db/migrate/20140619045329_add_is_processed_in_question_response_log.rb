class AddIsProcessedInQuestionResponseLog < ActiveRecord::Migration
def up
  add_column :question_response_logs,:is_processed,:boolean,default: true
end

def down
  remove_column :question_response_logs,:is_processed
end
end
