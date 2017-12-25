class CreateEnterpriseApiEndpoints < ActiveRecord::Migration
  def change
    create_table :enterprise_api_endpoints do |t|
	    t.string :subdomain
	    t.string :login_path
	    t.string :logout_path
	    t.string :forgot_pw_path
	    t.string :change_pw_path
	    t.integer :user_id
    end
  end
end
