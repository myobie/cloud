class LoadBalancer < Cloud::Box
  memory "512MB"
  # deps 'myobie.nginx', 'myobie.nginx.assets', 'myobie.haproxy', 'myobie.rails'
  parse_opts :balance
  config { Cloud.config['load_balancer'] }
end