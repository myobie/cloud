module Cloud::Role::Make
  def make!
    success = log "Role #{name} {" do
      deps.map do |dep|
        dep.make!
      end.all?
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