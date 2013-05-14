class RedisBox < Cloud::Box
  memory "1GB"
  config { Cloud.config["redis"] }
  bootstrap_with :user
  roles :redis
end
