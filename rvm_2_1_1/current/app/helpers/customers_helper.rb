module CustomersHelper

  def email_campaign_template(user,data,campaign_type)
    start_html = "<!DOCTYPE html><html><head></head><body style='overflow:auto; background-color:#FFFFFF; padding:40px; font-size:14px; color:#000000;'>"
    end_html = "</body></html>"
    start_html + body_content(user,data,campaign_type) + end_html
  end

  def body_content(user,data,campaign_type)
    body_init = "<div style='padding:20px; background-color:#FFFFFF;'>"
    company_info_start = "<div style='border-top:1px solid #AFAFAF; border-left:1px solid #AFAFAF; border-right:1px solid #AFAFAF;padding-top:15px; padding-left:15px'>"
    share_content = "<div style='color:#000000; padding-top: 20px; padding-bottom:15px;'>#{data["share_content"]}</div>"
    company_info_end = "</div>"
    meta_block = data["og_meta_data"]["title"] && data["og_meta_data"]["description"] ? "<div style='border-left:1px solid #AFAFAF; border-bottom:1px solid #AFAFAF; border-right:1px solid #AFAFAF;padding:15px;'>
      <div style='font-size:24px; font-weight:bold; color:#000000;text-align:center;'>#{data["og_meta_data"]["title"]}</div>" + description_block(data,campaign_type) +
      "</div>" : ""
    body_end = "</div>"
    footer = user.company.nil? ? "" : "<div style='text-align:center; padding:10px; margin-top:5px; background-color:#FFFFFF;'>
    <span style='display:inline-block;'>
    <a href='#{user.company.try(:facebook_url)}'><img src='http://i.imgur.com/jf45KXq.png' style='width:40px;height:40px;'></a>
    </span>
    <span style='display:inline-block;'>
    <a href='#{user.company.try(:twitter_url)}'><img src='http://i.imgur.com/bKJiu1b.png' style='width:40px;height:40px;'></a>
    </span>
    <span class='display:inline-block;'>
    <a href='#{user.company.try(:linkedin_url)}'><img src='http://i.imgur.com/g9NdlDE.png' style='width:40px;height:40px;'></a>
    </span>
    </div>"
    body_init + company_info_start + share_content + company_info_end + image_block(data) + meta_block + body_end + footer
  end

  def description_block(data,campaign_type)
    if campaign_type == "Powershare"
      "<div style='margin-top:10px; text-align:justify; color:#000000;'>#{data["og_meta_data"]["description"]}
         <a href='#{data["shorten_url"]}'>READ COMPLETE ARTICLE</a>
       </div>"
    else
      "<div style='margin-top:10px; margin-bottom:10px; text-align:justify; color:#000000;'>#{data["og_meta_data"]["description"]}</div>
       <div style='margin-top:40px;margin-bottom:10px;text-align:center;'><a href='#{data["email_shorten_url"] || data["shorten_url"]}' style=' background: #699637; border-radius: 5px; color: #FFFFFF;  padding: 12px 30px;
      margin: 12px 30px; text-decoration: none;  font-size: 20px;display: inline-block;max-width: 186px;display: inline-block;overflow-wrap: break-word;'>#{ data["email_cta"].present? ? data["email_cta"] : 'View'}</a>
      </div>"
    end
  end

  def image_block(data)
    image_tag  = ""
    if data["og_meta_data"]["image"].blank? &&  data["campaign_media_url"].blank?
      image_tag += ""
    elsif data["og_meta_data"]["image"].blank? && !data["campaign_media_url"].blank?
      image_tag += "<div style='line-height:1px; border-left:1px solid #AFAFAF; border-right:1px solid #AFAFAF;'><img src='#{data['campaign_media_url']}' style='width:100%;'></div>"
    elsif !data["og_meta_data"]["image"].blank? && data["campaign_media_url"].blank?
      image_tag += "<div style='line-height:1px; border-left:1px solid #AFAFAF; border-right:1px solid #AFAFAF;'><img src='#{data["og_meta_data"]["image"]}' style='width:100%;'></div>"
    end
    image_tag
  end
end
