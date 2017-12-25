require 'rubygems'
module ActiveModel; module Observing; end; end # Prevents spork from exiting due to non-existent class in rails4.
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'
require "paperclip/matchers"
require 'simplecov'
SimpleCov.start do
  add_filter "/devise"
  add_filter "/lib"
  add_filter 'app/admin'
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Routing', 'app/routing'
  add_group 'Helpers', 'app/helpers'
end

Spork.prefork do
  #Loading more in this block will cause your tests to run faster. However,
  #if you change any configuration or code from libraries loaded here, you'll
  #need to restart spork for it take effect.

  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'sunspot_test/rspec'
  require 'capybara/rspec'
  require 'capybara/rails'
  require 'factory_girl_rails'
  require 'sunspot/rails/spec_helper'
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  def  action_mailer_reset
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end
  RSpec.configure do |config|
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:twitter, {  :provider    => "twitter",
                                          :uid         => "1234",
                                          :info   => {   :name       => "Bob hope",
                                                         :nickname   => "bobby",
                                                         :first_name => "Test",
                                                         :last_name => "Test",
                                                         :urls       => {:Twitter => "www.twitter.com/bobster"}},
                                          :credentials => {   :token => "lk2j3lkjasldkjflasasasasasasask3ljsdf"} })

    OmniAuth.config.add_mock(:facebook, {  :provider    => "facebook",
                                           :uid         => "1234",
                                           :info   => {   :name       => "Bob hope",
                                                          :nickname   => "bobby",
                                                          :first_name => "Test",
                                                          :last_name => "Test",
                                                          :urls       => {:Twitter => "www.facebook.com/bobster"}},
                                           :credentials => {   :auth_token => "lk2j3lkjasldkjflk3ljsdf"} })

    OmniAuth.config.add_mock(:linkedin, {  :provider    => "linkedin",
                                           :uid         => "1234",
                                           :info   => {   :name       => "Bob hope",
                                                          :nickname   => "bobby",
                                                          :first_name => "Test",
                                                          :last_name => "Test",
                                                          :urls       => {:Twitter => "www.linkedin.com/bobster"}},
                                           :credentials => {   :token => "lk2j3lkjasldkjflssasassk3ljsdf" , :secret => "wesssdsdsdsd3232323423"} })

    OmniAuth.config.add_mock(:google, {  :provider    => "Google",
                                         :info   => {   :name       => "Bob hope",
                                                        :nickname   => "bobby",
                                                        :email => "google@gmail.com",
                                                        :first_name => "Test",
                                                        :last_name => "Test"}})

    # config.before(:all) do
    #   system("rake", "sunspot:solr:start")
    # end

    # config.after(:all) do
    #   system("rake", "sunspot:solr:stop")
    # end

    # config.before(:each) do
    #   ::Sunspot.session = ::Sunspot::Rails::StubSessionProxy.new(::Sunspot.session)
    # end

    # config.after(:each) do
    #   ::Sunspot.session = ::Sunspot.session.original_session
    # end

    # $original_sunspot_session = Sunspot.session

    # RSpec.configure do |config|
    #   config.before do
    #     Sunspot.session = Sunspot::Rails::StubSessionProxy.new($original_sunspot_session)
    #   end

    #   config.before :each, :solr => true do
    #     Sunspot::Rails::Tester.start_original_sunspot_session
    #     Sunspot.session = $original_sunspot_session
    #     #Sunspot.remove_all!
    #   end
    # end



    config.include Devise::TestHelpers, :type => :controller
    config.extend ControllerMacros, :type => :controller
    config.include Paperclip::Shoulda::Matchers
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = true
    config.infer_base_class_for_anonymous_controllers = false
    config.order = "random"
  end

Spork.each_run do
  #This code will be run each time you run your specs.

 end

#--- Instructions ---
#Sort the contents of this file into a Spork.prefork and a Spork.each_run
#block.
#
#The Spork.prefork block is run only once when the spork server is started.
#You typically want to place most of your (slow) initializer code in here, in
#particular, require'ing any 3rd-party gems that you don't normally modify
#during development.
#
#The Spork.each_run block is run each time you run your specs.  In case you
#need to load files that tend to change during development, require them here.
#With Rails, your application modules are loaded automatically, so sometimes
#this block can remain empty.
#
#Note: You can modify files loaded *from* the Spork.each_run block without
#restarting the spork server.  However, this file itself will not be reloaded,
#so if you change any of the code inside the each_run block, you still need to
#restart the server.  In general, if you have non-trivial code in this file,
#it's advisable to move it into a separate file so you can easily edit it
#without restarting spork.  (For example, with RSpec, you could move
#non-trivial code into a file spec/support/my_helper.rb, making sure that the
#spec/support/* files are require'd from inside the each_run block.)
#
#Any code that is left outside the two blocks will be run during preforking
#*and* during each_run -- that's probably not what you want.
#
#These instructions should self-destruct in 10 seconds.  If they don't, feel
#free to delete them.
end
