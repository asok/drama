require 'spec_helper'

RSpec.describe Drama::Matchers do
  subject do
    Class.new do
      include Drama::Matchers
    end.new
  end

  it{ should respond_to(:act_on) }
end
