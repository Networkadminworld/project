class SmsIndia < Struct.new(:file_name, :msg)
  require 'rest_client'
  def perform
    RestClient.post('http://enterprise.smsgupshup.com/GatewayAPI/rest', :xlsFile => File.new(file_name), :method => "xlsUpload", :userid => ENV["GUPSHUP_USERID"], :password => ENV["GUPSHUP_PASSWORD"], :msg => msg, :msg_type => "TEXT", :version => "1.1", :auth_scheme => "PLAIN", :filetype => "csv")
  end
end
