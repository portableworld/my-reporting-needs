require_relative 'Database'
require_relative 'oracle_settings'

class CmiDW < Database

	def initialize(*args) 
		# Build connection string
    	settings = OracleSettings.new
		connection_string = "Provider=MSDASQL.1;Password=#{settings.password};"
		connection_string += "Persist Security Info=True;User ID=#{settings.username};"
		connection_string += "Extended Properties=\"DSN=#{settings.dsn};"
		connection_string += "UID=#{settings.username};PWD=#{settings.password};SERVER=#{settings.server};\""
		super(connection_string)
	end

end
