class AddViewAndResponseCountColumns < ActiveRecord::Migration
 def up
   add_column :questions ,:view_count,:integer,default: 0
   add_column :questions ,:response_count,:integer,default: 0
 end
 def down
   remove_column :questions ,:view_count
   remove_column :questions ,:response_count
 end
end
