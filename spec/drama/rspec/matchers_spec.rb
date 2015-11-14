require 'spec_helper'

RSpec.describe Drama::RSpec::Matchers do
  subject do
    Class.new do
      include Drama::RSpec::Matchers
    end.new
  end

  it{ should respond_to(:act_on) }
  it{ should respond_to(:require_params) }
end
