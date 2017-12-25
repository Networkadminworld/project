json.array!(@admin_action_lists) do |admin_action_list|
  json.extract! admin_action_list, :id
  json.url admin_action_list_url(admin_action_list, format: :json)
end
