require 'RMagick'
class ConfigurationsController < ApplicationController
  before_filter :authenticate_user_web_api, except: [:show, :pricing_plan_configure]
	respond_to :json

  def show
    redirect_to QrCodeCampaign.redirect_call_to_action(params)
  end

	def social_configure
    social_info = UserSocialChannel.accounts(current_user)
    render :json => social_info
  end

  def get_campaign_styles
    campaign_styles = CampaignCustomisation.get_styles(current_user.id)
    render_json(campaign_styles)
  end

  def customise_campaign
    campaigns = CampaignCustomisation.create_style(customise_params)
    render_json(campaigns)
  end

  def get_user_actions
    render :json => UserActionList.get_action_lists(current_user)
  end

  def beacons_list
    render :json => Beacon.list(params,current_user)
  end

  def create_beacon
    render :json => Beacon.create_new(params,current_user)
  end

  def update_beacon
    render :json => Beacon.update_details(params,current_user)
  end

  def change_status
    render :json => Beacon.update_status(params,current_user)
  end

  def qr_code_list
    render :json => QrCode.list(params,current_user)
  end

  def create_qr_code
    render :json => QrCode.create_new(params,current_user)
  end

  def update_qr_code
    render :json => QrCode.update_details(params,current_user)
  end

  def download_qr_code
    encoded_url = URI.encode(params[:url])
    open("https://chart.googleapis.com/chart?cht=qr&chs=400x400&chl=#{encoded_url}", 'r') do |f|
      File.open("#{Rails.root}/tmp/QR_code.#{params[:type]}", 'wb') { |file| file.puts f.read }
      Magick::Image.read("#{Rails.root}/tmp/QR_code.#{params[:type]}").first.write("#{Rails.root}/tmp/QR_code.#{params[:type]}")
      send_file "#{Rails.root}/tmp/QR_code.#{params[:type]}", :type => "image/png"
    end
  end

  def change_qr_status
    render :json => QrCode.update_status(params,current_user)
  end

  def pricing_plan_configure
    render :json => PricingPlan.fetch_client_config(params)
  end

  private

  def customise_params
    params.require(:customise).permit(:bgcolor,:question_txt_color,:answer_txt_color,:button_txt_color,:button_bg_color,:bgimage,:font_style_id).merge(user_id: current_user.id)
  end

  def render_json(style)
    bg_image_url = style && style.attachment ? style.attachment.image.url(:large) : ''
    fonts = FontStyle.all
    render :json => { campaigns: style.to_json, bg_image_path: bg_image_url, fonts: fonts}
  end
end
