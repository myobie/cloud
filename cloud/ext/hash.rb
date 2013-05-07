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

  def deep_merge(other)
    merger = proc { |key, v1, v2|
      if v1.is_a?(Hash) && v2.is_a?(Hash)
        v1.merge(v2, &merger)
      else
        v2
      end
    }
    self.merge(other, &merger)
  end
end
