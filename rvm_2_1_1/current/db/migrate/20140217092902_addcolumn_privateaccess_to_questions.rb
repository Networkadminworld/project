class AddcolumnPrivateaccessToQuestions < ActiveRecord::Migration
  def up
    add_column :questions, :private_access, :boolean, :default => false
  end

  def down
    remove_column :questions, :private_access
  end
end
