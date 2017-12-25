require 'spec_helper'

describe AccountController do
  # include Devise::TestHelpers
  before(:each){
    controller.stub(:check_listener_module).and_return(true)
    controller.stub(:verified_request?).and_return(true)
    controller.stub(:authenticate_user_web_api).and_return(true)
    controller.stub(:verify_session).and_return(true)
    controller.stub(:check_role_level_permissions).and_return(true)
    controller.stub(:catch_exceptions).and_yield
  }

end