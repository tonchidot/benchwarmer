$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'fakeweb'
require 'benchwarmer'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

FakeWeb.allow_net_connect = false

RSpec.configure do |config|
  config.before(:each) do
    FakeWeb.clean_registry
    # Set up any variables needed here...
  end
end
