class ActionList < ActiveRecord::Base
  has_many :user_action_lists, dependent: :destroy
  has_many :users, through: :user_action_lists
end