require 'cloud/boxes'
require 'cloud/roles'
require 'cloud/configurable'
require 'cloud/rendering'
require 'cloud/logging'

class Cloud::Box
  include Cloud::Configurable
  include Cloud::Rendering
  include Cloud::Logging

  attr_accessor :name, :opts, :memory, :ip, :image, :region, :user

  def self.create(name, opts = {})
    box = new(name, opts)
    Cloud::Boxes.all << box
    box
  end

  def dep_graph
    roles.map do |name, role|
      { "role:#{name}" => role.dep_graph }
    end
  end

  def self.memory(mem = nil)
    unless mem.nil?
      @mem = mem
    end
    @mem
  end

  def self.region(reg = nil)
    unless reg.nil?
      @region = region
    end
    @region
  end

  def self.image(img = nil)
    unless img.nil?
      @image = img
    end
    @image
  end

  def self.user(u = nil)
    unless u.nil?
      @user = u
    end
    @user
  end

  def self.parse_opts(*opt_names)
    opt_names = Array(opt_names)
    attr_accessor(*opt_names)
    define_method :parse_opts! do
      super()
      opt_names.each do |opt_name|
        instance_variable_set(:"@#{opt_name}", config.fetch(opt_name.to_s))
      end
    end
  end

  def initialize(name, opts = {})
    @name = name
    @config = self.class.config.deep_merge(opts.stringify)
    parse_opts!
  end

  def backups?
    !!@backups
  end

  private

  def parse_opts!
    @memory = config['memory'] || self.class.memory
    @image = config['image'] || self.class.image
    @region = config['region'] || self.class.region
    @user = config['user'] || self.class.user
    @ip = config['ip']
    @backups = !!config['backups']
    @provider = config['provider']
  end
  
  
  require 'cloud/box/roles'
  require 'cloud/box/provider_api'
  require 'cloud/box/check'
  require 'cloud/box/make'
  
  include Cloud::Box::Roles
  include Cloud::Box::ProviderApi
  include Cloud::Box::Check
  include Cloud::Box::Make
end
