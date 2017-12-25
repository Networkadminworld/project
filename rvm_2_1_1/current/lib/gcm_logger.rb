class GcmLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
  end
end
 
logfile = File.open("#{Rails.root}/log/gcm.log", 'a')  # create log file
logfile.sync = true  # automatically flushes data to file
GCM_LOGGER = GcmLogger.new(logfile)  # constant accessible anywher