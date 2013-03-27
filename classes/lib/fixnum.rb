class Fixnum

  def week
    self * (7.days)
  end
  alias :weeks :week

  def day
    self * (86400)
  end
  alias :days :day

  def minute
    self * 60
  end
  alias :minutes :minute

  def day_ago
    Time.now - self.days
  end
  alias :days_ago :day_ago

  def hour
    self * 60.minutes
  end
  alias :hours :hour

  def month_name(format = :long)
    raise ArgumentError, 'Must be between 1 and 12' if self > 12 || self < 1
    long_names = %W{January February March April May June July August September October November December}
    long_names.insert(0, nil)
    short_names = %W{Jan Feb Mar Apr May June July Aug Sep Oct Nov Dec}
    short_names.insert(0, nil)

    if format == :long
      long_names[self]
    elsif format == :short
      short_names[self]
    else 
      raise ArgumentError, "Invalid 'format' parameter. Must be either :long or :short"
    end
        
  end
end