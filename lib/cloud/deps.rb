module Cloud::Deps
  def self.all
    @all ||= []
  end

  def self.find(name)
    name = name.to_s
    all.find { |dep| dep.name == name }
  end
end
