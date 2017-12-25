class CreateClientLanguages < ActiveRecord::Migration
  def change
    create_table :client_languages do |t|
      t.integer :client_setting_id
      t.integer :language_id
      t.timestamps
    end
  end
end
