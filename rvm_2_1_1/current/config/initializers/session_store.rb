# Be sure to restart your server when you modify this file.

#~ InquirlyNew::Application.config.session_store :cookie_store, key: '_inquirly-new_session'
 InquirlyNew::Application.config.session_store :active_record_store, domain: :all

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# InquirlyNew::Application.config.session_store :active_record_store
Rails.application.config.middleware.insert_before(
  Rails.application.config.session_store,
  FlashSessionCookieMiddleware,
  Rails.application.config.session_options[:key]
)
require 'action_dispatch/session/active_record_store'
require 'base64'
module ActiveRecord
  module SessionStore
    extend ActiveSupport::Concern
    module ClassMethods # :nodoc:
      def marshal(data)
        Base64.encode64( ActiveSupport::JSON.encode(data) ) if data
      end

      def unmarshal(data)
        ActiveSupport::JSON.decode( Base64.decode64(data) ) if data
      end

      def drop_table!
        connection_pool.clear_table_cache!(table_name)
        connection.drop_table table_name
      end

      def create_table!
        connection_pool.clear_table_cache!(table_name)
        connection.create_table(table_name) do |t|
          t.string session_id_column, :limit => 255
          t.text data_column_name
        end
        connection.add_index table_name, session_id_column, :unique => true
      end
    end
  end
end