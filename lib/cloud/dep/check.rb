module Cloud::Dep::Check
  def deps_check?
    if deps.empty?
      true
    else
      deps.map do |dep|
        dep.check!
      end.all?
    end
  end

  def check!
    success = log "Checking dep #{name} {" do
      deps_check? && met?
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