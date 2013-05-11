require 'cloud/roles'
require 'cloud/configurable'
require 'cloud/depable'
require 'cloud/rendering'
require 'cloud/ext/string'

class Cloud::Role
  include Cloud::Configurable
  include Cloud::Depable
  include Cloud::Rendering

  attr_reader :box

  def initialize(box)
    @box = box
    @config = self.class.config.deep_merge(box.config)
  end

  def deps_check?
    if deps.empty?
      true
    else
      deps.map do |dep|
        dep.check!
      end.all?
    end
  end

  def check!
    Cloud.p "Checking role #{name} {"
    Cloud.inc_p
    dm = deps_check?
    Cloud.dec_p

    if dm
      Cloud.p "} met."
      return true
    else
      Cloud.p "} failed."
      return false
    end
  rescue StandardError => e
    Cloud.p "} failed, because of #{e}."
    Cloud.p(e.backtrace) if $global_opts[:trace]
    unless $global_opts[:continue]
      Cloud.p "exiting..."
      exit(1)
    end
  end

  def make!
    Cloud.p "Role #{name} {"
    Cloud.inc_p
    m = deps.map do |dep|
      dep.make!
    end.all?
    Cloud.dec_p

    if m
      Cloud.p "} met."
      return true
    else
      Cloud.p "} failed."
      return false
    end
  rescue StandardError => e
    Cloud.p "} failed, because of #{e}."
    Cloud.p(e.backtrace) if $global_opts[:trace]
    unless $global_opts[:continue]
      Cloud.p "exiting..."
      exit(1)
    end
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

  def name
    self.class.name
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
