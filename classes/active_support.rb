require 'date'

require_relative 'lib/hash'
require_relative 'lib/date'
require_relative 'lib/time'
require_relative 'lib/fixnum'
require_relative 'lib/array'
require_relative 'lib/file'


if $0 == __FILE__
  require 'pry'
  binding.pry
end
