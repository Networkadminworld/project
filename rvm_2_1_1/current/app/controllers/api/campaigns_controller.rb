require 'erb'
class Api::CampaignsController < ApplicationController

  def email_blast
    errors = validate_inputs(params,"email")
    if errors.blank?
     ShareDetail.update_share_count(@client,params[:to_addresses].count,'email_count')
     Delayed::Job.enqueue(EmailApi.new(params[:to_addresses], params[:subject],params[:from_email],params[:body_content],params[:attach_type],params[:attach_path],params[:attach_name],params[:client_email]), 2)
     msg = {status: 200, message: APP_MSG['api']['email_success']}
    else
     msg = {status: 400, message: errors}
    end
    render :json => msg
  end


  def sms_blast
    errors = validate_inputs(params,"sms")
    if errors.blank?
      file = copy_sms_csv(params[:file_path])
      file_limit = File.new(file)
      number_count = file_limit.readlines.size - 1
      ShareDetail.update_share_count(@client,number_count,'sms_count') if number_count > 0
      Delayed::Job.enqueue(SmsIndia.new(file, ERB::Util.url_encode(params[:message])), 1)
      msg = {status: 200, message: APP_MSG['api']['sms_success']}
    else
      msg = {status: 400, message: errors}
    end
    render :json => msg
  end

  private

  def copy_sms_csv(file)
    file_name_without_extension = file.original_filename.gsub( /.{3}$/, '' )
    Dir.mkdir("#{ Rails.root }/tmp/sms_api_inputs") unless File.exists?("#{ Rails.root }/tmp/sms_api_inputs")
    name = "#{ file_name_without_extension }_#{ @client.id }_#{Time.now.strftime('%H:%M:%S')}.csv"
    directory = "#{ Rails.root }/tmp/sms_api_inputs/"
    file_path = File.join(directory, name)
    FileUtils.mv file.path, file_path
    file_path
  end

  def validate_inputs(params,type)
    errors = {}
    if type == "email"
      errors["to_addresses"] = APP_MSG['api']['blank_value'] if params[:to_addresses].blank?
      errors["from_email"] = APP_MSG['api']['blank_value'] if params[:from_email].blank?
      errors["invalid_from_email"] = APP_MSG["api"]["invalid_from_email"] if !params[:from_email].blank? && params[:from_email].match(/^[A-Za-z0-9._%+-]+@(?:[A-Za-z0-9-]{2,3}\.){1,2}[A-Za-z]{2,4}$/i).nil?
      errors["email_max_limit"] = APP_MSG['api']['email_max_limit'] if !params[:to_addresses].blank? && params[:to_addresses].is_a?(Array) && params[:to_addresses].count > 1000
      check_client_details(params,"email_count",errors)
    elsif type == "sms"
      errors["file_path"] = APP_MSG['api']['blank_value'] if params[:file_path].blank?
      errors["message"] = APP_MSG['api']['blank_value'] if params[:message].blank?
      check_client_details(params,"sms_count",errors)
    end
    errors
  end

  def check_client_details(params,type,errors)
    @client = User.where(email: params[:client_email]).first
    if params[:client_email].blank?
      errors["client_email"] = APP_MSG['api']['blank_value']
    elsif params[:client_email].present? && @client.blank?
      errors["client_email"] =  APP_MSG['api']['invalid_email']
    elsif @client.present? && @client.role && @client.check_action_privilege("#{type}") == 'disable'
      errors["limit_exceeded"] = APP_MSG['authorization']['limit']
    elsif @client.present? && @client.role && check_role_permissions(@client)
      errors["permission_issue"] = APP_MSG['authorization']['failure']
    end
    errors
  end

  def check_role_permissions(client)
    permissions = Permission.define_permissions(client)
    !Permission.check_user_role_permissions("share","show",client,permissions)
  end
end
