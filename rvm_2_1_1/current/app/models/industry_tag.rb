class IndustryTag < ActiveRecord::Base

  def self.tags_list(params)
    tags = []
    if params[:user_id]
      user = User.where(id: params[:user_id]).first
      if user.company
        tag_list = user.company && user.company.try(:tags).present? ? user.company.tags.map(&:name) : []
      else
        tag_list = list_of_tags(params)
      end
    else
      tag_list =  list_of_tags(params)
    end
    tag_list.each do |tag|
      temp = {}
      temp["text"] = tag
      tags << temp
    end
    tags
  end

  def self.list_of_tags(params)
    industry = find params[:industry_id]
    where(industry: industry.industry).map(&:tag)
  end

  def self.list
    uniq_industry = []
    industry_list = []
    industries = IndustryTag.all.uniq { |item| item.industry }
    industries.each do |item|
      unless uniq_industry.include?(item.industry)
        uniq_industry << item.industry
        json = {}
        json["id"] = item.id
        json["industry"] = item.industry.try(:titleize)
        industry_list << json
      end
    end
    industry_list.sort_by { |industry| industry["industry"] }
  end

  def self.get_all(company)
    uniq_industry = []
    industry_list = []
    company_industry = where(id: company.industry_id).first.try(:industry)
    industries = IndustryTag.all.where.not(industry: company_industry).uniq { |item| item.industry }
    industries.each do |item|
      unless uniq_industry.include?(item.industry) && item.industry != company_industry
        uniq_industry << item.industry
        industry_list << [item.id,item.industry.try(:titleize)]
      end
    end
    industry_list << [company.industry_id,company_industry.try(:titleize)]
    industry_list.sort_by { |industry| industry.last }
  end
end