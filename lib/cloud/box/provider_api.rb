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

  def exec(*commands)
    provider.exec(self, *commands)
  end

  def exec_and_log(*commands)
    log do
      commands.each do |command|
        log "> #{command}"
      end
    end

    exec(*commands)
  end
  alias el exec_and_log

  def destroy!
    provider.destroy(self)
  end

  def provision!
    provider.provision(self)
  end
end