class Hash
  def descend(key_string)
    if key_string.nil? || key_string.empty?
      self
    else
      keys = key_string.split(".")
      keys.reduce(self) do |memo, key|
        memo[key]
      end
    end
  end
  
  def stringify
    each_with_object({}) do |(key, value), memo|
      if value.is_a?(Hash)
        value = value.stringify
      end
      memo[key.to_s] = value
    end
  end
end