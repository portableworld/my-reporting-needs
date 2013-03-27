class Time


  YEAR = Time.now.year
  COMMON_YEAR_DAYS_IN_MONTH = [nil, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  # TODO Needs to have options for including Saturday as a business day (for overtime purposes)

  def last_business_day
    if self.monday? && (self - 3.days).holiday?
      self - 4.days
    elsif self.monday?
      self - 3.days
    elsif self.tuesday? && self.monday_was_holiday?
      self - 4.days
    elsif self.weekend?
      t = self
      t -= 1.day while t.weekend? || t.holiday?
      t
    elsif (self - 1.day).holiday?
      self - 2.days
    else
      self - 1.day
    end
  end

  def weekend?
    [0, 6].include? self.wday
  end

  def self.last_business_day
    Time.now.last_business_day
  end

  def monday_was_holiday?
    t = self
    t -= 1.day until t.monday?
    t.holiday?
  end

  def self.monday_was_holiday?
    Time.now.monday_was_holiday?
  end

  def holiday?
    Time.holidays(self.year).include? self.yday
  end

  def not_holiday?
    !self.holiday?
  end

  def self.holidays(year)
    # Returns Year Day of holiday
    days = []

    ### New Years Day ###
    days << 1
    
    ### Memorial Day ###
    t = new(year, 5, 31)
    until t.monday?
      t -= 1.day
    end
    days << t.yday

    ### Independence Day ###
    days << new(year, 7, 4).yday 

    ### Labor Day ###
    t = new(year, 9, 1)
    until t.monday?
      t += 1.day
    end
    days << t.yday

    ### Thanksgiving Day ###
    t = new(year, 11, 1)
    until t.thursday?
      t += 1.day
    end
    dst = t.dst?
    t += 3.weeks
    t += 1.day if dst
    days << t.yday 

    ### Christmas Day ###
    days << new(year, 12, 25).yday 
  end

  def yesterday
    self - 1.day
  end

  def self.yesterday
    Time.now.yesterday
  end

  ###
  # Better way of doing this with recursion?
  #
  def business_days_ago(num_of = 1)
      return last_business_day if num_of == 1

      t  = self - (num_of.days)
      if num_of >= self.wday # Passed through a weekend
        t -= 2.days if num_of < 7
        t -= (2 * ((num_of + (self.wday - 1))/5)).days if num_of >= 7
      end

      t = t.last_business_day if t.holiday?
      t
  end

  def self.business_days_ago(num_of = 1)
    Time.now.business_days_ago(num_of)
  end

  def self.last_monday(should_format = false, format = '%m %d %Y')
    t = Time.now - 1.week
    until t.monday?
      t -= 1.day
    end
    if should_format
      return t.strftime(format)
    else
      return t
    end
  end

  def self.this_monday(should_format = false, format = '%m %d %Y')
    t = Time.now
    until t.monday?
      t -= 1.day
    end
    if should_format
      return t.strftime(format)
    else
      return t
    end
  end

  def self.last_week_dates(format = '%m/%d/%Y')
    t = Time.last_monday

    if format.nil?
      [t, (t + 6.days)]
    else
      [t.strftime(format), (t + 6.days).strftime(format)]
    end
  end

  def self.last_month_dates(months_ago = 1)
    t = Time.now
    months_ago.times {t -= (1.day * Time.days_in_month(t.month))}
    [t.beginning_of_month.strftime('%m/%d/%Y'), t.end_of_month.strftime('%m/%d/%Y')]
  end

  def self.days_in_month(month, year = YEAR)
      return 29 if month == 2 && ::Date.gregorian_leap?(year)
      COMMON_YEAR_DAYS_IN_MONTH[month]
  end

  def beginning_of_month
    ::Time.new(year, month, 1)
  end

  def end_of_month
    last_day = ::Time.days_in_month(month, year)
    ::Time.new(year, month, last_day)
  end

  def self.network_hours(t1, t2)
    return 0 if t1.nil? || t2.nil?
    raise ArgumentError, 'Arguments should be of type Time' unless (t1.is_a? Time) && (t2.is_a? Time)

    weekend_days  = 2 * ((t2.yday - t1.yday)/7)
    weekend_days += 2 if t2.wday < t1.wday
    holidays(YEAR).each { |holiday| t1 += 1.day if (t1.yday...t2.yday).include? holiday }

    t = (t2 - (t1 + weekend_days.days))/60/60  # Gives hours
    t += 1 if !t1.dst? &&  t2.dst?
    t -= 1 if  t1.dst? && !t2.dst?
    t  = 0 if  t < 0

    t
  end

  # TODO - This method still doesn't pass all the tests
  def self.week_of_month(offset = 0)
    first_monday = now.first_monday_of_month
    ((first_monday.day - 1) + now.day) / 7 + ((now.friday? && now.day % 7 == 0) ? 0 : 1)
=begin
    return ((now.last_business_day.yday % 7) + now.last_business_day.mday) / 7 + 1

    beginning_of_month = Time.new(YEAR, (Time.now.month), 1)
    bom_padding = beginning_of_month.wday - 1
    bom_padding -= 5 if bom_padding > 4
    day_of_month = now.last_business_day.mday + bom_padding

    return  day_of_month / 7 + 1
    offset = 0 if offset.nil?
    
    now = Time.now - offset.days
    week_of_month = 1

    until beginning_of_month.mday >= now.mday
      beginning_of_month += 1.week
      week_of_month += 1
    end
    week_of_month -= 1 if beginning_of_month.wday < now.wday
    return week_of_month
=end
  end

  def formatted
    self.strftime('%r on %b %-d, %Y')
  end

  def informal
    self.strftime('%b %-d, %Y')
  end

  def between_times
    if self.min >= 30
      "#{'%02d' % self.hour.to_s}:30 - #{('%02d' % (self.hour + 1).to_s)%24}:00"
    else
      "#{'%02d' % self.hour.to_s}:00 - #{'%02d' % self.hour.to_s}:30"
    end
  end


  def first_monday_of_month
    t = Time.new(year, month, 1)
    t += 1.day until t.monday?
    t
  end
end