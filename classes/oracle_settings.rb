require 'yaml'

class OracleSettings
  attr_reader :username, :password, :server, :dsn

  def initialize
    # TODO - Refactor this when I switch to Ruby 2.0
    settings  = Hash[YAML.load_file(File.join(File.dirname(__FILE__), '..', 'properties', 'oracle_settings.yaml'))]
    @username = settings['username']
    @password = settings['password']
    @server   = settings['server']
    @dsn      = settings['dsn']
  end
end