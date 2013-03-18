require 'win32ole'
require_relative 'active_support'
require_relative 'data'

class Database
	attr_accessor :conn_string, :connection, :data

  def initialize(conn_string)
		@conn_string = conn_string
		@connection = nil
    @data = QueryData.new
    @sql = nil
	end

	def query(sql, *args)
    open if @connection.nil?
		recordset = WIN32OLE.new('ADODB.Recordset')
    recordset.Open(sql, @connection)
    begin
      @data.set_fields(recordset)
      @data.set_data(recordset)
      recordset.close
    rescue Exception => e
      puts "Encountered Exception: #{e.class}"
      puts
      puts e.message
      puts
      @data.clear
    end

    @data
  end

  def open
    begin
      @connection = WIN32OLE.new('ADODB.Connection')
      @connection.open(@conn_string)
    rescue WIN32OLERuntimeError => e
      puts
      if /RESTRICTED SESSION/.match(e.message)
        puts '(ORA-01035) Oracle Datawarehouse is in Restricted Session mode.'
      elsif /TNS:connection closed/.match(e.message)
        puts '(ORA-12537) TNS - Connection Closed'
      else
        puts e.message
        puts 'Sleeping for 15 minutes...'
      end
      
      puts "Will try again at #{(Time.now + 15.minutes).strftime('%r')}...\n"
      sleep(15.minutes)
      retry
    end
    @connection
	end

  def execute(sql)
		@connection.Execute(sql)
	end

	def close
		@connection.Close
  end


  def method_missing(sym, *args, &block)
    if @fields.include? sym.to_s
      return @data[@fields.index(sym.to_s)]
    elsif sym.to_s == 'any_field'
      return @data[0]
    end

    super(sym, *args, &block)
  end







   ######
  # Do not use this method anymore! 
  # The Inventory report is the only one left that still uses this method
  def query_as_hash(sql, *args)
    warn 'Database#query_as_hash is decrepted. Please refactor to Database#query.'

    recordset = WIN32OLE.new('ADODB.Recordset')
    recordset.open(sql, @connection)
    begin
      set_fields(recordset)
    rescue Exception
      puts 'Exception occurred while retrieving Recordset Fields'
      @fields = {}
    end
    recordset.movefirst unless recordset.bof
    begin
      @data = []
      results = {}
      until recordset.eof do
        for f in recordset.fields do
          results[f.name.downcase.to_sym] = f.value
        end
        @data << results
        results = Hash.new
        recordset.movenext
      end
    rescue Exception
      puts 'Error occurred while populating Data with query results'
    end

    @data
  end

end