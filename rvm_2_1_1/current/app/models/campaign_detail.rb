class CampaignDetail < ActiveRecord::Base
  belongs_to :campaign

  serialize :campaign_data, JSON
  serialize :campaign_short_urls, JSON

  def self.power_share_details(params,campaign)
    create(campaign_data: power_content(params), campaign_id: campaign.id, campaign_short_urls: short_urls(params))
  end

  def self.power_content(params)
    {
        share_content: params[:content],
        campaign_media_url: params[:image_url],
        shorten_url: params[:shorten_url],
        media_shorten_url: params[:image_shorten_url],
        og_meta_data: params[:is_upload_image] ? {} : (params[:og_meta_data].blank? ? {} : params[:og_meta_data]),
        tw_meta_data: params[:is_upload_image] ? {} : (params[:tw_meta_data].blank? ? {} : params[:tw_meta_data]),
        sms_content: params[:sms_content],
        email_subject: params[:email_subject],
        email_content: params[:email_content],
        email_sender: params[:email_sender],
        email_cta: params[:email_cta_label],
        footer: {
            fb_feed_name: params[:fb_name],
            fb_feed_caption: params[:fb_caption],
            fb_description: params[:fb_description],
            ln_title: params[:ln_title],
        }
    }.to_json
  end

  def self.short_urls(params)
    {
        shorten_url: params[:shorten_url],
        email_shorten_url: '',
        sms_shorten_url: '',
        fb_shorten_url: '',
        tw_shorten_url: '',
        ln_shorten_url: '',
        beacon_shorten_url: '',
        qrcode_shorten_url: '',
        opinify_shorten_url: ''
    }
  end
end