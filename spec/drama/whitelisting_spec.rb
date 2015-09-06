require 'spec_helper'

RSpec.describe Drama::Whitelisting do
  describe '#initialize' do
    it 'assigns the require attribute' do
      expect(described_class.new(:foo).required).to eq(:foo)
    end
  end

  describe '::permit' do
    it 'assigns the permit attribute' do
      expect(described_class.new(:foo).permit(:baz, :bar).permitted).to eq([:baz, :bar])
    end
  end
end
