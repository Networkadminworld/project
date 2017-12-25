class Attachment < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true
  has_attached_file :image, :styles => {:thumb => "116x97",:square => "320 x270"},
                    :content_type => ["image/jpg", "image/jpeg", "image/gif", "image/png", "image/pjpeg", "image/x-png"],
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/s3.yml",
                    :path => "/assets/questions/:id/:style/:basename.:extension"
  do_not_validate_attachment_file_type :image

  def self.create_file_attachment(params,question)
    Attachment.create(:image => params[:question][:image], :attachable_id => question.id,:attachable_type => "Question") if params[:question] && params[:question][:image].present?
  end

  def self.attach_user_profile(user,image)
    u_res = user.present?
    user.attachment.destroy if u_res && user.attachment.present?
    user.create_attachment(:image => open("#{image}")) if u_res
  end

  def self.create_attachment(attachment_id,image,type)
    Attachment.create(:image => image, :attachable_id => attachment_id,:attachable_type => type)
  end
end
