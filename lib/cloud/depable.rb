module Cloud::Depable
  def self.included(base)
    base.extend ClassMethods
  end

  def dep_names
    self.class.deps
  end

  def deps
    @deps ||= self.class.dep_classes.map do |dep|
      dep.new(box)
    end
  end

  def dep_graph
    self.class.dep_graph
  end

  module ClassMethods
    def deps(*deps)
      deps = Array(deps)
      @deps ||= []

      unless deps.empty?
        @deps.concat(deps)
      end

      @deps
    end

    def dep_classes
      deps.map do |name|
        Cloud::Deps.find(name)
      end
    end

    def dep_graph
      dep_classes.map do |dep|
        if dep.deps.empty?
          dep.name
        else
          { dep.name => dep.dep_graph }
        end
      end.compact
    end
  end
end
