class CampaignCustomisation < ActiveRecord::Base

  has_one :attachment, :as => :attachable, :dependent => :destroy

	def self.get_styles(user_id)
		where(user_id: user_id).first
  end

  def self.create_style(params)
    user_campaign_style = where(user_id: params[:user_id]).first
   if user_campaign_style
     user_campaign_style.update_attributes(background: params[:bgcolor],question_text: params[:question_txt_color],answer_text: params[:answer_txt_color],button_text: params[:button_txt_color], button_background: params[:button_bg_color],font_style_id: params[:font_style_id], user_id: params[:user_id])
     create_bg_attachment(params,user_campaign_style)  if params[:bgimage]
   else
     user_campaign_style = create(background: params[:bgcolor],question_text: params[:question_txt_color],answer_text: params[:answer_txt_color],button_text: params[:button_txt_color], button_background: params[:button_bg_color],font_style_id: params[:font_style_id],user_id: params[:user_id])
     create_bg_attachment(params,user_campaign_style) if params[:bgimage]
   end
    user_campaign_style
  end

  def self.create_bg_attachment(params,user_campaign_style)
    user_campaign_style.attachment.destroy if user_campaign_style.attachment.present?
    Attachment.create_attachment(user_campaign_style.id, params[:bgimage],"CampaignCustomisation")
  end
end
