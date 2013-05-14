require 'cloud/deps'
require 'cloud/depable'
require 'cloud/configurable'
require 'cloud/rendering'
require 'cloud/logging'
require 'cloud/rescuer'

module Cloud
  class Dep
    include Cloud::Configurable
    include Cloud::Depable
    include Cloud::Rendering
    include Cloud::Logging
    include Cloud::Rescuer

    attr_reader :box

    def self.exec(opts = {})
      unless opts.nil? || opts.empty?
        @exec_opts = opts
      end
      @exec_opts ||= {}
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

    def name
      self.class.name
    end

    def met?
      true
    end

    def meet
    end

    def deps_met?
      if deps.empty?
        true
      else
        deps.map do |dep|
          dep.met?
        end.all?
      end
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
      success = log "Checking dep #{name} {" do
        deps_check? && met?
      end

      if success
        log "} met."
        return true
      else
        log "} failed."
        return false
      end
    end

    def make!
      nested_success = nil

      log "Dep #{name} {" do
        nested_success = if deps.empty?
          true
        else
          deps.map do |dep|
            dep.make!
          end.all?
        end
      end

      unless nested_success
        log "} failed because of nested dep failure."
        return false
      end

      if met?
        log "} met."
        return true
      end

      meet_output = []

      rescuer do
        log "-> meeting..."
        meet_output = meet
      end

      if met?
        log "} met."
        return true
      else
        log "} failed, couldn't meet."
        log ">> \n#{meet_output.join("\n")}" if $global_opts[:trace]
        return false
      end
    end

    def exec(*commands)
      @box.exec(*commands)
    end

    def exec_and_log(*commands)
      @box.exec_and_log(*commands)
    end
    alias el exec_and_log
  end
end
