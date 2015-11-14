if defined?(RSpec)
  require 'drama/rspec/act_example_group'
  require 'drama/rspec/matchers'
  RSpec.configuration.include(Drama::RSpec::ActExampleGroup,         type: :act)
  RSpec.configuration.include(Drama::RSpec::Matchers::RequireParams, type: :act)
  RSpec.configuration.include(Drama::RSpec::Matchers::ActOn,         type: :controller)
end
