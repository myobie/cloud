require 'cloud/roles'
require 'cloud/configurable'
require 'cloud/depable'
require 'cloud/rendering'
require 'cloud/ext/string'
require 'cloud/logging'

class Cloud::Role
  include Cloud::Configurable
  include Cloud::Depable
  include Cloud::Rendering
  include Cloud::Logging

  attr_reader :box

  def initialize(box)
    @box = box
    @config = self.class.config.deep_merge(box.config)
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

  require 'cloud/role/check'
  require 'cloud/role/make'
  require 'cloud/role/config'

  include Cloud::Role::Check
  include Cloud::Role::Make
  include Cloud::Role::Config
end
