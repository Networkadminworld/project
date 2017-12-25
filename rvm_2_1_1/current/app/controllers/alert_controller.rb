class AlertController < WebsocketRails::BaseController

  def client_connected
    WebsocketRails.users[params[:user_id]] = connection
  end
end