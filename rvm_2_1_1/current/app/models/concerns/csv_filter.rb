module CsvFilter
  extend ActiveSupport::Concern
  included do
	  
    def self.filter_condition(filter,logic)
      @condition = ""
      filter.each do |k,val|
        if val['logic'].present?
          val['filters'].each do |s_k,s_v|
            s_v['value'] = s_v['value'].downcase if s_v['field'] == 'gender'
            s_v['value'] = get_country_info(s_v['value']) if s_v['field'] == 'country'
            @condition += " #{val['logic']}"
            @condition += " #{s_v['field']} #{find_operator(s_v['operator'], s_v['value'])}"
          end
        else
          val['value'] = val['value'].downcase if val['field'] == 'gender'
          val['value'] = get_country_info(val['value']) if val['field'] == 'country'
          @condition += " #{logic}"
          @condition += " #{val['field']} #{find_operator(val['operator'], val['value'])}"
        end
      end
      @condition
    end

    def self.get_country_info(value)
      Country.find_country_by_name(value).nil? ? value : Country.find_country_by_name(value).alpha2
    end

    def self.find_operator(operator, value)
      case operator
        when 'neq'
          "!= ('#{value}')"
        when 'lt'
          "< ('#{value}')"
        when 'lte'
          "<= ('#{value}')"
        when 'gt'
          "> ('#{value}')"
        when 'gte'
          ">= ('#{value}')"
        when 'startswith'
          "ILIKE ('#{value}%')"
        when 'endswith'
          "ILIKE ('%#{value}')"
        when 'contains'
          "ILIKE ('%#{value}%')"
        when 'doesnotcontain'
          "NOT ILIKE ('%#{value}%')"
        else
          "= ('#{value}')"
      end
    end
  end
end