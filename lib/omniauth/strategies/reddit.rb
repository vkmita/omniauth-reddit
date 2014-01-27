require 'omniauth/strategies/oauth2'
require 'base64'
require 'rack/utils'

module OmniAuth
  module Strategies
    class Reddit < OmniAuth::Strategies::OAuth2
      #class NoAuthorizationCodeError < StandardError; end

      option :name, "reddit"
      option :authorize_options, [:scope, :duration]

      option :client_options, {
        site: 'https://ssl.reddit.com',
        authorize_url: 'https://ssl.reddit.com/api/v1/authorize',
        token_url: 'https://ssl.reddit.com/api/v1/access_token'
      }

      uid { raw_info['id'] }

      info do
        {
          name: raw_info['name'],
          email: raw_info['email']
        }
      end

      extra do
        {
            'username' => raw_info['name'],
            'subreddits' => { 'subscriber' => subscriber_subreddits, 'moderator' => moderator_subreddits }
        }
      end

      def username
        @username ||= raw_info['name']
      end

      def subscriber_subreddits
        @subscriber_subreddits ||= sleep(0.5) && access_token.get('/subreddits/mine/subscriber').parsed || {}
      end

      def moderator_subreddits
        @moderator_subreddits ||= sleep(0.5) && access_token.get('/subreddits/mine/moderator').parsed || {}
      end

      def raw_info
        @raw_info ||= access_token.get('/api/v1/me').parsed || {}
      end

      def build_access_token
        options.token_params.merge!(:headers => {'Authorization' => basic_auth_header })
        super
      end

      def basic_auth_header
        "Basic " + Base64.strict_encode64("#{options[:client_id]}:#{options[:client_secret]}")
      end

    end
  end
end
