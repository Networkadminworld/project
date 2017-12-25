class AddAccessLevelToEnterpriseContacts < ActiveRecord::Migration
  def change
    add_column :enterprise_contacts, :tenant_can_access, :boolean
    add_column :enterprise_contacts, :params, :text
  end
end
