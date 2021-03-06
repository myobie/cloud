module Cloud::Roles
  def self.all
    @all ||= []
  end

  def self.find(name)
    name = name.to_s
    all.find { |role| role.name == name }
  end
end
