require 'csv'
require 'fileutils'
require 'erb'
module ShareOnMobile
  extend ActiveSupport::Concern
  included do

    def self.email_process(params,user,campaign)
      email_channels = campaign.email_channels
      BitLyService.new.create_shorten_url('email',campaign) if email_channels.count > 0 && campaign.long_url
      email_channels.each do |channel|
        dir = File.dirname("#{Rails.root}/public/campaign_share_files/#{user.id}/..")
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
        file = "#{dir}/local_email_camp_#{user.id}_#{campaign.id}_#{channel.contact_group_id}_#{Time.now.strftime('%H:%M:%S:%L')}.csv"
        sanitized_sql = "(SELECT email FROM business_customer_infos INNER JOIN customers_contact_groups ON business_customer_infos.id = customers_contact_groups.business_customer_info_id WHERE customers_contact_groups.contact_group_id = #{channel.contact_group_id} and (status = '' or status = 'false' or status = 'f' or status is NULL)) TO '#{file}' WITH CSV HEADER"
        copy_to_remote_server(sanitized_sql)
        new_file = File.new(file)
        total_emails = new_file.readlines.size - 1
        plan = ShareDetail.get_plan_detail(user,campaign.schedule_on)
        if ShareDetail.is_share_count_exceeds?(plan,plan.share_detail,'email',total_emails)
          InviteUser.delay.campaign_unsuccessful(user, "email",campaign)
        else
          if total_emails > 0
            ShareDetail.create_share_detail(user,total_emails,'email_count',campaign)
            Delayed::Job.enqueue MailerJob.new(file,user,campaign,channel), priority: 2, run_at: params[:schedule_on], campaign_id: campaign.id, user_id: user.id, share_now: params[:share_now]
          end
        end
      end
    end

    def self.sms_process(params,user,campaign)
      sms_channels = campaign.sms_channels
      BitLyService.new.create_shorten_url('sms',campaign) if sms_channels.count > 0 && campaign.long_url
      sms_content = JSON.parse(Campaign.where(id: campaign.id).first.campaign_detail.campaign_data)["sms_content"]
      sms_channels.each do |channel|
        indian_sms_service(user,campaign,channel,sms_content,params)
        international_sms_service(user,campaign,channel,sms_content,params)
      end
    end

    def self.indian_sms_service(user,campaign,channel,sms_content,params)
      dir = File.dirname("#{Rails.root}/public/campaign_share_files/#{user.id}/..")
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      ind_sms_file = "#{dir}/local_sms_camp_#{user.id}_#{campaign.id}_#{channel.contact_group_id}_#{Time.now.strftime('%H:%M:%S:%L')}.csv"
      sanitized_sql = "(SELECT mobile FROM business_customer_infos INNER JOIN customers_contact_groups ON business_customer_infos.id = customers_contact_groups.business_customer_info_id WHERE mobile LIKE 'dontuse%' and mobile != '' and customers_contact_groups.contact_group_id = #{channel.contact_group_id}) TO '#{ind_sms_file}' WITH CSV HEADER"
      copy_to_remote_server(sanitized_sql)
      begin
        sms_file = fetch_mobile_numbers(ind_sms_file,sms_content)
        file_limit = File.new(sms_file)
        number_count = file_limit.readlines.size - 1
        plan = ShareDetail.get_plan_detail(user,campaign.schedule_on)
        if ShareDetail.is_share_count_exceeds?(plan,plan.share_detail,'sms',number_count)
          InviteUser.delay.campaign_unsuccessful(user, "sms",campaign)
        else
          if number_count > 0
            ShareDetail.create_share_detail(user,number_count,'sms_count',campaign)
            Delayed::Job.enqueue CampaignSmsJob.new(sms_file, ERB::Util.url_encode(replace_shorten_url(sms_content,campaign)),channel,campaign), priority:1, run_at: params[:schedule_on], campaign_id: campaign.id, user_id: user.id, share_now: params[:share_now]
          end
        end
      rescue
        InviteUser.delay.csv_copy_error_mail(user, "sms")
      end
    end

    def self.international_sms_service(user,campaign,channel,sms_content,params)
      dir = File.dirname("#{Rails.root}/public/campaign_share_files/#{user.id}/..")
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      intern_sms_file = "#{dir}/intern_sms_camp_#{user.id}_#{campaign.id}_#{channel.contact_group_id}_#{Time.now.strftime('%H:%M:%S:%L')}.csv"
      sanitized_sql = "(SELECT mobile FROM business_customer_infos INNER JOIN customers_contact_groups ON business_customer_infos.id = customers_contact_groups.business_customer_info_id WHERE mobile != '' and customers_contact_groups.contact_group_id = #{channel.contact_group_id}) TO '#{intern_sms_file}' WITH CSV HEADER"
      copy_to_remote_server(sanitized_sql)
      begin
        sms_content = JSON.parse(campaign.reload.campaign_detail.campaign_data)["sms_content"]
        sms_file = fetch_mobile_numbers(intern_sms_file,sms_content)
        file_limit = File.new(sms_file)
        number_count = file_limit.readlines.size - 1
        plan = ShareDetail.get_plan_detail(user,campaign.schedule_on)
        if ShareDetail.is_share_count_exceeds?(plan,plan.share_detail,'sms',number_count)
          InviteUser.delay.campaign_unsuccessful(user, "sms",campaign)
        else
          if number_count > 0
            ShareDetail.create_share_detail(user,number_count,'sms_count',campaign)
            Delayed::Job.enqueue I18nCampaignSmsJob.new(sms_file, replace_shorten_url(sms_content,campaign),channel,campaign), priority:1, run_at: params[:schedule_on], campaign_id: campaign.id, user_id: user.id, share_now: params[:share_now]
          end
        end
      rescue
        InviteUser.delay.csv_copy_error_mail(user, "sms")
      end
    end

    def self.replace_shorten_url(sms_content,campaign)
      short_url = JSON.parse(campaign.campaign_detail.campaign_data)["shorten_url"]
      sms_short_url = campaign.reload.campaign_detail.campaign_short_urls["sms_shorten_url"]
      sms_content.gsub(short_url, sms_short_url) if short_url && sms_short_url.present?
      sms_content
    end

    def self.fetch_mobile_numbers(file,message)
      numbers = []
      CSV.foreach(file, :headers => true, :header_converters => :symbol, :skip_blanks => true, :encoding => 'ISO-8859-1', :converters => :all) do |row|
        hash_val = Hash[row.headers[0..-1].zip(row.fields[0..-1])]
        numbers << hash_val[:mobile]
      end
      change_header_value(file,numbers.compact.uniq,message)
    end

    def self.change_header_value(file,numbers,message)
      CSV.open(file, "wb") do |csv|
        csv << ["PHONE","MESSAGE"]
        numbers.each do |number|
          csv << [number,message]
        end
      end
      file
    end

    def self.copy_to_remote_server(query)
      config   = Rails.configuration.database_configuration
      host     = config[Rails.env]["host"]
      database = config[Rails.env]["database"]
      username = config[Rails.env]["username"]
      password = config[Rails.env]["password"]
      system("PGPASSWORD='#{password}' psql -h #{host} -d #{database} -U #{username} -c \"\\copy #{query}\"")
    end
  end
end
