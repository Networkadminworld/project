class AddCsvProcessedToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_csv_processed, :boolean, default: true
    rename_column :business_customer_infos, :is_unsubscribed, :status
  end
end
