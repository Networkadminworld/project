module ErpSessionData
  extend ActiveSupport::Concern
  included do

    def erp_session_data(user)
      if session[:subdomain] == "littleelly"
        raw_auth_token = JSON.parse(RestClient.post("http://preschoolapi.vanward.co/authtoken?apikey=#{ENV["LITTLEELLY_KEY"]}",''))
        session[:sso] = true
        session[:auth_token] = raw_auth_token["auth_token"]
        session[:centre_key] =  Tenant.where(id: user.tenant_id).first.try(:name) unless user.parent_id == 0
      end
    end
  end
end