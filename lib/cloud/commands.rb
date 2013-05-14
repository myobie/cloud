require 'cloud/wait'
require 'cloud/logging'
require 'cloud/rescuer'

module Cloud::Commands
  module_function

  include Cloud::Wait
  include Cloud::Logging
  include Cloud::Rescuer

  def info
    rescuer do
      Cloud::Boxes.all.map do |box|
        log "Box #{box.name}:" do
          if box.exists?
            inspect box.info
          else
            log "doesn't exist."
          end
        end
      end
      log "Done."
    end
  end

  def check
    rescuer do
      Cloud::Boxes.all.reduce({}) do |memo, box|
        memo[box.name] = box.check!
      end
    end
  end

  def make(box_name)
    rescuer do
      box = find_box(box_name)
      box.make!
    end
  end

  def dep_graph
    rescuer do
      graph = Cloud::Boxes.all.reduce({}) do |memo, box|
        memo[box.name] = box.dep_graph
        memo
      end
      inspect graph
    end
  end

  def provision(box_name)
    rescuer do
      box = find_box(box_name)

      if box.exists?
        log "Box #{box.name} already exists, not creating."
        exit(1)
      else
        log "Provisioning box #{box.name}..."
        box.provision!
        if wait(180) { box.ready? }
          `ssh-keygen -f ~/.ssh/known_hosts -R #{box.info[:ip]} > /dev/null 2&>1`
          log "#{box.name} provisioned and ready."
        else
          log "taking more than 3 minutes, exiting."
          exit(1)
        end
      end
    end
  end

  def destroy(box_name)
    rescuer do
      box = find_box(box_name)

      unless box.exists?
        log "Box #{box.name} doesn't exists, therefore cannot be destroyed."
        exit(1)
      end

      unless box.ready?
        log "Box #{box.name} is not fully provisioned, therefore cannot be destroyed."
        exit(1)
      end

      box.destroy!

      if wait { !box.ready? }
        log "#{box.name} destroyed."
      else
        log "taking more than 60 seconds, exiting."
        exit(1)
      end
    end
  end

  # private

  def find_box(box_name)
    box = Cloud::Boxes.find(box_name)
    if box
      return box
    else
      log "Couldn't find the box #{box_name}"
      exit(1)
    end
  end
end
