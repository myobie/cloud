require 'rest-client'
require 'json'

module DigitalOcean
  class Api
    def initialize(client_id, api_key)
      @client_id = client_id
      @api_key = api_key
    end

    def url_for(path)
      "https://api.digitalocean.com#{path}"
    end

    def params_for(params = {})
      params.merge({
        client_id: @client_id,
        api_key:   @api_key
      })
    end

    def get(path, params = {})
      response = RestClient.get url_for(path),
        params:       params_for(params),
        accept:       "application/json",
        content_type: "application/json"

      JSON.parse(response.body)
    end
  end
end
