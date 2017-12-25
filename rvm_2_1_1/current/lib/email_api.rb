class EmailApi < Struct.new(:to_addresses,:subject, :from_email,:body_content,:attach_type,:attach_path,:attach_name,:client_email)
	def perform
		Api::Email.run(to_addresses,subject,from_email,body_content,attach_type,attach_path,attach_name,client_email)
	end
end