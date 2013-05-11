module Cloud::Commands
  module_function

  def load_awesome_print
    unless @already_loaded_awesome_print
      require 'awesome_print'
      AwesomePrint.defaults = {
        indent: 2,
        index: false
      }
      @already_loaded_awesome_print = true
    end
  end

  def inspect(obj)
    if $global_opts[:awesome]
      load_awesome_print
      ap obj
    else
      puts obj.inspect
    end
  end

  def check
    Cloud::Boxes.all.reduce({}) do |memo, box|
      memo[box.name] = box.check!
    end
  end

  def dep_graph(awesome: false)
    graph = Cloud::Boxes.all.reduce({}) do |memo, box|
      memo[box.name] = box.dep_graph
      memo
    end
    inspect graph
  end
end
