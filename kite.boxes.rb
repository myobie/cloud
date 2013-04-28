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
    render file: "./templates/redis.conf.erb"
  end
  
  with_config_scope('redis') do
    use :daemonize
    use :port, default: 6379
    use :pidfile, default: "/var/run/redis.pid"
    use :bind, query: :should_bind?, value: :bind_address, default: "127.0.0.1"
    use :unixsocket, default: "/tmp/redis.sock"
    use :unixsocketperm, default: 755
    use :timeout, default: 0
    use :tcp_keepalive, default: 0
    use :loglevel, default: "notice"
    use :logfile, default: "stdout"
    use :syslog_enabled
    use :syslog_ident, default: "redis"
    use :syslog_facility, default: "local0"
    use :databases, default: 16
    use :save_points, default: []
    use :stop_writes_on_bgsave_error, default: true
    use :rdbcompression, default: true
    use :rdbchecksum, default: true
    use :dbfilename, default: 'dump.rdb'
    use :dir, default: './'
    use :password
    use :rename_commands, default: []
    use :maxclients
    use :maxmemory
    use :maxmemory_policy, default: "volatile-lru"
    use :maxmemory_samples
    use :aof, default: false
    use :appendfilename, default: "appendonly.aof"
    use :appendfsync, default: "everysec"
    use :no_appendfsync_on_rewrite, default: false
    use :auto_aof_rewrite_percentage, default: 100
    use :auto_aof_rewrite_min_size, default: "64mb"
    use :lua_time_limit, default: 5_000
    use :slowlog_log_slower_than, default: 10_000
    use :slowlog_max_len, default: 128
  end

  def default_save_points
    [{
      'seconds' => 900, 'keys' => 1
    }, {
      'seconds' => 300, 'keys' => 10
    }, {
      'seconds' => 60, 'keys' => 10_000
    }]
  end

  def following?
    false
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
