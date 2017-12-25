class AddCompanyNameToListener < ActiveRecord::Migration
  def change
    add_column :listeners, :company_name,:string
  end
end
