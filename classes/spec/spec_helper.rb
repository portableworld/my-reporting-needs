#RSpec.configure do |config|
#  config.before(:all, &:silence_output)
#  config.after(:all, &:enable_output)
#end

RSpec.configure do |config|
  orig_stderr = $stderr
  orig_stdout = $stdout
  config.before(:all) do
    $stderr = File.new(File.join(File.dirname(__FILE__),'/dev/null.txt'), 'w')
    $stdout = File.new(File.join(File.dirname(__FILE__),'/dev/null.txt'), 'w')
  end
  config.after(:all) do
    $stderr = orig_stderr
    $stdout = orig_stdout
  end
end

__END__
 public
# Redirects stderr and stdout to /dev/null.
def silence_output
  @orig_stderr = $stderr
  @orig_stdout = $stdout

  # redirect stderr and stdout to /dev/null
  $stderr = File.new(File.join(File.dirname(__FILE__),'/dev/null.txt'), 'w')
  $stdout = File.new(File.join(File.dirname(__FILE__),'/dev/null.txt'), 'w')
end

# Replace stdout and stderr so anything else is output correctly.
def enable_output
  $stderr = @orig_stderr
  $stdout = @orig_stdout
  @orig_stderr = nil
  @orig_stdout = nil
end
