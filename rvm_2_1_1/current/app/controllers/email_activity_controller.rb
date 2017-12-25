class EmailActivityController < ApplicationController

  def show
    head(:ok)
  end

  def reject_list
    BusinessCustomerInfo.update_reject_list(JSON.parse(params['mandrill_events']))
    render :json => {status:200, message: "success"}
  end

end
