module Cloud::Box::Check
  def roles_check_there?
    log "Roles: can't check roles over there until sync works"
    true
  end

  def roles_check_here?
    if roles.empty?
      true
    else
      roles.map do |role|
        role.check!
      end.all?
    end
  end

  def check_exists?
    if exists?
      return true
    else
      log "doesn't exist"
      return false
    end
  end
  
  def check_ready?
    if ready?
      return true
    else
      box_status = info['status']
      log "status: #{box_status}" if box_status
      log "not ready to accept ssh commands"
      return false
    end
  end

  def check!
    success = log "Checking box #{name} {" do
      check_exists? && check_ready? && deps_check? && roles_check_there?
    end
    
    if success
      log "}"
      return true
    else
      log "} failed."
      return false
    end
  end
end