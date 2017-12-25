class CreateCustomersContactGroups < ActiveRecord::Migration
  def change
    remove_column :business_customer_infos, :contact_group_id

    create_table :customers_contact_groups, id: false do |t|
      t.belongs_to :business_customer_info, index: true
      t.belongs_to :contact_group, index: true
    end
  end
end
