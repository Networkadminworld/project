class ChangeThanksResponseDataType < ActiveRecord::Migration
  def up
       change_column :questions, :thanks_response, :text
  end

  def down
       change_column :questions, :thanks_response, :text
  end
end
