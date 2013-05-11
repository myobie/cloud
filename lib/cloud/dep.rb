require 'cloud/deps'
require 'cloud/depable'
require 'cloud/configurable'
require 'cloud/rendering'

module Cloud
  class Dep
    include Cloud::Configurable
    include Cloud::Depable
    include Cloud::Rendering

    def self.exec(opts = {})
      unless opts.nil? || opts.empty?
        @exec_opts = opts
      end
      @exec_opts
    end

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

    def met?
      false
    end

    def meet
      raise "meet is not defined"
    end

    def exec(*commands, as_root: false)
      as_root = as_root || self.class.exec[:as_root]
      @box.exec(*commands, as_root: as_root)
    end
  end
end
