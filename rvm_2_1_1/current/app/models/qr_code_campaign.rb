class QrCodeCampaign < ActiveRecord::Base
  belongs_to :qr_code
  belongs_to :campaign

  def self.redirect_call_to_action(params)
    qr_code = QrCode.friendly.where(slug: params[:id]).last
    qr_code_campaign = where(qr_code_id: qr_code.id).last
    if qr_code_campaign && qr_code_campaign.is_active && qr_code.status
      qr_code_campaign.campaign_long_url ? qr_code_campaign.campaign_long_url : "#{ENV['CUSTOM_URL']}power_share/#{qr_code_campaign.campaign_slug}"
    elsif qr_code.url && qr_code.is_active && qr_code.status
      qr_code.url
    else
      "http://app.ezeees.com"
    end
  end

  def self.create_qr_campaigns(qr_code_ids,campaign)
    (0..qr_code_ids.length - 1).each do |i|
      qr_campaign = create(qr_code_id: qr_code_ids[i], campaign_id: campaign.id, is_scheduled: campaign.campaign_status,
             campaign_short_url: campaign.short_url,campaign_long_url: campaign.long_url, campaign_slug: campaign.slug, is_active: true)
      QrCode.where(id: qr_code_ids[i]).first.update(url: qr_campaign.campaign_long_url)
    end
  end
end
