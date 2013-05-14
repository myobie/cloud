require 'securerandom'

class UserDep < Cloud::Dep
  deps :passworded_user, :admin_group_can_sudo
end

class PasswordlessUserDep < Cloud::Dep
  deps :admin_group

  def username
    Cloud.config['user']
  end

  def met?
    as_root do
      exec('cat /etc/passwd') =~ /^#{username}:/
    end
  end

  def meet
    as_root do
      exec "useradd -m -s /bin/bash -b /home -G admin #{username}",
           "chmod 701 /home/#{username}"
    end
  end
end

class PasswordedUserDep < Cloud::Dep
  deps :passwordless_user

  def username
    Cloud.config['user']
  end

  def met?
    as_root do
      exec('cat /etc/shadow') =~ /^#{username}:[^\*!]/
    end
  end

  def meet
    password = SecureRandom.urlsafe_base64(32)
    log "-> New passowrd for #{username} is: #{password}"
    as_root do
      exec %{echo "#{username}:#{password}" | chpasswd}
    end
  end
end

class AdminGroupDep < Cloud::Dep
  def met?
    as_root do
      exec('cat /etc/group') =~ /^admin\:/
    end
  end

  def meet
    as_root do
      exec 'groupadd admin'
    end
  end
end

class AdminGroupCanSudoDep < Cloud::Dep
  deps :admin_group

  def met?
    as_root do
      exec('cat /etc/sudoers') =~ /^%admin\b/
    end
  end

  def meet
    as_root do
      exec %{echo "%admin  ALL=(ALL) ALL\n" >> /etc/sudoers}
    end
  end
end
