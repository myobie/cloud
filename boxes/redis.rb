class RedisBox < Cloud::Box
  memory "1GB"
  config { Cloud.config }
  roles :redis
end
