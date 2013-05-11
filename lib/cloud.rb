require 'yaml'
require 'timeout'

$global_opts ||= {}

module Cloud
  def self.provider
    @provider
  end

  def self.provider=(p)
    @provider = p
  end

  def self.config
    return @config if defined?(@config)

    file = "./cloud.config.yml"

    @config = if File.exists?(file)
      YAML::load_file(file)
    end
  end

  def self.wait(num, &blk)
    Timeout.timeout(num, &blk)
    true
  rescue Timeout::Error
    false
  end

  def self.p(message)
    spaces = "  "*p_indent
    puts "** #{spaces}#{message}"
  end

  def self.inc_p
    @p_indent = p_indent + p_inc_amount
  end

  def self.dec_p
    @p_indent = p_indent - p_inc_amount
  end

  def self.p_indent
    @p_indent ||= 0
  end

  def self.p_inc_amount
    2
  end
end

require 'cloud/dep'
require 'cloud/role'
require 'cloud/box'
