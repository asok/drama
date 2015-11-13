require 'spec_helper'
require 'action_pack'

RSpec.describe Drama::RSpec::ActExampleGroup do
  let(:group) do
    RSpec::Core::ExampleGroup.describe superclass do
      include Drama::RSpec::ActExampleGroup
    end
  end
  let(:superclass){ Class.new(Drama::Act) }

  it "includes routing matchers" do
    expect(group.included_modules).to include(Drama::RSpec::ActExampleGroup)
  end

  describe '#controller' do
    before do
      group.class_exec do
        controller do
          def baz
            {foo: :bar}
          end
        end
      end
    end

    it 'memoizes the controller' do
      expect(group.new.controller.baz).to eq({foo: :bar})
    end

    describe 'accessing the context of the example' do
      before do
        group.class_exec do
          let(:bar){ 'foo' }

          controller do
            def baz
              bar
            end
          end
        end
      end

      it 'is possible to use methods defined outside of the block' do
        expect(group.new.controller.baz).to eq('foo')
      end
    end

    context 'the controller defines param method' do
      before do
        group.class_exec do
          controller do
            def params
              {foo: :bar}
            end
          end
        end
      end

      it 'makes the returned value to be ActionController::Parameters' do
        expect(group.new.controller.params).to be_a_kind_of(ActionController::Parameters)
      end
    end
  end

  describe '#act' do
    let(:example) { group.new }

    context 'the controller was setup' do
      before do
        group.class_exec do
          controller do
          end
        end
      end

      it 'returns the described act object initialized with the controller' do
        expect(example.act).to be_a(superclass)
        expect(example.act.controller).to_not be_nil
      end
    end

    context 'the controller was not setup' do
      it 'sets up subject to be an instance of act initialized with a fake controller' do
        expect(example.act).to be_a(superclass)
        expect(example.act.controller).to be_a(Drama::RSpec::FakeController)
      end
    end
  end

  describe '#act!' do
    let(:example) { group.new }

    context 'the controller was setup' do
      let(:superclass) do
        Class.new(Drama::Act) do
          def call
            true
          end
        end
      end

      it 'sends `call` message to the instantieted act' do
        expect(example.act!).to be true
      end
    end
  end
end
