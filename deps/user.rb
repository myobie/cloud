class UserDep < Cloud::Dep
  deps :passworded_user, :admin_group_can_sudo
end

class PasswordlessUserDep < Cloud::Dep
  exec as_root: true

  deps :admin_group

  def username
    config['user']
  end

  def met?
    exec('/etc/passwd') =~ /^#{username}:/
  end

  def home_dir_base
    "/home/#{username}"
  end

  def meet
    exec "mkdir -p #{home_dir_base}",
         "useradd -m -s /bin/bash -b #{home_dir_base} -G admin #{username}",
         "chmod 701 #{home_dir_base / username}"
  end
end

class PasswordedUserDep < Cloud::Dep
  exec as_root: true

  deps :passwordless_user

  def met?
    exec('cat /etc/shadow') =~ /^#{username}:[^\*!]/
  end

  def meet
    password = SecureRandom.urlsafe_base64(64)
    puts "New passowrd for #{username} is: #{password}"
    exec %{echo "#{password}\n#{password}" | passwd #{username}}
  end
end

class AdminGroupDep < Cloud::Dep
  exec as_root: true

  def met?
    exec('/etc/group') =~ /^admin\:/
  end

  def meet
    exec 'groupadd admin'
  end
end

class AdminGroupCanSudoDep < Cloud::Dep
  exec as_root: true

  deps :admin_group

  def met?
    exec('/etc/sudoers') =~ /^%admin\b/
  end

  def meet
    exec %{echo "%admin  ALL=(ALL) ALL\n" >> /etc/sudoers}
  end
end
