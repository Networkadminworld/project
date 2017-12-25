module CustomerGroupInfo
  extend ActiveSupport::Concern
  included do

    def self.update_group_value(user,params)
      params[:groups] = params[:groups].nil? ? [] : [params[:groups]]
      unless params[:group_name].blank?
        contact = ContactGroup.create(name: params[:group_name], user_id: user.id)
        params[:groups] << contact.id.to_i
      end
      params[:groups] = params[:groups].compact.reject { |c| c.to_s.empty? }
      selected_contacts = ContactGroup.where(id: params[:groups]).map(&:id)
      (0..selected_contacts.length-1).each do |i|
        file = "/tmp/email_customers_#{i}_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
        sanitized_sql = "(#{sql_condition(user,params)}) TO '#{file}' WITH CSV HEADER"
        copy_to_remote_server(sanitized_sql)
        final_customer_csv = "/tmp/final_customers_#{i}_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
        system("awk -F, '{$(NF+1) = NR==1 ? \"contact_group_id\" : \"#{selected_contacts[i]}\"}1'  OFS=,  #{file} > #{final_customer_csv}")
        final_csv = "/tmp/final_group_customers_#{i}_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
        system("awk '{if (NR!=1) {print}}' #{final_customer_csv} > #{final_csv}")
        conn = ActiveRecord::Base.connection
        rc = conn.raw_connection
        rc.exec("COPY customers_contact_groups (business_customer_info_id, contact_group_id) FROM STDIN WITH CSV  DELIMITER ','  ESCAPE '\n' NULL ''  ENCODING 'SQL_ASCII'")
        file = File.open(final_csv, 'r')
        while !file.eof?
          rc.put_copy_data(file.readline)
        end
        rc.put_copy_end
        while res = rc.get_result
          if @message == res.error_message
            Rails.env == "development" ? (p @message) : (Rails.logger.info @message)
          end
        end

        # Update the Channel in User Mobile Channel
        if UserMobileChannel.where(contact_group_id: selected_contacts[i],user_id: user.id)
          items = []
          items << "email"  if CustomersContactGroup.email_customers_count([selected_contacts[i]]) > 0
          items << "sms"  if CustomersContactGroup.sms_customers_count([selected_contacts[i]]) > 0
          items << "opinify" if CustomersContactGroup.opinify_customers_count([selected_contacts[i]]) > 0
          items.each do |item|
            UserMobileChannel.create_channels(item,selected_contacts[i],user.id)
          end
        end
      end
    end

    def self.sql_condition(user,params)
      unchecked_customers = params[:unchecked_customers].present? ? params[:unchecked_customers].join(',') : []
      checked_customers = params[:customers].present? ? params[:customers].join(',') : []
      if params[:state]
        select_all_true(user,params,unchecked_customers)
      else
        select_all_false(user,params,checked_customers)
      end
    end

    def self.select_all_true(user,params,unchecked_customers)
      if params[:search_text].blank? && params[:unchecked_customers].nil?
        "SELECT id as business_customer_info_id from business_customer_infos where user_id=#{user.id} and
           is_deleted is NULL #{filter_business_customers(params)}"
      elsif params[:search_text].blank? && !params[:unchecked_customers].nil?
        "SELECT id as business_customer_info_id from business_customer_infos where user_id=#{user.id} and
           id not in (#{unchecked_customers}) and is_deleted is NULL #{filter_business_customers(params)}"
      elsif !params[:search_text].blank? && params[:unchecked_customers].nil?
        "SELECT id as business_customer_info_id from business_customer_infos where (email ILIKE '%#{params[:search_text]}%' or
           mobile ILIKE '%#{params[:search_text]}%' or customer_name ILIKE '%#{params[:search_text]}%') and user_id=#{user.id} and
           is_deleted is NULL #{filter_business_customers(params)}"
      elsif !params[:search_text].blank? && !params[:unchecked_customers].nil?
        "SELECT id as business_customer_info_id from business_customer_infos where (email ILIKE '%#{params[:search_text]}%' or
           mobile ILIKE '%#{params[:search_text]}%' or customer_name ILIKE '%#{params[:search_text]}%') and user_id=#{user.id} and
           id not in (#{unchecked_customers}) and is_deleted is NULL #{filter_business_customers(params)}"
      end
    end

    def self.select_all_false(user,params,checked_customers)
      if params[:search_text].blank? && !params[:customers].nil?
        "SELECT id as business_customer_info_id from business_customer_infos where user_id=#{user.id} and
           id in (#{checked_customers}) and is_deleted is NULL #{filter_business_customers(params)}"
      elsif !params[:search_text].blank? && !params[:customers].nil?
        "SELECT id as business_customer_info_id from business_customer_infos where (email ILIKE '%#{params[:search_text]}%' or
           mobile ILIKE '%#{params[:search_text]}%' or customer_name ILIKE '%#{params[:search_text]}%') and user_id=#{user.id} and
           is_deleted is NULL and id in (#{checked_customers}) #{filter_business_customers(params)}"
      end
    end
  end
end