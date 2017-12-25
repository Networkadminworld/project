require 'csv'
require 'fileutils'
require 'erb'
module CampaignProcess
  include ERB::Util
  extend ActiveSupport::Concern
  included do

    def self.email_campaign_process(params,user,filter,logic,sort,question)
      to_addresses = []
      biz_customer_ids = []
      question_image = question.attachment.image(:thumb) if question.present? && question.attachment.present?
      get_query_info(filter,logic,sort,user,params[:unchecked_cus_ids],"email",params[:customer_ids])
      file_name = "/tmp/email_camp_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
      sanitized_sql = "(SELECT id,email FROM business_customer_infos where #{@email_condition}) TO '#{file_name}' WITH CSV HEADER"
      copy_to_remote_server(sanitized_sql)
      if File.exists?(file_name)
        CSV.foreach(file_name, :headers => true, :header_converters => :symbol, :skip_blanks => true, :encoding => 'ISO-8859-1', :converters => :all) do |row|
          hash_val = Hash[row.headers[0..-1].zip(row.fields[0..-1])]
          biz_customer_ids  << hash_val[:id]
          to_addresses << hash_val[:email]
        end
        email_array = Question.get_email_list(user,biz_customer_ids,to_addresses,question)
        ShareDetail.update_share_count(user,email_array.count,'email_count')
        Delayed::Job.enqueue(MailerJob.new(email_array,params[:subject],params[:message],question_image,user,question.id, params[:is_html]), 2)
      else
        InviteUser.delay.csv_copy_error_mail(user,"email")
      end
    end

    def self.sms_campaign_process(params,user,filter,logic,sort)
      indian_numbers,intern_numbers = [],[]
      get_query_info(filter,logic,sort,user,params[:unchecked_cus_ids],"mobile",params[:customer_ids])
      ind_file_name = "/tmp/local_sms_camp_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
      sanitized_sql = "(SELECT mobile FROM business_customer_infos where (#{@local_sms})) TO '#{ind_file_name}' WITH CSV HEADER"
      copy_to_remote_server(sanitized_sql)
      if File.exists?(ind_file_name)
        ind_file,indian_numbers = fetch_mobile_numbers(ind_file_name)
          Delayed::Job.enqueue(SmsIndia.new(ind_file, ERB::Util.url_encode(params[:message])), 1)
      else
        InviteUser.delay.csv_copy_error_mail(user, "sms")
      end
      inter_file_name = "/tmp/inter_sms_camp_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
      sanitized_sql = "(SELECT mobile FROM business_customer_infos where (#{@inter_sms})) TO '#{inter_file_name}' WITH CSV HEADER"
      copy_to_remote_server(sanitized_sql)
      if File.exists?(inter_file_name)
        file,intern_numbers = fetch_mobile_numbers(inter_file_name)
        intern_numbers.each do |number|
          Delayed::Job.enqueue(SmsJob.new(number, params[:message]), 1)
        end
      else
        InviteUser.delay.csv_copy_error_mail(user,"sms")
      end
      number_count = indian_numbers.uniq.count + intern_numbers.uniq.count
      ShareDetail.update_share_count(user,number_count,'sms_count') if number_count > 0
    end

    def self.voice_campaign_process(params,question,user,content,filter,logic,sort)
      get_query_info(filter,logic,sort,user,params[:unchecked_cus_ids],"mobile",params[:customer_ids],true)
      voice_file_name = "/tmp/voice_camp_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
      sanitized_sql = "(SELECT mobile FROM business_customer_infos where (#{@call_condition})) TO '#{voice_file_name}' WITH CSV HEADER"
      copy_to_remote_server(sanitized_sql)
      if File.exists?(voice_file_name)
        file,phone_numbers = fetch_mobile_numbers(voice_file_name)
        uniq_numbers = phone_numbers.uniq
        ShareDetail.update_share_count(user,uniq_numbers.count,'call_count')
        Delayed::Job.enqueue(VoiceJob.new(uniq_numbers, question.id,content,"false"), 0)
      else
        InviteUser.delay.csv_copy_error_mail(user,"call")
      end
    end

    def self.fetch_mobile_numbers(file)
      numbers = []
      CSV.foreach(file, :headers => true, :header_converters => :symbol, :skip_blanks => true, :encoding => 'ISO-8859-1', :converters => :all) do |row|
        hash_val = Hash[row.headers[0..-1].zip(row.fields[0..-1])]
        numbers << hash_val[:mobile]
      end
      change_header_value(file,numbers.uniq)
    end

    def self.change_header_value(file,numbers)
      CSV.open(file, "wb") do |csv|
        csv << ["PHONE"]
        numbers.each do |number|
          csv << [number]
        end
      end
      return file, numbers
    end

    def self.get_query_info(filter,logic,sort,user,unchecked_ids,type,selected_ids,is_call=nil)
      unchecked = unchecked_ids.present? ? unchecked_ids.split(",").uniq : []
      selected = selected_ids.present? ? selected_ids.split(",").uniq : []
      if type == "email"
        @condition = "user_id = #{user.id} and is_deleted is NULL and #{type} != '' and (status = '' or status = 'false' or status = 'f' or status is NULL) "
      else
        @condition = "user_id = #{user.id} and is_deleted is NULL and #{type} != ''"
      end
      unless filter.nil?
        filter.each do |k,val|
          if val['logic'].present?
            val['filters'].each do |s_k,s_v|
              @condition += " #{val['logic']}"
              @condition += " #{s_v['field']} #{find_operator(s_v['operator'], s_v['value'])}"
            end
          else
            @condition += " #{logic}"
            @condition += " #{val['field']} #{find_operator(val['operator'], val['value'])}"
          end
        end
      end
      unselected_ids = !unchecked.blank? ? " and id NOT IN (#{unchecked.join(',')})" : ""
      selected_ids = !selected.blank? ? " and id IN (#{selected.join(',')})" : ""
      sort_by = !sort.nil? ? " ORDER BY #{sort['column']} #{sort['by']}" : ""
      if is_call
        @call_condition = @condition + unselected_ids + selected_ids + sort_by
      else
        if type == "mobile"
          @local_sms = @condition + " and mobile LIKE '91%'" + unselected_ids + selected_ids + sort_by
          @inter_sms = @condition + " and mobile NOT LIKE '91%'" + unselected_ids + selected_ids + sort_by
        elsif type == "email"
          @email_condition = @condition + unselected_ids + selected_ids + sort_by
        end
      end
    end

    def self.copy_to_remote_server(query)
      config   = Rails.configuration.database_configuration
      host     = config[Rails.env]["host"]
      database = config[Rails.env]["database"]
      username = config[Rails.env]["username"]
      password = config[Rails.env]["password"]
      system("PGPASSWORD='#{password}' psql -h #{host} -d #{database} -U #{username} -c \"\\copy #{query}\"")
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