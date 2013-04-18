class LoadBalancer < Box
  memory "512MB"
  deps 'myobie.nginx', 'myobie.nginx.assets', 'myobie.haproxy', 'myobie.rails'
  parse_opts :balance
  config { Kite.config['load_balancer'] }
end

class Application < Box
  memory "1GB"
  deps 'myobie.nginx', 'myobie.nginx.unicorn', 'myobie.rails',
       'myobie.rails.git', 'myobie.rails.unicorn'
  parse_opts :git_url
  config { Kite.config['application'] }
end

class Database < Box
  memory "1GB"
  deps 'myobie.postgres'
end

class SlaveDatabase < Database
  parse_opts :follow, :failover
end

class Redis < Box
  memory "1GB"
  deps 'myobie.redis'
  config { Kite.config['redis'] }
  
  def config_file
    @databases = 16
    render text: <<-EOF
some file things
databases <%= @databases %>
more file things
    EOF
  end
end

class SlaveRedis < Redis
  parse_opts :follow, :failover
  config { Kite.config['slave_redis'] }
end

class Memcached < Box
  memory "1GB"
  deps 'myobie.memcached'
end

class Resque < Box
  memory "1GB"
  deps 'myobie.resque'
end