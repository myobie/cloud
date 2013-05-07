require 'cloud/configurable'
require 'cloud/rendering'
require 'cloud/roles'

class Cloud::Box
  include Cloud::Configurable
  include Cloud::Rendering

  attr_accessor :name, :opts, :memory, :ip

  def self.create(name, opts = {})
    box = new(name, opts)
    Cloud.boxes << box
    box
  end

  def self.roles(*role_names)
    @role_names = Array(role_names)
    unless @role_names.empty?
      @roles = @role_names.map do |name|
        Cloud::Roles.find(name)
      end
    end
    @roles
  end

  def roles
    @roles ||= self.class.roles.reduce({}) do |memo, role|
      memo[role.name] = role.new(config)
      memo
    end
  end

  def self.memory(mem = nil)
    unless mem.nil?
      @mem = mem
    end
    @mem
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
    @config = self.class.config.deep_merge(opts).stringify
    parse_opts!
  end

  def backups?
    !!@backups
  end

  def exists?
    Cloud.provider.exists?(self)
  end

  private

  def parse_opts!
    @memory = config['memory'] || self.class.memory
    @ip = config['ip']
    @backups = !!config['backups']
  end
end
