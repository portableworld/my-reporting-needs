=begin
Example:
  timer = ResultDocumenter.new('Report Name', rundate)
  timer.start!
  db.query(sql)
  result_count
  timer.stop!
  timer.count = db.data.count
  timer.save!
=end

require_relative 'Excel'

class ResultDocumenter
	attr_reader :report_name, :start_time, :end_time, :date_ran, :for_date_range
  attr_accessor :count

	def initialize(report_name, date_range)
		@report_name = report_name
    @for_date_range = date_range
    @date_ran = Time.now.strftime('%m/%d/%Y')
  end

  def start!
    @start_time = Time.now
  end

  def stop!
    @end_time = Time.now
  end

  def reset
    @end_time   = nil
    @start_time = nil
    @count      = 0
  end

  def elapsed_minutes
    ((@end_time - @start_time)/60).ceil
  end

  def elapsed_hours
    (elapsed_minutes/60).ceil
  end

  def save!
    begin
      raise ArgumentError, 'Not all values are valid. Please revise.' unless all_valid?
      puts 'Documenting Report Statistics...'
      save_to_excel
      save_to_mysql
      puts 'Completed documenting Report Statistics'
    rescue WIN32OLERuntimeError => e
      puts 'There appears to be a problem with the Excel file.'
      puts e.message
      puts e.backtrace
      print 'Would you like me to drop you into debug mode?[y/n]: '
      if gets.chomp == 'y'
        require 'pry'
        binding.pry
      end
      retry
    rescue Exception => e
      puts 'An Exception has occured while trying to document time and count'
      puts e.message
      puts 'Continuing without documenting...'
    end
	end

  private

  def all_valid?
    @report_name && @report_name.length > 0 &&
        @start_time && @end_time &&
        @start_time < @end_time &&
        @count
  end

  def save_to_excel
    # Find Excel file based on @report_name
    begin
      stats_folder = File.join('path', 'to', 'statistics', 'folder')
    rescue WIN32OLERuntimeError => e # TODO - I think this was moved to the Excel class. Check and remove
        if e.message =~ /failed to create WIN32OLE object/
          puts 'Failed to create Excel.Application object'
          puts 'The Statistics Template is probably already in use'
          puts 'Sleeping for 5 minutes and then will try again'
          sleep(5.minutes)
          retry
        else
          raise
        end
    end
    # TODO - The Excel class should be the one that creates a new file if it doesn't exist
    if File.exists?(File.join(stats_folder, "Stats for #{@report_name}.xls"))
      # Open Excel file
      xl = Excel.new(File.join(stats_folder, "Stats for #{@report_name}.xls"))
    else
      # Create Excel file
      template = File.join(stats_folder, 'template.xls')
      xl = Excel.new(template)
      xl.save_as(File.join(stats_folder, "Stats for #{@report_name}.xls"))
    end
    xl.sheet('Data')
    # Find next insertion point
    next_blank_cell = xl.get_next_blank_cell_address('A2', :down)
    xl.insert_array([@date_ran, date_range, @count, elapsed_minutes, elapsed_hours], next_blank_cell)

    xl.save
    xl.close
  end

  def save_to_mysql
    warn %q{ResultDocumenter#save_to_mysql is not yet implemented}
  end

  def date_range
    return @date_ran.to_s if @for_date_range.nil?
    if @for_date_range.size == 1 || @for_date_range.is_a?(String)
      @for_date_range.to_s
    elsif @for_date_range.first == @for_date_range.last
      @for_date_range.first.to_s
    else
      @for_date_range.join(' to ')
    end
  end
end