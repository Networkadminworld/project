module Api
  class Email
   def self.run(to_addresses, subject,from_email,body_content,attach_type,attach_path,attach_name,client_email)
      client = User.where(email: client_email).first
      sub_account_id = (client.parent_id == 0 || client.parent_id == nil) ? "cust-#{client.id}" : "cust-#{client.parent_id}"
      begin
         mandrill = Mandrill::API.new ENV["MANDRILL_API_KEY"]
         message = message_params(to_addresses,subject,from_email,attach_path,attach_type,attach_name,body_content,sub_account_id)
         mandrill.messages.send message
      rescue Mandrill::Error => e
        MANDRILL_LOGGER.info("A mandrill error occurred(email_api): #{e.class} - #{e.message}")
      end
   end

   def self.message_params(to_addresses,subject,from_email,attach_path,attach_type,attach_name,email_content,sub_account)
      addresses = []
      merge_vars = []
      encoded_hex = Base64.encode64(File.open( "#{attach_path}").read) unless attach_path.blank?
      to_addresses.each do |email|
         addresses << {"email" => email}
         merge_vars << { "rcpt" => email, "vars" => [{ "name" => 'CONTENT', "content" => email_content }]}
      end
      unless attach_path.blank?
         file_name = attach_name.blank? ? (File.basename attach_path) : attach_name
         file_type = get_mime_type(attach_type)
         message_hash = {
            "attachments"=>[{"content"=>"#{encoded_hex}","type"=>"#{file_type}","name"=>"#{file_name}"}],
             "merge"=> true,
             "from_email"=> from_email,
             "subject"=> subject,
             "to"=> addresses,
             "html"=> Api::EmailContent.html_content,
             "merge_vars"=> merge_vars,
             "subaccount"=> sub_account,
             "async" => true
          }
      else
         message_hash = {
             "merge"=> true,
             "from_email"=> from_email,
             "subject"=> subject,
             "to"=> addresses,
             "html"=> Api::EmailContent.html_content,
             "merge_vars"=> merge_vars,
             "subaccount"=> sub_account,
             "async" => true
          }
         message_hash
    end
   end
    
    def self.get_mime_type(mime_type)
      case mime_type
          when "pdf"
        "text/pdf"
          when "csv"
        "text/csv"
          else
        "text/plain"
      end
    end
  end
end