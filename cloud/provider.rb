require 'rest-client'
require 'json'

module DigitalOcean
  class Provider
    attr_reader :config

    def initialize(opts = {})
      @config = opts
    end

    def exists?(box)
      !!find_droplet_id(box.name)
    end

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

    def api
      client_id = config.fetch("client_id") { ENV["DO_CLIENT_ID"] }
      api_key   = config.fetch("api_key")   { ENV["DO_API_KEY"] }
      @api ||= Api.new(client_id, api_key)
    end

    def sizes
      @sizes ||= begin
        response = api.get("/sizes")
        if response["status"] == "OK"
          response["sizes"]
        end
      end
    end

    def find_size_id(string)
      found = sizes.find do |size|
        size["name"].downcase.gsub(/ +/, '') == string.downcase.gsub(/ +/, '')
      end

      if found
        found["id"]
      end
    end

    def droplets
      response = api.get("/droplets")
      if response["status"] == "OK"
        response["droplets"]
      end
    end

    def find_droplet_id(name)
      found = droplets.find do |drop|
        drop["name"] == name
      end

      if found
        found["id"]
      end
    end
  end
end
