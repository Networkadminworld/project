class CreateLinkedinCompanyPage < ActiveRecord::Migration
  def change
    create_table :linkedin_company_pages do |t|
      t.integer :company_id
      t.string  :name
      t.string  :company_logo
      t.integer :user_social_channel_id
      t.integer :user_id
      t.timestamps
    end unless ActiveRecord::Base.connection.table_exists? 'linkedin_company_pages'
  end
end
