$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'rasem'
require 'simplecov'
SimpleCov.start

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end


def class_hierarchy(obj)
  classes = []
  c = obj.class
  while c != Object
    classes << c
    c = c.superclass
  end
  classes
end
