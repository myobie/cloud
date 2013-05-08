require 'yaml'

module Cloud
  def self.provider
    @provider
  end

  def self.provider=(p)
    @provider = p
  end

  def self.boxes
    @boxes ||= []
  end

  def self.config
    return @config if defined?(@config)

    file = "./cloud.config.yml"

    @config = if File.exists?(file)
      YAML::load_file(file)
    end
  end
end

require 'cloud/roles'
require 'cloud/role'
require 'cloud/box'
