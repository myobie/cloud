class SlaveRedis < Redis
  parse_opts :follow, :failover
  config { Cloud.config['slave_redis'] }
end