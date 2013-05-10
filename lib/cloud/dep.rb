require 'cloud/depable'

module Cloud
  class Dep
    include Cloud::Depable

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
