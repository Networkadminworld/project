class AddAttachmentVideoToQuestions < ActiveRecord::Migration
  def self.up
    change_table :questions do |t|
      t.attachment :video
    end
  end

  def self.down
    drop_attached_file :questions, :video
  end
end
