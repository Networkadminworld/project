class ChatController < ApplicationController

  respond_to :json

  def identity
    response = {}
    session = Session.where("session_id='#{cookies["_session_id"]}'").first
    user = User.where(id: JSON.parse(Base64.decode64(session.data))["warden.user.user.key"][0].fetch(0)).first
    response = { id: user.id,userId: user.uid,email: user.email,first_name: user.first_name,last_name: user.last_name,
                 avatar_url: user.avatar_url, industry_name: user.company.nil? ? nil : user.company.industry } unless user.blank?
    render json: response.to_json
  end
end