class AddThanksResponseToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :thanks_response, :string
  end
  def self.down
      remove_column :questions, :thanks_response
  end
end
