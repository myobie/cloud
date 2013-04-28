class Application < Cloud::Box
  memory "1GB"
  parse_opts :git_url
  config { Cloud.config['application'] }
  roles :application
end