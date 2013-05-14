module Cloud::Box::Make

  def make!
    if check_exists? && check_ready?
      bootstrap! && sync! && setup_there! && bootup!
    end
  end
  
  def bootstrap!
    m = log "Bootstrap {" do
      deps.map do |dep|
        dep.make!
      end.all?
    end

    if m
      log "} done."
      return true
    else
      log "} bootstrap failed."
      return false
    end
  end

  def sync!
    log "Sync step not ready yet, skipping"
    true
  end

  def setup_there!
    log "Setup step not ready yet, skipping"
    true
  end

  def setup_here!
    m = log "Setup {" do
      roles.map do |role|
        role.make!
      end.all?
    end

    if m
      log "} done."
      return true
    else
      log "} setup failed."
      return false
    end
  end

  def bootup!
    log "Bootup step not ready yet, skipping"
    true
  end

end