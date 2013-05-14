module Cloud::Box::Make

  def make!
    m = nil

    log "Box #{name} {" do
      unless must_exist_and_be_ready!
        return false
      end

      m = roles.map do |name, role|
        role.make!
      end.all?
    end

    if m
      log "} met."
      return true
    else
      log "} failed."
      return false
    end
  rescue StandardError => e
    log "} failed, because of #{e}."
    log "exiting..."
    exit 1
  end

end