module Cloud::Boxes
  def self.all
    @all ||= []
  end

  def self.find(name)
    name = name.to_s
    all.find { |box| box.name == name }
  end
end
