class CsvJob <  Struct.new(:file_path,:group_id,:current_user)

  def perform
    BusinessCustomerInfo.insert_customer_info(file_path, group_id,current_user)
  end
end
