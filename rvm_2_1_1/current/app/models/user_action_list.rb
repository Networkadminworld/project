class UserActionList < ActiveRecord::Base
  belongs_to :user
  belongs_to :action_list

  def self.get_action_lists(user)
    lists = []
    unless user.nil?
      action_lists = ActionList.where(id: user.user_action_lists.map(&:action_list_id))
      action_lists.each do |action_list|
        json = {}
        json["action"] = action_list.action
        json["weight"] = action_list.weight
        json["url"] = action_list.url
        json["completed"] = is_completed?(action_list.id,user)
        lists << json
      end
    end
    lists
  end

  def self.is_completed? act_id, user
    where(user_id: user.id, action_list_id: act_id).first.try(:completed)
  end

  def self.update_status(user,action,state)
    unless user.nil?
      action = ActionList.where(action: action).first
      user_action = where(user_id: user.id, action_list_id: action.try(:id)).first
      user_action.update(completed: state) if user_action
    end
  end
end