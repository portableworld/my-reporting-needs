require_relative 'Module' # Uses delegate method from Rails

class QueryData
  include Enumerable

  attr_accessor :fields, :data

  delegate :size, :length, :count, to: :data

  def initialize
    @fields = Array.new
    @data   = Array.new
  end

  def [](index)
    if index.is_a? Fixnum
      @data[index]
    elsif index.is_a? Symbol
      col = index_of_field(index)
      @data.collect {|arr| arr[col]}
    end
  end
  alias :at :[]

  def each_row
    @data.each {|row| yield row, @fields }
  end
  alias :each_line :each_row
  alias :each :each_row

  def each_row_with_index
    @data.each_with_index {|row, index| yield row, index }
  end
  alias :each_line_with_index :each_row_with_index

  def clear
    @fields.clear
    @data.clear
  end

  def at_with_field(index, sym)
    row = at(index)
    row[index_of_field(sym)]
  end

  def field(sym)
    index_of_field(sym.to_sym)
  end
  alias :get_index_of_field :field

  def set_fields(record_set)
    @fields.clear
    if record_set.is_a? WIN32OLE
      record_set.movefirst unless record_set.bof
      record_set.fields.each { |f|
        @fields << f.name.downcase.to_sym
      }
    else
      @fields = record_set || []
    end
    #(class << self; self; end).class_eval do
    #  @fields.each do |field|
    #    define_method(field) {self.send(:[], field)}
    #  end
    #end
  end
  alias :set_fields_from :set_fields

  def fields=(record_set)
    set_fields(record_set)
  end

  # TODO - Class knows too much about WIN32OLE and recordsets. Refactor
  def set_data(record_set)
    @data.clear
    if record_set.is_a? WIN32OLE
      record_set.movefirst unless record_set.bof
      until record_set.eof
        row = Array.new
        record_set.fields.each do |f|
          row << f.value
        end
        @data << row
        record_set.movenext
      end
    else
      @data = record_set
    end
    @data
  end
  alias :set_data_from :set_data

  def data=(record_set)
    set_data(record_set)
  end

  def method_missing(sym, *args, &block)
    if @fields.include? sym
      #TODO - This is slow so work on a define_method means inside #set_fields
      return self.send(:[], sym)
    end
    super(sym, *args, &block)
  end

  private

  def index_of_field(field)
    @fields.index(field.to_sym)
  end
end