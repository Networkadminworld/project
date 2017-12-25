require 'spec_helper'

describe ApplicationController do
  before(:each){
        controller.stub(:check_listener_module).and_return(true)
    controller.stub(:verified_request?).and_return(true)
    controller.stub(:authenticate_user_web_api).and_return(true)
    controller.stub(:catch_exceptions).and_yield
    controller.stub(:verify_session).and_return(true)
  }
  app_con = ApplicationController.new
  describe "Application Controller as model" do
    it "model test" do
      # app_con = ApplicationController.new
      expect(app_con.class).to eq(ApplicationController)
    end

    it "must verify email properly" do
      # app_con = ApplicationController.new
      expect(app_con.valid_email? "someone@gmail.com").to eq(true)
    end

    it "must return false for invalid email" do
      # app_con = ApplicationController.new
      expect(app_con.valid_email? "someonemail.com").to eq(false)
    end

      # it "" do
      #   app_con.check_listener_module
      # # expect(app_con.check_listener_module).to eq(false)
      # end
  end
end