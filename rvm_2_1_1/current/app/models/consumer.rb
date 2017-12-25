require 'mandrill'
class Consumer < ActiveRecord::Base
	has_many :subscriptions
  has_many :business_customer_infos

  has_secure_password

  def self.check_consumer_subscribed(customer)
    consumer = where(user_id: customer.email).first
    consumer && check_subscribed_business(customer.user_id,consumer) ? consumer : []
  end

  def self.check_subscribed_business(user_id,consumer)
    client = User.where(id: user_id).first
    if client.parent_id == 0
      company = Company.where(user_id: client.id).first
      subscribed = Subscription.is_subscribed(company.id,consumer.id,"C")
    else
      if client.tenant_id
        tenant = Tenant.where(id: client.tenant_id).first
        subscribed = Subscription.is_subscribed(tenant.id,consumer.id,"T")
      else
        company = Company.where(user_id: client.parent_id).first
        subscribed = Subscription.is_subscribed(company.id,consumer.id,"C")
      end
    end
    subscribed
  end

  def self.invite_consumer(data,user)
    consumer = where(user_id: data["email"]).first
    unless consumer
      consumer = create(user_id: data["email"], first_name: data["customer_name"],password:"Opinify@123",
                        gender: data["gender"],mobile: data["mobile"], is_active: false)
      if consumer
        send_app_invitation(consumer,user)
        subscribe_to_business(consumer,user)
      end
    end
    consumer
  end

  def self.subscribe_to_business(consumer,user)
    client = User.where(id: user.id).first
    if client.parent_id == 0
      company = Company.where(user_id: client.id).first
      Subscription.add_subscription(company.id,consumer.id,"C")
    else
      if client.tenant_id
        tenant = Tenant.where(id: client.tenant_id).first
        Subscription.add_subscription(tenant.id,consumer.id,"T")
      else
        company = Company.where(user_id: client.parent_id).first
        Subscription.add_subscription(company.id,consumer.id,"C")
      end
    end
  end

  def self.send_app_invitation(consumer,user)
    mandrill = Mandrill::API.new ENV["MANDRILL_API_KEY"]
    template_name = "Inquirly-custom-template"
    template_content = [{ :name => 'header', :content => "<br><br> You can download the Opinify App through the link below: <br><br> <a href='#{ENV["OPINIFY_APP"]}'>Click here to download</a>" }]
    message = {
        :subject => "Invitation to Opinify",
        :from_email => user.email,
        :to => [{:email => consumer.user_id}],
        :important => true,
        :global_merge_vars => [{ :name => "IMAGE", :content => "<img src='http://inquirly.com/img/logo-light.png' mc:label='header_image' mc:edit='header_image' style='max-width:540px; text-align:centre;'>" }]
    }
    mandrill.messages.send_template template_name, template_content, message
  end

end
