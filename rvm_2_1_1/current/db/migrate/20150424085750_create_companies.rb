class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string  :name
      t.string  :logo_url
      t.string  :address
      t.string  :area
      t.text    :description
      t.integer :company_type_id
      t.integer :industry_id
      t.string  :tags
      t.string  :website_url
      t.string  :facebook_url
      t.string  :twitter_url
      t.string  :linkedin_url
      t.integer :user_id
      t.timestamps
    end
  end
end
