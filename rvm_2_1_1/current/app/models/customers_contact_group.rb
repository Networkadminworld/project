class CustomersContactGroup < ActiveRecord::Base
  def self.email_customers_count(contact_groups)
    count_by_sql("select count(*) from customers_contact_groups as c,business_customer_infos as biz where c.business_customer_info_id = biz.id
                 and c.contact_group_id in (#{contact_groups.join(',')}) and (biz.email != '' and (biz.status = 'false' or biz.status = '' or biz.status = 'f' or biz.status is NULL))")
  end

  def self.sms_customers_count(contact_groups)
    count_by_sql("select count(*) from customers_contact_groups as c,business_customer_infos as biz where c.business_customer_info_id = biz.id
                 and c.contact_group_id in (#{contact_groups.join(',')}) and (biz.mobile != '' and biz.mobile is not null)")
  end

  def self.opinify_customers_count(contact_groups)
    count_by_sql("select count(*) from customers_contact_groups as c,business_customer_infos as biz where c.business_customer_info_id = biz.id
                 and c.contact_group_id in (#{contact_groups.join(',')}) and biz.is_active_consumer is true")
  end
end