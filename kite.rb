require 'yaml'
require 'erb'

module Kite
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
    
    file = "./kite.config.yml"
    
    @config = if File.exists?(file)
      YAML::load_file(file)
    end
  end
end

class Box
  attr_accessor :name, :opts, :memory, :ip
  
  def self.create(name, opts = {})
    box = new(name, opts)
    Kite.boxes << box
    box
  end
  
  def self.deps(*deps)
    deps = Array(deps)
    @deps ||= []
    
    unless deps.empty?
      @deps.concat(deps)
    end
    
    @deps
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
        instance_variable_set(:"@#{opt_name}", @opts.fetch(opt_name))
      end
    end
  end
  
  def self.config(hash = nil)
    @config ||= {}
    
    unless hash.nil? && !block_given?
      unless hash.nil?
        @config = hash
      end
      if block_given?
        @config = yield
      end
    end
    
    @config
  end

  def self.use(name, default: nil, query: nil, value: nil)
    query ||= :"#{name}?"
    value ||= name
    default_method_name = :"default_#{value}"
    current_config = self.current_config_scope.dup # is there a better way to do this?

    define_method query do
      !!current_config[name]
    end

    define_method default_method_name do
      default
    end

    define_method value do
      current_config.fetch(name) { send(default_method_name) }
    end
  end

  def self.current_config_scope
    self.current_config_scopes.first
  end

  def self.current_config_scopes
    @current_config_scope ||= [self.config]
  end

  def self.with_config_scope(scope_name)
    self.current_config_scopes.push(self.current_config_scope[scope_name])
    yield
    self.current_config_scopes.pop
  end

  def config
  	@opts
  end

  def initialize(name, opts = {})
    @name = name
    @opts = self.class.config.merge(opts)
    parse_opts!
  end
  
  def backups?
    !!@backups
  end
  
  private
  
  def parse_opts!
    @memory = @opts['memory'] || self.class.memory
    @ip = @opts['ip']
    @backups = !!@opts['backups']
  end
  
  def render(file: nil, text: nil)
    contents = case
      when file
        File.read(file)
      when text
        text
      end
    
    erb = ERB.new(contents)
    erb.result(binding)
  end
end
