require 'csv'
require 'fileutils'
module ValidateCsv
  extend ActiveSupport::Concern
  included do
  def self.csv_process(file,user)
      error_hash_value = []
      success_hash_val = []
      remaining_records = remaining_upload_limit(user)
      countries_name = Country.all.collect { |x| x.first.downcase }
      count = 0
      CSV.foreach(file, :headers => true, :header_converters => :symbol, :skip_blanks => true, :encoding => 'ISO-8859-1', :converters => :all) do |row|
        begin
          hash_val = Hash[row.headers[0..-1].zip(row.fields[0..-1])]
          if remaining_records > 0 && count < remaining_records
              hash_val, @error_status, @can_upload = error_status_notify(hash_val,countries_name)
                @country = countries_name.index(hash_val[:country].to_s.downcase)
                if @can_upload
                  hash_val[:country] = countries_name[@country].camelize if @country.present?
                  hash_val[:gender] = hash_val[:gender].to_s.downcase
                  hash_val[:email] = hash_val[:email].present? ? hash_val[:email].to_s.downcase : hash_val[:email]
                  success_hash_val << hash_val
                  count += 1
                else
                  hash_val[:status] = @error_status                  
                  error_hash_value << hash_val
                end              
          else
            hash_val[:status] = "limit exceed"
            error_hash_value << hash_val
          end
        rescue => e
          Rails.env == "development" ? (p e) : (Rails.logger.info e)
          InviteUser.delay.csv_file_error_mail(user, csv_file_status = false)
          return false
        end
      end
      Dir.mkdir("#{Rails.root}/tmp/csv_processed") unless File.exists?("#{Rails.root}/tmp/csv_processed")
      name = "valid_hash_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
      directory = "#{Rails.root}/tmp/csv_processed/"
      path = File.join(directory, name)
      CSV.open(path, "wb") do |csv|
       if success_hash_val.present?
	      csv << ["customer_name","email","age","gender","mobile","country","state","city","area","custom_field"]
        success_hash_val.each do |hash|
          csv << hash.values
        end
       end
      end
      error_path = invalid_data(error_hash_value, user)
      [path,error_path]
  end

  def self.error_status_notify(hash_val,countries_name)
      # Validation preparation
      hash_val = hash_val.each{ |k, v| v.gsub!(/,/, '') if v.is_a?(String)}
      hash_val = hash_val.each{ |k, v| v.strip! if v.is_a?(String)}
      error_status = []
      @can_upload = true

      #Validate Customer Name
      if !hash_val[:customer_name].blank? && hash_val[:customer_name].to_s.match(/^[a-zA-Z0-9_\-., ]*$/).nil?
          @can_upload = false
          error_status  << APP_MSG["csv"]["name_format"]
      elsif !hash_val[:customer_name].blank? && !hash_val[:customer_name].to_s.match(/^[a-zA-Z0-9_\-., ]*$/).nil? && hash_val[:customer_name].to_s.length < 1
          @can_upload = false
          error_status  << APP_MSG["csv"]["name_min"]
      elsif !hash_val[:customer_name].blank? && !hash_val[:customer_name].to_s.match(/^[a-zA-Z0-9_\-., ]*$/).nil? && hash_val[:customer_name].to_s.length > 80
          @can_upload = false
          error_status  << APP_MSG["csv"]["name_max"]
      end

      #Validate Email
      if !hash_val[:email].blank? && hash_val[:email].to_s.match(/^[A-Za-z0-9._%+-]+@(?:[A-Za-z0-9-]{2,50}\.){1,2}[A-Za-z]{2,4}$/i).nil?
         @can_upload = false
         error_status  << APP_MSG["csv"]["email_format"]
      end

      #Validate Age
      if !hash_val[:age].blank? && hash_val[:age].to_s.match(/^\d{1,2}$/).nil?
          @can_upload = false
          error_status  << APP_MSG["csv"]["age_limit"]
      end

      #Validate Gender
      if !hash_val[:gender].to_s.downcase.blank? && !DEFAULTS["csv_gender_values"].include?(hash_val[:gender].to_s.downcase)
         @can_upload = false
         error_status  << APP_MSG["csv"]["gender_format"]
      end

      #Validate Country
      if !hash_val[:country].blank? && (hash_val[:country].to_s.match(/^[a-zA-Z+\s]*$/).nil? || countries_name.index(hash_val[:country].to_s.downcase).nil?)
         @can_upload = false
         error_status  << APP_MSG["csv"]["country_format"]
      end

      #Validate Mobile Number
      if !hash_val[:mobileadd_mobile_number_without_country_code].blank? && hash_val[:mobileadd_mobile_number_without_country_code].to_s.match(/^(\d{8,15})$/).nil?
         @can_upload = false
         error_status  << APP_MSG["csv"]["mobile_format"]
      end

      if hash_val[:email].blank? && hash_val[:mobileadd_mobile_number_without_country_code].blank?
        @can_upload = false
        error_status  << APP_MSG["csv"]["email_or_mobile_blank"]
      end

      #Validate Other Columns
      if hash_val[:state].to_s.length > 200
        @can_upload = false
        error_status  << APP_MSG["csv"]["state_max"]
      elsif !hash_val[:state].blank? && hash_val[:state].to_s.match(/^[a-zA-Z0-9_\-., ]*$/).nil?
        @can_upload = false
        error_status  << APP_MSG["csv"]["state_invalid"]
      end

      if hash_val[:city].to_s.length > 200
        @can_upload = false
        error_status  << APP_MSG["csv"]["city_max"]
      elsif !hash_val[:city].blank? && hash_val[:city].to_s.match(/^[a-zA-Z0-9_\-., ]*$/).nil?
        @can_upload = false
        error_status  << APP_MSG["csv"]["city_invalid"]
      end

      if hash_val[:area].to_s.length > 200
        @can_upload = false
        error_status  << APP_MSG["csv"]["area_max"]
      elsif !hash_val[:area].blank? && hash_val[:area].to_s.match(/^[a-zA-Z0-9_\-., ]*$/).nil?
        @can_upload = false
        error_status  << APP_MSG["csv"]["area_invalid"]
      end

      if hash_val[:custom_field].to_s.length > 200
        @can_upload = false
        error_status  << APP_MSG["csv"]["custom_field_length"]
      elsif !hash_val[:custom_field].blank? && hash_val[:custom_field].to_s.match(/^[a-zA-Z0-9_\-., ]*$/).nil?
        @can_upload = false
        error_status  << APP_MSG["csv"]["custom_field_invalid"]
      end

      # Add Country Code to the Mobile Number
      if hash_val[:country].present? &&
         hash_val[:country].match(/^[a-zA-Z+\s]*$/).present? &&
         countries_name.index(hash_val[:country].to_s.downcase).present? &&
         hash_val[:mobileadd_mobile_number_without_country_code].present? &&
         hash_val[:mobileadd_mobile_number_without_country_code].to_s.match(/^(\d{8,15})$/).present?
            country_code = Country.find_country_by_name(hash_val[:country]).country_code
            hash_val[:mobileadd_mobile_number_without_country_code]  = "#{country_code}#{hash_val[:mobileadd_mobile_number_without_country_code]}"
      elsif hash_val[:country].blank? &&
          hash_val[:mobileadd_mobile_number_without_country_code].present? &&
          hash_val[:mobileadd_mobile_number_without_country_code].to_s.match(/^(\d{8,15})$/).present?
        hash_val[:mobileadd_mobile_number_without_country_code]  = "91#{hash_val[:mobileadd_mobile_number_without_country_code]}"
        hash_val[:country] = "india"
      else
          hash_val[:mobileadd_mobile_number_without_country_code] = "" if hash_val[:mobileadd_mobile_number_without_country_code].blank?
      end
      status_msg = error_status.each_with_index{|v,i| "#{i+1}.#{v}"}
      [hash_val, status_msg, @can_upload]
    end
 
    def self.invalid_data(error_hash_value, user)
	    file_path = "#{ Rails.root }/tmp/csv_processed/error_info_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
	    CSV.open(file_path, "wb") do |csv|
	        csv << ["customer_name","email","age","gender","mobile","country","state","city","area","custom_field", "status"]
	        error_hash_value.each do |hash|
		      csv << hash.values
	        end
      end
      file_path
    end
   end
  end