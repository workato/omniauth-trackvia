require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Trackvia < OmniAuth::Strategies::OAuth2

      option :name, 'trackvia'

      option :client_options,
             site: 'https://go.trackvia.com',
             authorize_url: 'https://go.trackvia.com/oauth/authorize',
             token_url: 'https://go.trackvia.com/oauth/token'

      uid { user_id }

      info do
        { uid: user_id,
          name: username,
          email: user_email }
      end

      extra do
        { raw_info: raw_info }
      end

      def user_email
        raw_info['email']
      end

      def username
        raw_info['username']
      end

      def user_id
        @user_id ||= access_token.params['oauth_id']
      end

      def raw_info
        @raw_info ||= access_token.get('users').parsed
      end
    end
  end
end
