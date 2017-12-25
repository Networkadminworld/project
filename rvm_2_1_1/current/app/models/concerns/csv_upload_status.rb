module CsvUploadStatus
  extend ActiveSupport::Concern
  included do

    def self.import_customers_status(user, success_count, error_count, total_record, remaining_count,error_list_path)
      attach_file = File.read(error_list_path)
      size = (attach_file.size).to_f/1000.to_f
      mandrill = Mandrill::API.new ENV["MANDRILL_API_KEY"]
      template_name = "Inquirly-custom-template"
      template_content = [
          { :name    => 'header',
            :content =>  message_block(user, success_count, error_count, total_record, remaining_count,size,error_list_path)
          }]
      if size > 2000
        message = get_message(user)
      elsif success_count > 0 || error_count > 0
        attach_file_encoded = Base64.encode64(attach_file)
        message = {
            :subject => "Customer Information Upload Process Completed",
            :from_email => ENV["ALERT_EMAIL"],
            :to => [{:email => user.email}],
            :important => true,
            :attachments =>[{:type =>"text/csv",:content => attach_file_encoded, :name =>"customer_infos.csv"}],
            :global_merge_vars => [
                { :name => "IMAGE",
                  :content => "<img src='http://inquirly.com/img/logo-light.png' mc:label='header_image' mc:edit='header_image' style='max-width:540px; text-align:centre;'>"
                }]
        }
      else
        message = get_message(user)
      end

      mandrill.messages.send_template template_name, template_content, message
    end

    def self.message_block(user, success_count, error_count, total_record, remaining_count,size,error_list_path)
      message = remaining_count != 0 ? "Business contacts have been uploaded successfully." : "You have reached the maximum upload limit."
      download_link = size > 2000 ? "Check here for invalid and upload records #{uploaded_public_url(error_list_path)}" : ''
      %Q{
        <p>Dear #{user.first_name},</p>
        <p> #{message}
        <p>Total contacts : #{total_record} </p>
        <p>No of contacts uploaded successfully : #{success_count}</p>
        <p>No of contacts not loaded : #{error_count < 0 ? 0 : error_count}</p>
        <p>Remaining no of contacts in allocated limit : #{remaining_count}</p>
        <p> #{download_link} </p>
        Regards,<br>
        Inquirly Admin<br>
      }
    end

    def self.get_message(user)
      {
          :subject => "Customer Information Upload Process Completed",
          :from_email => ENV["ALERT_EMAIL"],
          :to => [{:email => user.email}],
          :important => true,
          :global_merge_vars => [
              { :name => "IMAGE",
                :content => "<img src='http://inquirly.com/img/logo-light.png' mc:label='header_image' mc:edit='header_image' style='max-width:540px; text-align:centre;'>"
              }]
      }
    end

    def self.uploaded_public_url(error_list_path)
      key = File.basename(error_list_path)
      bucket_name = ENV['AWS_BUCKET']
      s3 = Aws::S3::Resource.new
      obj = s3.bucket(bucket_name).object(key)
      obj.upload_file(error_list_path, acl:'public-read')
      obj.public_url
    end
  end
end
