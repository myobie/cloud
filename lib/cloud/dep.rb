require 'cloud/deps'
require 'cloud/depable'
require 'cloud/configurable'
require 'cloud/rendering'

module Cloud
  class Dep
    include Cloud::Configurable
    include Cloud::Depable
    include Cloud::Rendering

    attr_reader :box

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
      Cloud.p "Checking dep #{name} {"
      Cloud.inc_p
      dm = deps_check?
      mm = met?
      Cloud.dec_p

      if dm && mm
        Cloud.p "} met."
        return true
      elsif mm
        Cloud.p "} failed because of a nested dep."
        return false
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
      Cloud.p "Dep #{name} {"
      Cloud.inc_p

      nested_success = if deps.empty?
        true
      else
        deps.map do |dep|
          dep.make!
        end.all?
      end

      Cloud.dec_p

      unless nested_success
        Cloud.p "} failed because of nested dep failure."
        return false
      end

      if met?
        Cloud.p "} met."
        return true
      end

      begin
        Cloud.p "-> meeting..."
        meet_output = meet
      rescue StandardError => e
        Cloud.p "Error: #{e}."
        Cloud.p(e.backtrace.join("\n")) if $global_opts[:trace]
        unless $global_opts[:continue]
          Cloud.p "exiting..."
          exit(1)
        end
      end

      if met?
        Cloud.p "} met."
        return true
      else
        Cloud.p "} failed, couldn't meet."
        Cloud.p ">> \n#{meet_output.join("\n")}" if $global_opts[:trace]
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

    def exec(*commands, as_root: false)
      as_root = as_root || self.class.exec[:as_root]
      @box.exec(*commands, as_root: as_root)
    end

    def exec_and_log(*commands, as_root: false)
      as_root = as_root || self.class.exec[:as_root]
      @box.exec_and_log(*commands, as_root: as_root)
    end
    alias el exec_and_log
  end
end
