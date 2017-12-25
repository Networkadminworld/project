class CreateFunnelStates < ActiveRecord::Migration
  def change
    create_table :funnel_states do |t|
      t.string :name

      t.timestamps
    end
  end
end
