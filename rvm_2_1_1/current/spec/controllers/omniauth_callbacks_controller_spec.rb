require 'spec_helper'

describe Users::OmniauthCallbacksController do
  before(:each){
    controller.stub(:check_listener_module).and_return(true)
    controller.stub(:verified_request?).and_return(true)
    controller.stub(:catch_exceptions).and_yield
    controller.stub(:verify_session).and_return(true)
  }
  describe "#facebook" do
    before do
      stub_env_for_omniauth
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:facebook]
    end
    context "facebook login" do
      it "it should return successfully authenticated message" do
        fb_user = FactoryGirl.create(:user,:facebook_user, :uid => "1234" ,:authentication_token => "xyese2134343434",:confirmed_at => Time.now)
        get :facebook ,:authentication_token => fb_user.authentication_token
        expect(assigns[:user]).to eq fb_user
        #~ expect(request.session[:user]).to eq fb_user
        flash[:notice].should =~ /Successfully authenticated from Facebook account./i
      end

      #      it "it should redirect to dashboard index page" do
      #        stub_env_for_omniauth
      #        fb_user = FactoryGirl.create(:user,:facebook_user, :uid => "1234" ,:authentication_token => "xyese2134343434",:confirmed_at => Time.now)
      #        @controller.stub(:current_user) { fb_user }
      #        get :facebook
      #        expect(assigns[:user]).to eq fb_user
      #        flash[:notice].should =~ /Successfully authenticated from Facebook account./i
      #      end
    end
  end

  describe "#twitter" do
    before do
      stub_env_for_omniauth
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:twitter]
    end
    context "twitter login" do
      it "it should return successfully authenticated message" do
        User.delete_all
        twitter_user = FactoryGirl.create(:user,:twitter_user, :uid => "1234q32" ,:authentication_token => "xyese21343434342322",:twitter_oauth_token => "lk2j3lkjasldkjflasasasasasasask3ljsdf",:confirmed_at => Time.now)
        get :twitter ,:authentication_token => twitter_user.authentication_token
        expect(assigns[:user]).to eq twitter_user
        #~ expect(request.session[:user]).to eq twitter_user
        flash[:notice].should =~ /Successfully authenticated from Twitter account./i
      end
    end
  end

  describe "#linkedin" do
    before do
      stub_env_for_omniauth
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:linkedin]
    end
    context "linkedin login" do
      it "it should return successfully authenticated message" do
        User.delete_all
        linkedin_user = FactoryGirl.create(:user,:linkedin_user, :uid => "1234q3sdsd2" ,:authentication_token => "xyessdsde21343434342322",:linkedin_token => "lk2j3lkjasldkjflssasassk3ljsdf",:confirmed_at => Time.now)
        get :linkedin ,:authentication_token => linkedin_user.authentication_token
        expect(assigns[:user]).to eq linkedin_user
        #~ expect(request.session[:user]).to eq linkedin_user
        flash[:notice].should =~ /Successfully authenticated from Linkedin account./i
      end
    end
  end
  describe "#google" do
    before do
      stub_env_for_omniauth
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:google]
    end
    context "google login" do
      it "it should return successfully authenticated message" do
        User.delete_all
        google_user = FactoryGirl.create(:user,:google_user, :email => "google@gmail.com")
        get :google ,:authentication_token => google_user.authentication_token
        expect(assigns[:user]).to eq google_user
        #~ expect(request.session[:user]).to eq google_user
        flash[:notice].should =~ /Successfully authenticated from Google account./i
      end
    end
  end
=begin
  describe "#passthru" do
    it "passthru" do
      get :passthru
    end
  end

  describe "#failure" do
    it "failure" do
      get :failure
    end
  end
=end
end

def stub_env_for_omniauth
  @request.env["devise.mapping"] = Devise.mappings[:user]
end
