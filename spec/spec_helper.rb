require 'bundler/setup'
Bundler.setup

require 'xdrgen'

Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|

end
