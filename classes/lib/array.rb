class Array

  def not_empty?
    !self.empty?
  end

  def average
    temp = self.compact
    temp.map! {|e| e.is_a?(String) && (e.match(/\d/)) ? e.to_f : e}
    return nil if (temp.not_empty?) && (temp.reject! {|e| !e.is_a? Numeric}; temp.empty?)
    return 0.0 if temp.empty?

    temp.inject(:+) / temp.length.to_f
  end


  ### The following #extract_options! is copied from Rails

  # Extracts options from a set of arguments. Removes and returns the last
  # element in the array if it's a hash, otherwise returns a blank hash.
  #
  #   def options(*args)
  #     args.extract_options!
  #   end
  #
  #   options(1, 2)           # => {}
  #   options(1, 2, :a => :b) # => {:a=>:b}
  def extract_options!
    if last.is_a?(Hash) && last.extractable_options?
      pop
    else
      {}
    end
  end


end
