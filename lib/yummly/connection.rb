# This class handles the HTTP interactions with the Yummly API calls.
module Yummly
  class Connection

    attr_accessor :connection

    def self.get(command, params = {})
      response = self.api_connection(self.url).get(self.uri(command, params))
      self.parse_response(response)
    end

    def self.api_connection(url)
      Faraday.new(:url => url) do |faraday|
        faraday.request :url_encoded # form-encode POST params
        faraday.response :logger # log requests to STDOUT
        faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
      end
    end

    def self.parse_response(response)
      case response.status
        when 409 then
          raise Yummly::PermissionError, response.body
        when 404 then
          raise Yummly::NotFoundError, response.body 
        when 200 then
          JSON.parse(response.body)
        when 501 then
          raise Yummly::NotEmplimentedError, response.body
      end
    end
    
    def self.domain
      "api.yummly.com"
    end

    def self.url
      "#{self.protocol}://#{self.domain}"
    end

    def self.uri(command, params)
      query_string = self.build_params_query_string(params)
      "/#{self.api_version}/api/#{command}?#{query_string}"
    end

    def self.build_params_query_string(params)
      params['_app_id'] = Yummly.configuration.app_id
      params['_app_key'] = Yummly.configuration.app_key
      Rack::Utils.build_query(params)
    end

    def self.protocol
      Yummly.configuration.use_ssl? ? 'https' : 'http'
    end

    def self.api_version
      Yummly::API_VERSION
    end

  end
end