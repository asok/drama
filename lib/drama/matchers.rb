require 'drama/matchers/act_on_matcher'
require 'drama/matchers/require_params_matcher'

module Drama
  module Matchers
    include ActOn
    include RequireParams
  end
end
