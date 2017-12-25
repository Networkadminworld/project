class AddFunnelChannelToFunnels < ActiveRecord::Migration
  def change
    add_column :funnels, :funnel_channel, :string
  end
end
