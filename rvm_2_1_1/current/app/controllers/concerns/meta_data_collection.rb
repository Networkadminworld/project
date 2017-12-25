require 'addressable/uri'
require 'open-uri'
require 'nokogiri'
module MetaDataCollection
	extend ActiveSupport::Concern
	included do
    def fetch url
      begin
        doc = Nokogiri::HTML(open("#{url}"))
        twitter = {}
        open_graph = {}
        doc.xpath("//meta").each do |meta|
          p_value = ''
          if meta.attributes["property"]
            p_value = meta.attributes["property"].value
          elsif meta.attributes["name"]
            p_value = meta.attributes["name"].value
          end
          if meta.attributes["content"]
            if p_value == "twitter:card"
              twitter["card"] = meta.attributes["content"].value || ''
            elsif p_value == "twitter:site"
              twitter["site"] = meta.attributes["content"].value || ''
            elsif p_value == "twitter:title"
              twitter["title"] = meta.attributes["content"].value || ''
            elsif p_value == "twitter:description"
              twitter["description"] = meta.attributes["content"].value || ''
            elsif p_value == "twitter:image" || p_value == "twitter:image:src"
              twitter["image"] = meta.attributes["content"].value || ''
            elsif p_value == "og:image"
              open_graph["image"] = meta.attributes["content"].value || ''
            elsif p_value == "og:type"
              open_graph["type"] = meta.attributes["content"].value || ''
            elsif p_value == "og:site_name"
              open_graph["site_name"] = meta.attributes["content"].value || ''
            elsif p_value == "og:url"
              open_graph["url"] = meta.attributes["content"].value || ''
            elsif p_value == "og:description"
              open_graph["description"] = meta.attributes["content"].value || ''
            elsif p_value == "og:title"
              open_graph["title"] = meta.attributes["content"].value || ''
            end
          end

          p meta.attributes

          if open_graph["title"].blank?
            title_node = doc.at_xpath("//head//title")
            if title_node
              open_graph["title"] = title_node.text
            elsif doc.title
              open_graph["title"] = doc.title
            else
              open_graph["title"] = url
            end
            twitter["title"] = open_graph["title"]
          end

          if open_graph["description"].blank?
            content = doc.css("p")
            long_paragraph = []
            short_paragraph = []
            small_paragraph = []
            content.each do  |value|
              long_paragraph << value.text if value.text.strip.length > 60
              short_paragraph << value.text if value.text.strip.length > 20 && value.text.strip.length < 60
              small_paragraph << value.text if value.text.strip.length > 0 && value.text.strip.length < 20
            end
            if long_paragraph.count > 0
              open_graph["description"] = long_paragraph[0].strip
            elsif long_paragraph.count == 0 && short_paragraph.count > 0
              open_graph["description"] = short_paragraph[0].strip
            elsif long_paragraph.count == 0 && short_paragraph.count == 0 && small_paragraph.count > 0
              open_graph["description"] = small_paragraph[0].strip
            else
              open_graph["description"] = url
            end
            twitter["description"] = open_graph["description"]
          end

          if open_graph["image"].blank?
            img = doc.css("img")
            images = []
            img.each do |value|
              images << value.attributes["src"].value
            end
            open_graph["image"] = images[Random.new.rand(0..5)]
            twitter["image"] = open_graph["image"]
          end

          open_graph["url"] = url if open_graph["url"].blank?

          open_graph["domain"] = Addressable::URI.parse("#{url}").host.upcase
        end
      rescue => e
        puts e
      end
      [twitter,open_graph]
    end

    def default_search_tags
      tags = []
      user_company_tags.each do |tag|
        temp = {}
        temp["text"] = tag.name
        tags << temp
      end
      tags.reject! { |tag| tag.empty? }
      tags
    end

    def user_company_tags
      if current_user.client
        current_user.client.company && current_user.client.company.tags ? current_user.client.company.tags : []
      else
        current_user.company && current_user.company.tags ? current_user.company.tags : []
      end
    end
	end
end