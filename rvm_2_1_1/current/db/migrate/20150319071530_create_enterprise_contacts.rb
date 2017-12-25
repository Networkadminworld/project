class CreateEnterpriseContacts < ActiveRecord::Migration
  def change
    create_table :enterprise_contacts do |t|
	    t.string :name
	    t.string :path
	    t.integer :enterprise_api_endpoint_id
    end
  end
end
