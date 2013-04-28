class Redis < Cloud::Box
  memory "1GB"
  config { Cloud.config['redis'] }
  roles :redis
end