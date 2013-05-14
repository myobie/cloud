module Cloud::Box::Check
  def roles_met?
    if roles.empty?
      true
    else
      roles.map do |role_name, role|
        role.check!
      end.all?
    end
  end

  def must_exist_and_be_ready!
    unless exists?
      outdent_logging
      log "} failed because the box doesn't exist."
      return false
    end

    unless ready?
      box_status = info['status']
      log "status: #{box_status}" if box_status

      outdent_logging
      log "} failed because the box is not ready to accept ssh commands."
      return false
    end

    return true
  end

  def check!
    log "Checking box #{name} {" do
      unless must_exist_and_be_ready!
        return false
      end

      unless roles_met?
        outdent_logging
        log "} failed."
        return false
      end
    end

    log "} met."
    true
  rescue StandardError => e
    log "} failed, because of #{e}."
    log "exiting..."
    exit 1
  end
end