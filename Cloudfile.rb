$: << __dir__
$: << File.expand_path("./lib")

require 'cloud'

require 'roles/redis'
require 'roles/application'

require 'boxes/database'
require 'boxes/slave_database'
require 'boxes/redis'
require 'boxes/slave_redis'
require 'boxes/memcached'
require 'boxes/application'
require 'boxes/load_balancer'
require 'boxes/resque'

require 'providers/digital_ocean'

Cloud.provider = DigitalOcean::Provider.new Cloud.config['provider']

red1 = RedisBox.create "red1", redis: { databases: 4 }

puts "red1 ruby object: #{red1.inspect}"
puts "red1 exists? #{Cloud.provider.exists?(red1).inspect}"
if Cloud.provider.exists?(red1)
  puts "red1 info: #{Cloud.provider.info(red1).inspect}"
  if Cloud.provider.ready?(red1)
    puts "red1 exec: ls / =>"
    puts Cloud.provider.exec(red1, "ls /").split("\n").inspect
  else
    puts "red1 is not ready to accept ssh commands yet"
  end
else
  puts "Provisioning red1..."
  puts Cloud.provider.provision(red1).inspect
end

if ARGV.include?("destroy")
  puts "Destroying red1..."
  if Cloud.provider.ready?(red1)
    success = Cloud.provider.destroy(red1)
    puts "success? #{success.inspect}"
  else
    puts "red1 is not active, so it cannot be destroyed yet"
  end
end





# db1 = Database.create "db1"
# db2 = SlaveDatabase.create "db2", follow: db1, failover: true
# 
# red1 = Redis.create "red1", redis: { databases: 4 }
# red2 = SlaveRedis.create "red2", follow: red1, failover: true
# 
# mem1 = Memcached.create "mem1"
# 
# app_config = {
#   memcached: mem1,
#   database: {
#     master: db1,
#     slave: db2
#   },
#   redis: {
#     master: red1,
#     slave: red2
#   },
#   git_url: "git://github.com/myobie/something.git"
# }
# 
# app1 = Application.create "app1", app_config
# app2 = Application.create "app2", app_config
# 
# apps = [app1, app2]
# 
# LoadBalancer.create "lb1", ip: Cloud.config['external_ips'][0], balance: apps
# LoadBalancer.create "lb2", ip: Cloud.config['external_ips'][1], balance: apps
# 
# Resque.create "job1", redis: red1, database: { master: db1, slave: db2 }



# puts Cloud.boxes.inspect
# puts "*"*80
# puts red1.roles[:redis].config_file
