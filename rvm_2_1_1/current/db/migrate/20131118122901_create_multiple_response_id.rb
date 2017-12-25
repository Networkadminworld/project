class CreateMultipleResponseId < ActiveRecord::Migration
  def up
    add_column :answers,:multiple_response_id,:integer
    add_column :answers,:other_options_text,:text
  end

  def down
   remove_column :answers,:multiple_response_id
   remove_column :answers,:other_options_text
  end
end
