class SlaveRedisBox < RedisBox
  parse_opts :follow, :failover
  config { Cloud.config['slave_redis'] }
end
