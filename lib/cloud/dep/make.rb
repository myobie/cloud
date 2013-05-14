module Cloud::Dep::Make
  def make!
    success = log "Dep #{name} {" do
      if deps.empty?
        true
      else
        deps.map do |dep|
          dep.make!
        end.all?
      end
    end

    unless success
      log "} failed because of nested failure."
      return false
    end

    if met?
      log "} met."
      return true
    end

    meet_output = []

    rescuer do
      log "-> meeting..."
      meet_output = meet
    end

    if met?
      log "} met."
      return true
    else
      log "} failed, couldn't meet."
      log ">> \n#{meet_output.join("\n")}\n<<" if $global_opts[:trace]
      return false
    end
  end
end