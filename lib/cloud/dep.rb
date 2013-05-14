require 'cloud/deps'
require 'cloud/depable'
require 'cloud/configurable'
require 'cloud/rendering'
require 'cloud/logging'
require 'cloud/rescuer'
require 'cloud/executor'

class Cloud::Dep
  include Cloud::Configurable
  include Cloud::Depable
  include Cloud::Rendering
  include Cloud::Logging
  include Cloud::Rescuer
  include Cloud::Executor

  attr_reader :box

  def self.name(new_name = nil)
    unless new_name.nil?
      @name = new_name
    end
    if @name.nil?
      @name = super().gsub(/Dep$/, '').underscore
    end
    @name
  end

  def initialize(box)
    @box = box
    @config = self.class.config.deep_merge(box.config)
  end

  def self.inherited(base)
    Cloud::Deps.all << base
  end

  def name
    self.class.name
  end

  def met?
    true
  end

  def meet
  end

  require 'cloud/dep/check'
  require 'cloud/dep/make'

  include Cloud::Dep::Check
  include Cloud::Dep::Make
end
