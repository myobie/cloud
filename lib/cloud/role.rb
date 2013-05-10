require 'cloud/configurable'
require 'cloud/depable'
require 'cloud/rendering'
require 'cloud/ext/string'

class Cloud::Role
  include Cloud::Configurable
  include Cloud::Depable
  include Cloud::Rendering

  def initialize(opts = {})
    @config = self.class.config.deep_merge(opts.stringify)
  end

  def self.inherited(base)
    Cloud::Roles.all << base
  end

  def self.name(new_name = nil)
    unless new_name.nil?
      @name = new_name
    end
    if @name.nil?
      @name = super().gsub(/Role$/, '').underscore
    end
    @name
  end

  def self.use(name, default: nil, query: nil, value: nil)
    query ||= :"#{name}?"
    value ||= name
    default_method_name = :"default_#{value}"
    config_scope = self.current_config_scopes.join(".")

    define_method query do
      !!config_for_keys(config_scope, name)
    end

    define_method default_method_name do
      default
    end

    define_method value do
      config_for_keys(config_scope, name) || send(default_method_name)
    end
  end

  def self.current_config_scopes
    @current_config_scopes ||= []
  end

  def self.with_config_scope(scope_name)
    self.current_config_scopes.push(scope_name)
    yield
    self.current_config_scopes.pop
  end
  def self.inside(scope_name, &blk)
    with_config_scope(scope_name, &blk)
  end
end
