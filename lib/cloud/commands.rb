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

  def provision(box_name)
    box = Cloud::Boxes.find(box_name)

    if box
      if box.exists?
        Cloud.p "Box #{box.name} already exists, not creating."
        exit(1)
      else
        Cloud.p "Provisioning box #{box.name}..."
        box.provision!
        if Cloud.wait(60) { box.ready? }
          Cloud.p "#{box.name} provisioned and ready."
        else
          Cloud.p "taking more than 60 seconds, exiting."
          exit(1)
        end
      end
    else
      Cloud.p "Couldn't find the box #{box_name}"
      exit(1)
    end
  end
end
