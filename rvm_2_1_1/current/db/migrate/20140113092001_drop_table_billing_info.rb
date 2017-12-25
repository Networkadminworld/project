class DropTableBillingInfo < ActiveRecord::Migration
  def up
    drop_table :billing_infos
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
