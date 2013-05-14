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
    exec('cat /etc/passwd') =~ /^#{username}:/
  end

  def home
    "/home"
  end

  def meet
    exec "useradd -m -s /bin/bash -b /home -G admin #{username}",
         "chmod 701 /home/#{username}"
  end
end

class PasswordedUserDep < Cloud::Dep
  deps :passwordless_user

  def username
    Cloud.config['user']
  end

  def met?
    exec('cat /etc/shadow') =~ /^#{username}:[^\*!]/
  end

  def meet
    password = SecureRandom.urlsafe_base64(32)
    log "-> New passowrd for #{username} is: #{password}"
    exec %{echo "#{username}:#{password}" | chpasswd}
  end
end

class AdminGroupDep < Cloud::Dep
  def met?
    exec('cat /etc/group') =~ /^admin\:/
  end

  def meet
    exec 'groupadd admin'
  end
end

class AdminGroupCanSudoDep < Cloud::Dep
  deps :admin_group

  def met?
    exec('cat /etc/sudoers') =~ /^%admin\b/
  end

  def meet
    exec %{echo "%admin  ALL=(ALL) ALL\n" >> /etc/sudoers}
  end
end
