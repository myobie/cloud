module DigitalOcean
  class DropletApi
    def initialize(provider)
      @provider = provider
    end

    def api
      @provider.api
    end

    def all
      response = api.get("/droplets")
      if response["status"] == "OK"
        response["droplets"].map { |d| Droplet.new(self, d) }
      else
        puts response.inspect
        exit 1
      end
    end

    def find_by_name(name)
      found = all.find do |drop|
        drop.name == name
      end

      if found
        found.hydrate!
        found
      end
    end

    def get(id)
      response = api.get("/droplets/#{id}")
      if response["status"] == "OK"
        response["droplet"]
      end
    end

    def create(params)
      response = api.get("/droplets/new", params)
      if response["status"] == "OK"
        Droplet.new(self, response["droplet"])
      end
    end

    def destroy(id)
      response = api.get("/droplets/#{id}/destroy")
      response["status"] == "OK"
    end
  end

  class Droplet
    attr_accessor :id, :image_id, :name, :region_id, :size_id, :status, :ip

    def initialize(api = nil, opts = {})
      if api.is_a?(Hash)
        opts = api
        api = nil
      end
      @api = api
      parse_opts opts
    end

    def parse_opts(opts = {})
      @id = opts["id"]
      @image_id = opts["image_id"]
      @name = opts["name"]
      @region_id = opts["region_id"]
      @size_id = opts["size_id"]
      @status = opts["status"]
      @ip = opts["ip_address"]
    end

    def to_h
      {
        id: id,
        image_id: image_id,
        name: name,
        region_id: region_id,
        size_id: size_id,
        status: status,
        ip: ip
      }
    end

    def hydrate!
      raise_if_no_api
      opts = @api.get(id)
      parse_opts opts
    end

    def destroy!
      raise_if_no_api
      @api.destroy(id)
    end

    private

    def raise_if_no_api
      unless @api
        raise "no api found, so you can't do api related things with this Droplet"
      end
    end
  end
end
