require 'bundler/setup'
Bundler.setup

require 'pry'
require 'xdrgen'

SPEC_ROOT = 'spec'

Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|

end
