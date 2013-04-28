module Cloud::Roles
  def self.all
    @all ||= []
  end
  
  def self.find(name)
    all.find { |role| role.name == name }
  end
end