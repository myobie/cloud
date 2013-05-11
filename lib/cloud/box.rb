require 'cloud/boxes'
require 'cloud/roles'
require 'cloud/configurable'
require 'cloud/rendering'

class Cloud::Box
  include Cloud::Configurable
  include Cloud::Rendering

  attr_accessor :name, :opts, :memory, :ip, :image, :region, :user

  def self.create(name, opts = {})
    box = new(name, opts)
    Cloud::Boxes.all << box
    box
  end

  def self.roles(*role_names)
    @role_names = Array(role_names)
    unless @role_names.empty?
      @roles = @role_names.map do |name|
        Cloud::Roles.find(name)
      end
    end
    @roles
  end

  def roles
    @roles ||= self.class.roles.reduce({}) do |memo, role|
      memo[role.name] = role.new(self)
      memo
    end
  end

  def dep_graph
    roles.map do |name, role|
      { "role:#{name}" => role.dep_graph }
    end
  end

  def self.memory(mem = nil)
    unless mem.nil?
      @mem = mem
    end
    @mem
  end

  def self.region(reg = nil)
    unless reg.nil?
      @region = region
    end
    @region
  end

  def self.image(img = nil)
    unless img.nil?
      @image = img
    end
    @image
  end

  def self.user(u = nil)
    unless u.nil?
      @user = u
    end
    @user
  end

  def self.parse_opts(*opt_names)
    opt_names = Array(opt_names)
    attr_accessor(*opt_names)
    define_method :parse_opts! do
      super()
      opt_names.each do |opt_name|
        instance_variable_set(:"@#{opt_name}", config.fetch(opt_name.to_s))
      end
    end
  end

  def initialize(name, opts = {})
    @name = name
    @config = self.class.config.deep_merge(opts.stringify)
    parse_opts!
  end

  def backups?
    !!@backups
  end

  def provider
    @provider ||= Cloud.provider
  end

  def exists?
    provider.exists?(self)
  end

  def ready?
    provider.ready?(self)
  end

  def info
    provider.info(self)
  end

  def exec(*commands, as_root: false)
    provider.exec(self, *commands, as_root: as_root)
  end

  def exec_and_log(*commands, as_root: false)
    Cloud.inc_p
    commands.each do |command|
      Cloud.p "> #{command}"
    end
    Cloud.dec_p

    exec(*commands, as_root: as_root)
  end
  alias el exec_and_log

  def destroy!
    provider.destroy(self)
  end

  def provision!
    provider.provision(self)
  end

  def roles_met?
    if roles.empty?
      true
    else
      roles.map do |role_name, role|
        role.check!
      end.all?
    end
  end

  def must_exist_and_be_ready!
    unless exists?
      Cloud.dec_p
      Cloud.p "} failed because the box doesn't exist."
      return false
    end

    unless ready?
      box_status = info['status']
      Cloud.p "status: #{box_status}" if box_status

      Cloud.dec_p
      Cloud.p "} failed because the box is not ready to accept ssh commands."
      return false
    end

    return true
  end

  def check!
    Cloud.p "Checking box #{name} {"
    Cloud.inc_p

    unless must_exist_and_be_ready!
      return false
    end

    unless roles_met?
      Cloud.dec_p
      Cloud.p "} failed."
      return false
    end

    Cloud.dec_p
    Cloud.p "} met."
    true
  rescue StandardError => e
    Cloud.p "} failed, because of #{e}."
    Cloud.p "exiting..."
    exit 1
  end

  def make!
    Cloud.p "Box #{name} {"
    Cloud.inc_p

    unless must_exist_and_be_ready!
      return false
    end

    m = roles.map do |name, role|
      role.make!
    end.all?

    Cloud.dec_p

    if m
      Cloud.p "} met."
      return true
    else
      Cloud.p "} failed."
      return false
    end
  rescue StandardError => e
    Cloud.p "} failed, because of #{e}."
    Cloud.p "exiting..."
    exit 1
  end

  private

  def parse_opts!
    @memory = config['memory'] || self.class.memory
    @image = config['image'] || self.class.image
    @region = config['region'] || self.class.region
    @user = config['user'] || self.class.user
    @ip = config['ip']
    @backups = !!config['backups']
    @provider = config['provider']
  end
end
