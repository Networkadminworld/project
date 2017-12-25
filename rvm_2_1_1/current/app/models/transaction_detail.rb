class TransactionDetail < ActiveRecord::Base

 def self.crypto_key_split(enc_response)
   working_key = ENV["CCAVENUE_WOKING_KEY"]
   crypto = Crypto.new 
   dec_resp=crypto.decrypt(enc_response,working_key)
   dec_response = dec_resp.split("&")
   build_hash = {}
   dec_response.each do |key|
     build_hash[key.from(0).to(key.index("=")-1)] = key.from(key.index("=")+1).to(-1)
    end
   transaction_detail = self.find_transaction(build_hash["order_id"])
   return build_hash, transaction_detail
 end

 def self.find_transaction(order_id)
   self.where("order_id = ? AND payment_status =?",order_id, "Incomplete").first
 end

 def self.create_transaction(current_user,params)
   self.create(:user_id => current_user.id, :business_type_id => current_user.business_type_id, :order_id => params["order_id"], :payment_status => "Incomplete",:request_plan_id => params["plan_id"],:action => params["plan_action"],:amount=>params["amount"])
 end

 def update_transaction_details(plan_id,decrypt_response,exp_date = nil)
   self.update_attributes(:business_type_id => plan_id, :amount => decrypt_response["amount"].to_f , :payment_status =>decrypt_response["order_status"] , :tracking_id => decrypt_response["tracking_id"].to_i, :bank_ref_no => decrypt_response["bank_ref_no"], :failure_message => decrypt_response["failure_message"], :payment_mode => decrypt_response["payment_mode"], :card_name => decrypt_response["card_name"],:status_code => decrypt_response["status_code"],:status_message=>decrypt_response["status_message"] ,:currency => decrypt_response["currency"],:expiry_date => exp_date)
 end

 def self.build_transactions(user_id,params)
   transaction_details = where(user_id: user_id).limit(params[:per_page].to_i)
   transaction_history = transaction_details.paginate(:page => params[:page], :per_page => params[:per_page])
   transactions = {}
   transactions["transaction_history"] = []
   transaction_history.each do |detail|
     json = {}
     json["transaction_id"] = detail.transaction_id
     json["created_at"] = detail.created_at.strftime("#{detail.created_at.day.ordinalize} of %b, %Y")
     json["item"] = PricingPlan.where(id: detail.business_type_id).first.try(:plan_name)
     json["amount"] = detail.amount
     json["status"] = detail.payment_status
     transactions["transaction_history"] << json
   end
   transactions["num_results"] = where(user_id: user_id).count
   transactions
 end

end