require 'providers/digital_ocean/api'
require 'providers/digital_ocean/droplet'

module DigitalOcean
  class Provider
    attr_reader :config

    def initialize(opts = {})
      @config = opts
    end

    def api
      @api ||= begin
        client_id = config.fetch("client_id") { ENV["DO_CLIENT_ID"] }
        api_key   = config.fetch("api_key")   { ENV["DO_API_KEY"] }
        DigitalOcean::Api.new(client_id, api_key)
      end
    end

    def droplet_api
      @droplet_api ||= DropletApi.new(self)
    end

    def sizes
      response = api.get("/sizes")
      if response["status"] == "OK"
        response["sizes"]
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

    def exists?(box)
      !!info(box)
    end

    def info(box)
      droplet_api.find_by_name(box.name)
    end

    def destroy(box)
      drop = droplet_api.find_by_name(box.name)
      if drop
        drop.destroy!
      end
    end

    def provision(box)
      if !exists?(box)
        image_id = if box.image
          find_image_id(box.image)
        else
          default_image_id
        end

        region_id = if box.region
          find_region_id(box.region)
        else
          default_region_id
        end

        params = {
          name: box.name,
          size_id: find_size_id(box.memory),
          image_id: image_id,
          region_id: region_id
        }

        if configured_ssh_key_id
          params["ssh_key_ids"] = configured_ssh_key_id
        end

        droplet_api.create(params)
      end
    end

    def ssh_keys
      response = api.get("/ssh_keys")
      if response["status"] == "OK"
        response["ssh_keys"]
      end
    end

    def find_ssh_key_id(name)
      found = ssh_keys.find do |key|
        key["name"] == name
      end

      if found
        found["id"]
      end
    end

    def configured_ssh_key_id
      if config["ssh_key"]
        find_ssh_key_id(config["ssh_key"])
      end
    end

    def images
      response = api.get("/images")
      if response["status"] == "OK"
        response["images"]
      end
    end

    def find_image_id(image_name)
      found = images.find do |image|
        image["name"] == image_name
      end

      if found
        found["id"]
      end
    end

    def default_image_id
      if config["image"]
        find_image_id(config["image"])
      end
    end

    def regions
      response = api.get("/regions")
      if response["status"] == "OK"
        response["regions"]
      end
    end

    def find_region_id(region_name)
      found = regions.find do |region|
        region["name"] == region_name
      end

      if found
        found["id"]
      end
    end

    def default_region_id
      if config["region"]
        find_region_id(config["region"])
      end
    end
  end
end
