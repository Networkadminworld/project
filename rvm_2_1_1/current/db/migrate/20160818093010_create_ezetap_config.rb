class CreateEzetapConfig < ActiveRecord::Migration
  def change
    create_table :ezetap_configs do |t|
      t.integer :company_id
      t.integer :tenant_id
      t.string  :account_id
      t.string  :charge_group_id
      t.string  :app_key
      t.string  :app_user_id
      t.timestamps
    end unless ActiveRecord::Base.connection.table_exists? 'ezetap_configs'
  end
end
