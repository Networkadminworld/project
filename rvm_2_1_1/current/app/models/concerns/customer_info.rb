module CustomerInfo
  extend ActiveSupport::Concern
  included do

    def update_share_detail
      ShareDetail.create_share_detail(self.user,1,'customer_records_count')
    end

    def email_downcase
      self.email.downcase! if self.email
      self.gender.downcase! if self.gender
    end

    def create_mobile_channels(obj)
      items = []
      items << "email"  if CustomersContactGroup.email_customers_count([obj.id]) > 0
      items << "sms"  if CustomersContactGroup.sms_customers_count([obj.id]) > 0
      items << "opinify" if CustomersContactGroup.opinify_customers_count([obj.id]) > 0
      items.each do |item|
         UserMobileChannel.create_channels(item,obj.id,obj.user_id)
      end
    end

    def remove_mobile_channels(obj)
      items = []
      items << "email"  if CustomersContactGroup.email_customers_count([obj.id]) == 0
      items << "sms"  if CustomersContactGroup.sms_customers_count([obj.id]) == 0
      items << "opinify" if CustomersContactGroup.opinify_customers_count([obj.id]) == 0
      items.each do |item|
        UserMobileChannel.remove_channels(item,obj.id,obj.user_id)
      end
    end

    def update_mobile_channels
      self.contact_groups.each do |group|
        group.add_or_remove_email_channel
        group.add_or_remove_sms_channel
        group.add_or_remove_opinify
      end
    end

    def update_in_all_customers
      groups = ContactGroup.where(name: "All Customers", user_id: self.user_id)
      groups.each do |group|
        self.contact_groups << group unless self.contact_groups.include?(group)
      end
    end
  end
end