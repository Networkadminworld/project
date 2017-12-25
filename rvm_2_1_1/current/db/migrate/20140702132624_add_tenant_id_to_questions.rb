class AddTenantIdToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :tenant_id, :integer
  end
  def self.down
    add_column :questions, :tenant_id
  end
end
