class ChangeAccessLevelColumnInPermission < ActiveRecord::Migration
   def change
   change_column :permissions, :access_level, 'boolean USING CAST(access_level AS boolean)'
  end
end
