module Cloud::Box::ProviderApi
  def provider
    @provider ||= Cloud.provider
  end

  def exists?
    provider.exists?(self)
  end

  def ready?
    provider.ready?(self)
  end

  def info
    provider.info(self)
  end

  def exec(*commands, as_root: false)
    provider.exec(self, *commands, as_root: as_root)
  end

  def exec_and_log(*commands, as_root: false)
    log do
      commands.each do |command|
        log "> #{command}"
      end
    end

    exec(*commands, as_root: as_root)
  end
  alias el exec_and_log

  def destroy!
    provider.destroy(self)
  end

  def provision!
    provider.provision(self)
  end
end