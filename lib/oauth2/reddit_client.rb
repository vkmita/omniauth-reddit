require 'oauth2/client'

module OAuth2
  class RedditClient < Client
    AUTHORIZATION_HOST = 'https://ssl.reddit.com'
    API_HOST           = 'https://oath.reddit.com'

    def request(verb, url, opts = {})
      super
      sleep(0.5)
      #self.site = API_HOST if self.site == AUTHORIZATION_HOST
    end
  end
end
