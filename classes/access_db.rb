require_relative 'Database'
require_relative 'mixins/database_paths'
include DatabasePaths # This file contains proprietary information

class AccessDB < Database
  attr_accessor :mdb

  def initialize(mdb = DatabasePaths::DEFAULT)
    @mdb = mdb
    connection_string  = 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source='
    connection_string += @mdb
    super(connection_string)
  end

  def mdb=(mdb)
    @mdb = mdb
    @conn_string = 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + @mdb
  end

  def password=(password)
    @password = password # Write only password variable
    # TODO - Rebuild connection string in case password has already been appended
    @conn_string += ";Jet OLEDB:Database Password=#{@password}"
  end

  def reset_password(new_password)
    # Reset password for all linked tables
    # TODO - implement reset_password
  end
  
end
