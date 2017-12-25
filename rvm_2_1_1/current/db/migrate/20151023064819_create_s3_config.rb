class CreateS3Config < ActiveRecord::Migration
  def change
    create_table :s3_configs do |t|
      t.text :identity_name
      t.text :identity_pool_name
      t.string :identity_type
      t.timestamps
    end
  end
end
