class AddIsHtmlInAlertConfig < ActiveRecord::Migration
  def change
    add_column :alert_configs, :is_html, :boolean, :default => false
  end
end
