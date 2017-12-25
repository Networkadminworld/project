module CsvProcess
  extend ActiveSupport::Concern
  included do

  def self.create_process_files(path,user)
    name = path == "#{ Rails.root }/tmp/biz_customer_records" ? "db" : "file"
    @valid_email = "#{path}/valid_email_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    @copy_header = "#{path}/_header_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    @csv_header = "#{path}/csv_header_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    @duplicate_email = "#{path}/_email_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    @email_blank = "#{path}/_email_blank_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    @final_valid_csv = "#{path}/_final_merged_csv_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    @email_not_blank = "#{path}/_email_not_blank_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    @update_email_error = "#{path}/email_duplicate_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    @error_list = "#{path}/#{name}_duplicate_entries_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    @valid_list = "#{path}/#{name}_valid_list_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
  end
  
  def self.run(user,original_file,path,email_error,mobile_error)	
    create_process_files(path,user)
    #check for duplicate emails
    system("awk -F, '{if ($2 == \"\")print}' OFS=, #{original_file} > #{@email_blank}")
    system("awk -F, '{if ($2 != \"\" && $2 != \"email\")print}' OFS=, #{original_file} > #{@email_not_blank}")
    system("awk -F, '!a[$2]++' #{@email_not_blank} > #{@valid_email}") #Remove duplicate emails
    system("awk -F, 'NR==1 {print;next}' #{original_file} > #{@copy_header}") # Copy the CSV header
    system("awk -F, '{$(NF+1)=\"status\"}1' OFS=, #{@copy_header} > #{@csv_header}") # Header file
    system("awk -F, '++a[$2]>1 {print $lines}' OFS=, #{@email_not_blank} > #{@duplicate_email}") # Stored duplicate emails in separate file
    system("awk -F, '{$(NF+1)=\"#{email_error}\"}1' OFS=, #{@duplicate_email} > #{@update_email_error}") # update email duplicate message
    system("cat #{@csv_header} #{@valid_email} #{@email_blank} > #{@final_valid_csv}") # Merge email blank csv with valid list csv
    system("awk -F , '{if ($11!=\"db\") print}' OFS=, #{@final_valid_csv} > #{@valid_list}") #Remove the DB duplicated
    system("cat #{@csv_header} #{@update_email_error} > #{@error_list}") #final duplicate file with header attached
    system("rm -rf #{@valid_email} #{@copy_header} #{@csv_header} #{@duplicate_email} #{@update_email_error}") #remove all the tmp created files
    return @valid_list, @error_list
  end

  def self.fetch_db_records(user,valid_file)
    Dir.mkdir("#{ Rails.root }/tmp/biz_customer_records") unless File.exists?("#{ Rails.root }/tmp/biz_customer_records")
    exist_file_name = "#{ Rails.root }/tmp/biz_customer_records/customer_records_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    sanitized_sql = "(SELECT customer_name,email,age,gender,mobile,country,state,city,area,custom_field FROM business_customer_infos where user_id = #{user.id} and email != '' and is_deleted is NULL) TO '#{exist_file_name}' WITH CSV HEADER"
    copy_to_server(sanitized_sql)
    csv_list = "#{ Rails.root }/tmp/biz_customer_records/cust_records_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    combined_csv_list = "#{ Rails.root }/tmp/biz_customer_records/combined_customer_records_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    db_type_list = "#{ Rails.root }/tmp/biz_customer_records/db_customer_records_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    system("awk -F, '{$(NF+1) = NR==1 ? \"type\" : \"db\"}1'  OFS=,  #{exist_file_name} > #{db_type_list}") # Add db type
    system("awk '{if (NR!=1) {print}}' #{valid_file} > #{csv_list}") # Remove the Header of CSV file
    system("cat #{db_type_list} #{csv_list} > #{combined_csv_list}") # CSV file with DB records
    system("rm -rf #{exist_file_name} #{db_type_list} #{csv_list}") #remove temp created files
    combined_csv_list
  end

  def self.fetch_db_deleted_records(user,valid_file)
    Dir.mkdir("#{ Rails.root }/tmp/customer_del_records") unless File.exists?("#{ Rails.root }/tmp/customer_del_records")
    exist_file_name = "#{ Rails.root }/tmp/customer_del_records/customer_records_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    sanitized_sql = "(SELECT customer_name,email,age,gender,mobile,country,state,city,area,custom_field FROM business_customer_infos where user_id = #{user.id} and email != '' and is_deleted='t') TO '#{exist_file_name}' WITH CSV HEADER"
    copy_to_server(sanitized_sql)
    csv_list = "#{ Rails.root }/tmp/customer_del_records/cust_records_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    combined_csv_list = "#{ Rails.root }/tmp/customer_del_records/combined_customer_records_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    db_type_list = "#{ Rails.root }/tmp/customer_del_records/db_customer_records_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    system("awk -F, '{$(NF+1) = NR==1 ? \"type\" : \"deleted\"}1'  OFS=,  #{exist_file_name} > #{db_type_list}") # Add db type
    system("awk '{if (NR!=1) {print}}' #{valid_file} > #{csv_list}") # Remove the Header of CSV file
    system("cat #{db_type_list} #{csv_list} > #{combined_csv_list}") # CSV file with DB records
    system("rm -rf #{exist_file_name} #{db_type_list} #{csv_list}") #remove temp created files
    combined_csv_list
  end

  def self.copy_to_server(query)
    config   = Rails.configuration.database_configuration
    host     = config[Rails.env]["host"]
    database = config[Rails.env]["database"]
    username = config[Rails.env]["username"]
    password = config[Rails.env]["password"]
    system("PGPASSWORD='#{password}' psql -h #{host} -d #{database} -U #{username} -c \"\\copy #{query}\"")
  end

  def self.get_valid_list(user,original_file)
    # Add is_deleted Header to the original_file
    Dir.mkdir("#{ Rails.root }/tmp/csv_inputs") unless File.exists?("#{ Rails.root }/tmp/csv_inputs")
    path = "#{ Rails.root }/tmp/csv_inputs"
    csv_file_name = "#{path}/csv_records_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    system("awk -F, '{$(NF+1) = NR==1 ? \"type\" : \"file\"}1'  OFS=,  #{original_file} > #{csv_file_name}")
    valid_csv_list, duplicate_csv_list= run(user,csv_file_name,path,APP_MSG["csv"]["repeat_email"],APP_MSG["csv"]["repeat_mobile"]) # Remove duplicate in file
    combined_list = fetch_db_records(user,valid_csv_list)
    path = "#{ Rails.root }/tmp/biz_customer_records"
    final_valid_list,duplicate_db_list = run(user,combined_list,path,APP_MSG["csv"]["email_exist"],APP_MSG["csv"]["mobile_exist"])  # Remove duplicate with DB
    valid_csv = "#{path}/valid_csv_records_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    final_processed_csv = "#{path}/valid_csv_inputs_#{user.id}_#{Time.now.strftime('%H:%M:%S')}.csv"
    system("awk -F , '{if ($11!=\"db\") print}' OFS=, #{final_valid_list} > #{valid_csv}") # Remove DB records from final list
    # Fetch is_deleted records
    deleted_list = fetch_db_deleted_records(user,valid_csv)
    path = "#{ Rails.root }/tmp/customer_del_records"
    final_valid_list,db_deleted_list = run(user,deleted_list,path,"Email deleted","Mobile deleted")  # Find is_deleted true
    system("awk -F , '{if ($11!=\"deleted\") print}' OFS=, #{final_valid_list} > #{valid_csv}") # Remove deleted records from final list
    system("cut -d\",\" -f1,2,3,4,5,6,7,8,9,10 #{valid_csv} > #{final_processed_csv}") #Remove type coloumn
    system("rm -rf #{combined_list} #{final_valid_list} #{valid_csv} #{valid_csv_list} #{deleted_list}")
    return final_processed_csv,duplicate_csv_list,duplicate_db_list,db_deleted_list
  end
 end
end
