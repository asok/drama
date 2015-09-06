require 'spec_helper'

RSpec.describe Drama::Act do
  describe '#initialize' do
    let(:controller){ Object.new }

    it{ should respond_to :controller }
    it{ should respond_to :controller= }

    it 'assigns the passed controller' do
      expect(described_class.new(controller).controller).to eq(controller)
    end

    context 'the whitelisting class attribute is set' do
      subject { act_class.new(controller) }

      let(:act_class) do
        Class.new(described_class) do
          require_params(:foo).permit(:bar, :baz)
          require_params(:bar).permit(:foo, :baz)
        end
      end

      let(:controller) do
        Struct.new(:params).
          new(ActionController::Parameters.new(foo: {bar: 'bar', baz: 'baz'},
                                               bar: {foo: 'foo', baz: 'baz'}))
      end

      it 'assigns params to the attribute' do
        expect(subject.foo_params).to be_a(ActionController::Parameters)
        expect(subject.bar_params).to be_a(ActionController::Parameters)
      end

      it 'the assigned params are whitelisted' do
        expect(subject.foo_params).to be_permitted
        expect(subject.bar_params).to be_permitted
      end
    end
  end

  describe '#call' do
    it 'raises NotImplementedError' do
      expect{ described_class.new.call }.to raise_error(NotImplementedError)
    end
  end

  describe '::require_params' do
    let(:act_class) do
      Class.new(described_class)
    end

    it 'returns Whitelist object' do
      expect(act_class.require_params(:foo)).to be_a(Drama::Whitelisting)
    end

    it 'adds the Whitelisting objects to whitelisting attribute' do
      expect {
        act_class.require_params(:foo)
        act_class.require_params(:bar)
      }.to change{
        act_class.whitelisting
      }.from(nil).to([instance_of(Drama::Whitelisting), instance_of(Drama::Whitelisting)])
    end

    it 'creates an instance attributes based on the required argument' do
      expect {
        act_class.require_params(:foo)
        act_class.require_params(:bar)
      }.to change{
        act_class.public_instance_methods.include?(:foo_params) &&
        act_class.public_instance_methods.include?(:bar_params)
      }.from(false).to(true)
    end


    it 'returns Whitelist object with require key set' do
      expect(act_class.require_params(:foo).required).to eq(:foo)
    end
  end
end
