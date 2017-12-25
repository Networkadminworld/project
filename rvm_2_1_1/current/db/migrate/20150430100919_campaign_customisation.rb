class CampaignCustomisation < ActiveRecord::Migration
  def change
    create_table :campaign_customisations do |t|
      t.string  :background
      t.string  :question_text
      t.string  :answer_text
      t.string  :button_text
      t.string  :button_background
      t.integer :font_style_id
      t.integer :user_id
      t.timestamps
    end
  end
end
