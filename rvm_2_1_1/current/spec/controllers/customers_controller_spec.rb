require 'spec_helper'

describe CustomersController do
  before(:each){
    controller.stub(:check_listener_module).and_return(true)
    controller.stub(:verified_request?).and_return(true)
    controller.stub(:catch_exceptions).and_yield
    controller.stub(:verify_session).and_return(true)
  }
  describe "#index" do
    business_user
  end

  describe "#create" do
    business_user
    it "must respond with status 200" do
      params = {}
      params[:customer] = {:mobile=> "123456789",:email => "abc@def.ghi",:country=>  "IN",:gender=> "male"}
      params[:authentication_token] = @user.authentication_token
      xhr :post, :create, params
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

  describe "#update" do
    business_user
    it "must respond with status 200" do
      @business_customer_info = FactoryGirl.create(:business_customer_info, :user_id => @user.id)
      put :update, :customer => {:mobile=> "1234567890",:country=>"IN", :email => "ramanujam@gmail.com"},:authentication_token => @user.authentication_token,:id => @business_customer_info.id
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end
  
  describe "#get_customer_email" do
    business_user
    it "must respond with status 200" do
      get :get_customer_email, authentication_token: @user.authentication_token
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

end