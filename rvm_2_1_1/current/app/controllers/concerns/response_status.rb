module ResponseStatus
  extend ActiveSupport::Concern
  included do
	def success status, response=nil
	  api_response(status,response)
	end
	
	def failure status, response=nil
	  api_response(status,response)
	end
	
	def invalid_token status, response=nil
	  render json: {:status => status , :response => response}
	end
	
	private
	
	def api_response(status=nil, response=nil)
	  {:status => status , :response => response}
	end
  end
end