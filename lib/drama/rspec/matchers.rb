require 'drama/rspec/matchers/act_on_matcher'
require 'drama/rspec/matchers/require_params_matcher'

module Drama
  module RSpec
    module Matchers
      include ActOn
      include RequireParams
    end
  end
end
