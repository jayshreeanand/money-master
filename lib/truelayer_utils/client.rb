require 'faraday'
require 'faraday_middleware'

module TruelayerUtils
  class Client
    BASE_URI = 'https://api.truelayer.com'

    def initialize(access_token=nil, url_encoded_request=false)
      @base_connection = Faraday.new do |faraday|
        faraday.url_prefix = BASE_URI

        @access_token = access_token
        if @access_token.present?
          faraday.authorization :Bearer, @access_token
        end

        if url_encoded_request
          faraday.request :url_encoded # refresh oauth token takes only url encoded POST parameters
        else
          faraday.request :json
        end
        faraday.response :raise_error
        faraday.response :logger, ::Logger.new(STDOUT), bodies: true
        faraday.response :follow_redirects
        faraday.response :logger
      end
    end

    def execute(method, url, body=nil, header=false, url_prefix=false)
      begin
        connection = @base_connection.dup
        if url_prefix
          connection.url_prefix = url_prefix
        end
        uri = URI.parse(URI.encode(url))
        connection.adapter Faraday.default_adapter
        response = connection.run_request(method, uri, body, header)
        JSON.parse(response.body)
      rescue Faraday::ClientError => e
        raise e
      end
    end

    def authenticate_url
      params = { client_id: Rails.application.secrets.truelayer_client_id, response_type: 'code', enable_mock: true, nonce: SecureRandom.hex, redirect_uri: 'http://localhost:3000/truelayer/callback', scope: 'info accounts balance transactions cards' }
      'https://auth.truelayer.com/?' + params.to_query
    end

    def fetch_access_token(code)
      params = { grant_type: 'authorization_code', code: code, client_id: Rails.application.secrets.truelayer_client_id, client_secret: Rails.application.secrets.truelayer_client_secret, redirect_uri: 'http://localhost:3000/truelayer/callback'}
      response = execute(:post, 'connect/token', params, false, 'https://auth.truelayer.com')
      response['access_token']
    end

    def bank_id
      response = execute(:get, 'data/v1/me')
      response['results'][0]['provider_id']
    end
  end
end
