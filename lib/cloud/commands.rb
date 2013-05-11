module Cloud::Commands
  module_function

  def check
    Cloud.boxes.reduce({}) do |memo, box|
      memo[box.name] = box.check!
    end
  end
end
