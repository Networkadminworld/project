class Invite < ActiveRecord::Base

  def self.send_invite(params)
    already_invited = where(email: strip_email(params[:email]))
    already_signed_up = User.where(email: strip_email(params[:email]))
    if already_invited.blank? && already_signed_up.blank?
      invite_user = Invite.create(name: params[:name], email: strip_email(params[:email]))
      InviteUser.on_board_invite(invite_user).deliver
      message = { status: 200 }
    elsif already_invited.blank? && !already_signed_up.blank?
      message = { status: 402, response_msg: "This email is already registered. Please use the login link on the top or contact help@inquirly.com for any troubleshooting." }
    else
      message = { status: 402, response_msg: "Hang on hang on! This email is already in queue. If you don't hear from us in 48 hours, please contact help@inquirly.com." }
    end
    message
  end


  def self.strip_email(email)
    email.strip.downcase
  end
end