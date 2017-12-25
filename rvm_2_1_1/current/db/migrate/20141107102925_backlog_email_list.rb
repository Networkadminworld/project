class BacklogEmailList < ActiveRecord::Migration
  def change
    create_table :backlog_email_lists do |t|
      t.string :email_array,   array: true, default: []
      t.string :bitly_url
      t.string :subject
      t.string :message
      t.string :sender_email
      t.string :question_image
      t.string :ref_message_id
      t.string :status
      t.integer :user_id
      t.timestamps
    end
  end
end
