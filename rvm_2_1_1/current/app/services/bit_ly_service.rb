require 'rest_client'

class BitLyService

  def initialize(end_point=ENV['SHORTEN_ENDPOINT'], secret=ENV['SHORTEN_SECRET'])
    @end_point = end_point
    @secret = secret
  end

  def create_shorten_url(channel,campaign)
    long_url = campaign.long_url
    short_url = long_url.include?("?") ? long_url+"&channel=#{channel}" : long_url+"?channel=#{channel}"
    case channel
      when 'email'
        update_short_urls(campaign,'email_shorten_url',shorten({url: short_url, secret: @secret})["short_url"])
      when 'sms'
        update_short_urls(campaign,'sms_shorten_url',shorten({url: short_url, secret: @secret})["short_url"])
      when 'facebook'
        update_short_urls(campaign,'fb_shorten_url',shorten({url: short_url, secret: @secret})["short_url"])
      when 'twitter'
        update_short_urls(campaign,'tw_shorten_url',shorten({url: short_url, secret: @secret})["short_url"])
      when 'linkedin'
        update_short_urls(campaign,'ln_shorten_url',shorten({url: short_url, secret: @secret})["short_url"])
      when 'QrCode'
        update_short_urls(campaign,'qrcode_shorten_url',shorten({url: short_url, secret: @secret})["short_url"])
      when 'Beacon'
        update_short_urls(campaign,'beacon_shorten_url',shorten({url: short_url, secret: @secret})["short_url"])
      when 'opinify'
        update_short_urls(campaign,'opinify_shorten_url', shorten({url: short_url, secret: @secret})["short_url"])
      else
        ''
    end
  end

  def update_short_urls(campaign,type,url)
    detail = CampaignDetail.where(campaign_id: campaign.id).first
    detail.campaign_short_urls[type] = url
    detail.save
  end

  def shorten(data)
    JSON.parse(RestClient.post @end_point, data.to_json, :content_type => 'application/json')
  end
end