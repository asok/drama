if defined?(RSpec)
  require 'drama/rspec/act_example_group'
  RSpec.configuration.include(Drama::RSpec::ActExampleGroup, type: :act)
end
