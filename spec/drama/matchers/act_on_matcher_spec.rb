require 'spec_helper'

RSpec.describe Drama::Matchers::ActOnMatcher do
  class NewUserAct
  end

  describe 'usage' do
    subject do
      Class.new do
        include Drama

        def self.controller_name
          "users"
        end

        acts_on(:new)
      end.new
    end

    before do
      RSpec.configure do |config|
        config.include(Drama::Matchers::ActOn)
      end
    end

    it{ should     act_on(:new) }
    it{ should     act_on(:new).with(NewUserAct) }
    it{ should_not act_on(:create).with(NewUserAct) }
  end
end
