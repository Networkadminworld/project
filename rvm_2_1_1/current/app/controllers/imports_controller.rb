require "#{Rails.root}/lib/csv_job.rb"
class ImportsController < ApplicationController
  require 'csv'
  require 'fileutils'

  before_filter :authenticate_user_web_api
  skip_before_filter :verify_authenticity_token, if: :json_request?

  CSV_HEADER = ["customer_name", "email", "age", "gender", "mobile(*Add mobile number without country code)", "country", "state", "city", "area", "custom_field"]

  def create_customer_info
        params[:customer][:group_id] = ContactGroup.create(name: params[:customer][:group_name], user_id: current_user.id).id if !params[:customer][:group_name].blank? && params[:customer][:is_new_group] == "true"
        if (params[:datafile] != nil && File.extname(params[:datafile].original_filename)!= ".csv") || (params[:business_customer_info][:datafile] != nil && File.extname(params[:business_customer_info][:datafile].original_filename) != ".csv")
          flash[:notice] = APP_MSG['csv']['invalid_file']
        else
	    file_path = request.format.json? ? move_file_to_tmp(params[:datafile], current_user) : move_file_to_tmp(params[:business_customer_info][:datafile],current_user)
            file = CSV.read(file_path,col_sep: ",", encoding: "ISO-8859-1")
            if file_path.present? && file.first == CSV_HEADER
              current_user.update_csv_process(false)
              Delayed::Job.enqueue(CsvJob.new(file_path, params[:customer][:group_id],current_user), 3)
              current_user.upload_customer_status
              flash[:notice] = APP_MSG['csv']['success_upload']
            else
              flash[:notice] = APP_MSG['csv']['invalid_file']
            end
         end
    render :json => { success: flash[:notice], status: 200 }
  end

  def csv_template
    respond_to do |format|
      format.csv { send_data CSV_HEADER.to_csv }
    end
  end

  def customer_data
    @customer = BusinessCustomerInfo.where("user_id =? and is_deleted is NULL",current_user.id).select(:customer_name, :email, :age, :gender, :mobile, :country, :state, :city, :area, :custom_field)
    respond_to do |format|
      format.csv { send_data @customer.to_csv }
    end
  end

  def get_upload_status
    render :json => {is_csv_processed: current_user.is_csv_processed }
  end

  private

  def move_file_to_tmp(datafile, user)
    file_name_without_extension = datafile.original_filename.gsub( /.{3}$/, '' )
    Dir.mkdir("#{ Rails.root }/tmp/csv_inputs") unless File.exists?("#{ Rails.root }/tmp/csv_inputs")
    name = "#{ file_name_without_extension }_#{ user.id }.csv"
    directory = "#{ Rails.root }/tmp/csv_inputs/"
    file_path = File.join(directory, name)
    FileUtils.mv datafile.path, file_path
    file_path
  end
end
