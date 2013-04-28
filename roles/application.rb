class ApplicationRole < Cloud::Role
  name :application
  deps 'myobie.nginx', 'myobie.nginx.unicorn', 'myobie.rails',
       'myobie.rails.git', 'myobie.rails.unicorn'
end