module Cloud::Logging
  def self.included(base)
    base.extend ClassMethods
  end

  def log(message = nil, &blk)
    self.class.log(message, &blk)
  end

  def inspect(obj)
    self.class.inspect(obj)
  end

  def indent_logging
    self.class.indent_logging
  end

  def outdent_logging
    self.class.outdent_logging
  end

  module ClassMethods
    def log(message = nil) 
      result = nil

      if message
        spaces = " " * current_indent
        puts "#{spaces}#{message}"
      end

      if block_given?
        indent_logging
        result = yield
        outdent_logging
      end

      result
    end

    def indent_logging
      $current_indent ||= 0
      $current_indent += 2
    end

    def outdent_logging
      $current_indent ||= 0
      $current_indent -= 2
      if $current_indent < 0
        $current_indent = 0
      end
      $current_indent
    end

    def current_indent
      $current_indent ||= 0
    end

    def load_awesome_print
      unless $already_loaded_awesome_print
        require 'awesome_print'
        AwesomePrint.defaults = {
          indent: 2,
          index: false
        }
        $already_loaded_awesome_print = true
      end
    end

    def inspect(obj)
      if $global_opts[:awesome]
        load_awesome_print
        ap obj
      else
        puts obj.inspect
      end
    end
  end
end