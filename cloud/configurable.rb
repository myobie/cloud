require 'cloud/ext/hash'

module Cloud::Configurable
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def config(hash = nil)
      @config ||= {}
    
      unless hash.nil? && !block_given?
        unless hash.nil?
          @config = hash.stringify
        end
        if block_given?
          @config = yield.stringify
        end
      end
    
      @config
    end
  end

  def config
  	@config
  end

  def config_for_keys(*keys)
    config_for_string(keys.join("."))
  end

  def config_for_string(key_string)
    config.descend(key_string)
  end

end