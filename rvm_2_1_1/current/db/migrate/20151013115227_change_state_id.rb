class ChangeStateId < ActiveRecord::Migration
  def change
    rename_column :funnels,:state_id , :funnel_state_id
  end
end
