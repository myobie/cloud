module Cloud::Role::Config
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def use(name, default: nil, query: nil, value: nil)
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

    def current_config_scopes
      @current_config_scopes ||= []
    end

    def with_config_scope(scope_name)
      self.current_config_scopes.push(scope_name)
      yield
      self.current_config_scopes.pop
    end
    def inside(scope_name, &blk)
      with_config_scope(scope_name, &blk)
    end
  end
end