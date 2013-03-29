require 'win32ole'
require_relative 'active_support'
require_relative 'Module'


class Excel
  attr_accessor :xl, :wb, :ws, :filepath

  delegate :range, to: :ws
  delegate :visible=, to: :xl

  DOWN    = -4121
  TOLEFT  = -4159
  TORIGHT = -4161
  UP      = -4162

  SHEET_HIDDEN      =  0
  SHEET_VERY_HIDDEN =  2
  SHEET_VISIBLE	  = -1

  def initialize(filepath, password = nil)
    begin
      @xl = WIN32OLE.new('Excel.Application')
    rescue WIN32OLERuntimeError => e
      if /failed to create WIN32OLE object from 'Excel.Application'/.match(e.message)
        puts 'Failed to create Excel.Application. Will try again in 5 minutes...'
        sleep(5.minutes)
        retry
      end
      raise
    end
    @filepath = filepath
    puts "Opening #@filepath..."
    if password.nil?
      @wb = @xl.workbooks.open(@filepath)
    else
      @wb = @xl.workbooks.open(@filepath, false, false, nil, password, password)
    end
    sheet(1)
  end

  class << self
    alias :open :new
  end


  def sheet(sheet_name)
    @ws = @wb.worksheets(sheet_name)
    if [SHEET_HIDDEN, SHEET_VERY_HIDDEN].include? @ws.visible
      warn "Sheet #{sheet_name} is hidden. Cannot select it."
    else
      @ws.select
    end

    self
  end

  def hide(sheet_name)
    puts "Hiding sheet '#{sheet_name}'..."
    sheet_name = @ws.name if sheet_name == :current
    @wb.worksheets(sheet_name).visible = SHEET_HIDDEN
  end

  def unhide(sheet_name)
    puts "Unhiding sheet #{sheet_name}..."
    @wb.worksheets(sheet_name).visible = SHEET_VISIBLE
    sheet(sheet_name)
  end

  def clear_sheet(start_cell = 'A2', end_column = nil)
    if end_column.nil?
      end_column = @ws.range('A1').end(TORIGHT).address
      end_cell   = @ws.range(start_cell).end(DOWN).address
      @ws.range("#{start_cell}:$#{end_column.split('$')[1]}$#{end_cell.split('$')[2]}").clear
    elsif end_column.match(/[\d]/).nil?
      end_cell   = @ws.range(start_cell).end(DOWN).address
      @ws.range("#{start_cell}:$#{end_column}$#{end_cell.split('$')[2]}").clear
    else
      @ws.range("#{start_cell}:#{end_column}").clear
    end

    self
  end

  def get_value(cell)
    @ws.range(cell).value
  end
  alias :get_value_at :get_value

  def insert_data(data, start_cell)
    puts 'Inserting Data...'
    # This assumes that +data+ is of type +QueryData+
    # TODO - Should not assume
    data.each_row_with_index do |row, row_index|
      if row.is_a? Array
        row.each_with_index do |item, column_index|
          @ws.range(start_cell).offset(row_index, column_index).value = item
        end
      elsif row.is_a? Hash
        raise ArgumentError, 'Data should never be a Hash!'
      end #end if
    end # end each_with_index
  end # end method

  # TODO - Refactor string parameter +direction+ into a symbol
  def insert_array(data, start_cell, direction = 'right')
    direction = get_direction(direction)
    row_offset = 0
    col_offset = 0

    data.each do |val|
      @ws.range(start_cell).offset(row_offset, col_offset).value = val
      case direction
        when DOWN
          row_offset +=  1
        when UP
          row_offset += -1
        when TORIGHT
          col_offset +=  1
        when TOLEFT
          col_offset += -1
      end
    end
  end

  def update_named_ranges
    puts 'Updating Named Ranges...'
    @wb.names.each do |r|
      location = r.refersto.split('!') # ["='Sheet Name'", "$Col$Row:$Col$Row"]
      if location[0].include? '\''
        sheet_name = location[0].split('\'')[1]
      else
        sheet_name = location[0][1..-1] # removes '='
      end
      column = @wb.worksheets(sheet_name).range('A1').end(TORIGHT).address
      end_cell = @wb.worksheets(sheet_name).range('A1').end(DOWN).address
      r.refersto = location[0] + "!$A$1:$#{column.split('$')[1]}$#{end_cell.split('$')[2]}"
    end

    self
  end


  def all_values_from(from, direction)
    direction = get_direction(direction)
    if @ws.range(from).offset(1,0).value.nil?
      to = from
    else
      to = @ws.range(from).end(direction).address
    end
    r = @ws.range("#{from}:#{to}")
    if block_given?
      values = r.to_enum.collect {|cell| yield cell}
    else
      values = r.to_enum.collect {|cell| cell.value}
    end

    values
  end

  def get_next_blank_cell(starting_cell, direction)
    puts "Checking for next blank cell in #{direction} direction..."
    return @ws.range(starting_cell) if @ws.range(starting_cell).value.nil?

    direction = get_direction(direction)
    row_offset = 0
    col_offset = 0

    last_cell = @ws.range(starting_cell).end(direction)
    case direction
      when DOWN
        row_offset = 1
      when UP
        row_offset = -1
      when TORIGHT
        col_offset = 1
      when TOLEFT
        col_offset = -1
    end
    # require 'pry'
    # binding.pry
    last_cell.offset(row_offset, col_offset)
  end

  def get_next_blank_cell_address(starting_cell, direction)
    get_next_blank_cell(starting_cell, direction).address.gsub('$', '')
  end

  def refresh_pivot_tables
    puts 'Refreshing Pivot Tables...'
    @wb.sheets.each do |s|
      s.pivottables.each do |pt|
        pt.refreshtable
      end
    end

    self
  end

  def datestamp(cell, sheet_name, date)
    puts "Date stamping report at #{cell}"
    @wb.worksheets(sheet_name).range(cell).value = date
    puts 'Stamped'
  end

  def run_macro(macro)
    puts "Running macro: '#{macro}'..."
    begin
      @xl.run(macro)
      puts 'Macro done'
    rescue WIN32OLERuntimeError => e
      puts e.message
    end

    self
  end

  def save
    puts 'Saving...'
    begin
      @wb.save
    rescue WIN32OLERuntimeError => e
      if /The disk is full./.match(e.message)
        puts 'The drive is reporting that the disk is full.'
        puts 'Sleeping for 5 minutes and trying again.'
        sleep(5.minutes)
        retry
      end
    end
    puts 'Saved'

    self
  end

  def save_as(new_filename)
    if @filepath == new_filename
      save
      return self
    end
    puts "Saving #{new_filename}..."
    begin
      @wb.saveas(new_filename)
    rescue WIN32OLERuntimeError => e
      if /The disk is full./.match(e.message)
        puts 'The drive is reporting that the disk is full.'
        puts 'Sleeping for 5 minutes and trying again.'
        sleep(5.minutes)
        retry
      end
    end
    puts 'Saved'
    @filepath = new_filename
    self
  end
  alias :saveas :save_as


  def close
    # TODO - Catch if need to be saved first
    @wb.close
    @xl.quit

    self
  end


  protected


  def get_range_direction(from, to)
    return DOWN         if from[0] < to[0]
    return UP           if from[0] > to[0]
    return TORIGHT      if from[1..-1] < to[1..-1]
    TOLEFT
  end

  def get_direction(direction)
    direction = direction.downcase.to_sym if direction.respond_to? :downcase
    return DOWN         if direction.downcase == :down
    return UP           if direction.downcase == :up
    return TORIGHT      if direction.downcase == :right
    return TOLEFT       if direction.downcase == :left
    raise ArgumentError, 'direction should be either :left, :right, :up, or :down'
  end
end
