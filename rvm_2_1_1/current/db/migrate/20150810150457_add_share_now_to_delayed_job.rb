class AddShareNowToDelayedJob < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :share_now, :boolean
  end
end
