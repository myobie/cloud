module Cloud::Role::Check
  def check!
    success = log "Checking role #{name} {" do
      deps_check?
    end

    if success
      log "} met."
      return true
    else
      log "} failed."
      return false
    end
  end
end