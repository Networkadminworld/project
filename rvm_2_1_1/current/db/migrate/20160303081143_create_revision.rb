class CreateRevision < ActiveRecord::Migration
  def change
    create_table :revisions do |t|
      t.text :content
      t.boolean :is_updated
      t.integer :campaign_id
      t.integer :created_by
      t.integer :created_for
      t.integer :company_id
      t.integer :tenant_id
      t.timestamps
    end

    add_index :revisions, :created_by
    add_index :revisions, :created_for
    add_index :revisions, :campaign_id
    add_index :revisions, :company_id
    add_index :revisions, :tenant_id

    add_column :campaigns, :service_user_id, :integer
    add_index :campaigns, :service_user_id
  end
end
