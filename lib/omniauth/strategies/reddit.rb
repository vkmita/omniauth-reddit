require 'omniauth/strategies/oauth2'
require 'base64'
require 'rack/utils'
require 'oauth2/reddit_client'

module OmniAuth
  module Strategies
    class Reddit < OmniAuth::Strategies::OAuth2
      AUTHORIZATION_HOST = 'https://ssl.reddit.com'
      AUTHORIZATION_PATH = '/api/v1/authorize'
      ACCESS_TOKEN_PATH  = '/api/v1/access_token'

      option :client_options, {
        site: AUTHORIZATION_HOST,
        authorize_url: AUTHORIZATION_HOST + AUTHORIZATION_PATH,
        token_url: AUTHORIZATION_HOST + ACCESS_TOKEN_PATH
      }

      option :name, "reddit"
      option :authorize_options, [:scope, :duration]

      uid { api_v1_me['id'] }

      info do
        {
          name: api_v1_me['name'],
          email: api_v1_me['email']
        }
      end

      extra do
        {
          :username => username,
          :email => email
          #:subreddits => {
          #  :subscribed => subreddits_mine_subscriber,
          #  :moderated => subreddits_mine_moderator
          #}
        }
      end

      def client
        ::OAuth2::RedditClient.new(options.client_id, options.client_secret, deep_symbolize(options.client_options))
      end

      def username
        @username ||= api_v1_me['name']
      end

      def email
        @email ||= api_v1_me['email']
      end

      def api_v1_me
        @api_v1_me ||= access_token.get('/api/v1/me').parsed || {}
      end

      def subreddits_mine_moderator
        @subreddits_mine_moderator ||= access_token.get('/subreddits/mine/moderator').parsed || {}
      end

      def subreddits_mine_subscriber
        @subreddits_mine_subscriber ||= access_token.get('/subreddits/mine/subscriber').parsed || {}
      end


      def build_access_token
        options.token_params.merge!(:headers => {'Authorization' => basic_auth_header })
        super
      end

      def basic_auth_header
        "Basic #{Base64.strict_encode64("#{options[:client_id]}:#{options[:client_secret]}")}"
      end

    end
  end
end
