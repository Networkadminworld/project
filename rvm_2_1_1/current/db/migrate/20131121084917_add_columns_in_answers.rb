class AddColumnsInAnswers < ActiveRecord::Migration
  def up
    add_column :answers,:option,:string
    add_column :question_options,:order,:integer
    add_column :question_options,:is_other,:boolean
    add_column :answers,:date,:integer
    add_column :answers,:month,:integer
    add_column :answers,:year,:integer
    add_column :answers,:hour,:integer
    add_column :answers,:is_business_user,:boolean
    #add_column :customer_info_questions,:is_business_user,:boolean
    remove_column :answers,:answer_type_id
    add_column :answers,:is_deactivated,:boolean
    add_column :question_options,:is_deactivated,:boolean
  end

  def down
   remove_column :answers,:option
   remove_column :question_options,:order
   remove_column :question_options,:is_other
   remove_column :answers,:date
   remove_column :answers,:month
   remove_column :answers,:year
   remove_column :answers,:is_business_user
   remove_column :answers,:hour
  # remove_column :customer_info_questions,:is_business_user
   add_column :answers,:answer_type_id
   remove_column :answers,:is_deactivated
   remove_column :question_options,:is_deactivated
  end
end
