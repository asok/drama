require 'spec_helper'

RSpec.describe Drama::Matchers::RequireParamsMatcher do
  describe 'usage' do
    subject do
      Class.new(Drama::Act) do
        require_params(:foo).permit(:baz, :bar)
      end
    end

    it{ should     require_params(:foo).and_permit(:bar, :baz) }
    it{ should_not require_params(:foo).and_permit(:bar) }
  end
end
