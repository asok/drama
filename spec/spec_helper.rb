$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'drama'

require 'action_controller'

RSpec.configure do |config|
  config.include(Drama::Matchers)
end
