class AddIsOtherInAnswers < ActiveRecord::Migration
  def up
    add_column :answers,:is_other,:boolean,:default=>false
    remove_column :answers,:other_options_text
  end

  def down
    remove_column :answers,:is_other
    add_column :answers,:other_options_text,:string
  end
end
