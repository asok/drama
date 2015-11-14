if defined?(RSpec)
  require 'drama/rspec/act_example_group'
  require 'drama/rspec/matchers'
  RSpec.configuration.include(Drama::RSpec::ActExampleGroup, type: :act)
end
