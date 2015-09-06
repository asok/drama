require 'spec_helper'

RSpec.describe Drama do
  class CreateUserAct < Drama::Act
  end

  class FetchUsersAct < Drama::Act
  end

  def controller_class(&blk)
    Class.new do
      include Drama

      def self.controller_name
        'users'
      end

      def params
        ActionController::Parameters.new({})
      end

      class_eval(&blk)
    end
  end

  describe '::acts_on' do
    let(:controller) do
      _args = args #to introduce args in the current scope
      controller_class do
        acts_on(*_args)
      end
    end

    context 'passing name of the action with class' do
      let(:args){ [create: CreateUserAct] }

      it 'stores the act' do
        expect(controller.acts).to eq(create: CreateUserAct)
      end
    end

    context 'passing the name of the action only' do
      let(:args){ [:create] }

      it 'finds the constant using controller_name and stores the act' do
        expect(controller.acts).to eq(create: CreateUserAct)
      end

      context 'the constant is not defined' do
        it 'gives back explanatory message' do
          expect {
            controller_class { acts_on :update }
          }.to raise_error('Please create UpdateUserAct class in the app/acts directory')
        end
      end
    end

    context 'passing class and the name of the action' do
      let(:args){ [:create, {index: FetchUsersAct}] }

      it 'stores the acts' do
        expect(controller.acts).to eq(create: CreateUserAct, index: FetchUsersAct)
      end
    end
  end

  describe '#act' do
    let(:controller) do
      controller_class do
        acts_on :create

        def action_name
          "create"
        end
      end.new
    end

    it 'returns the instantiated act for the given action' do
      expect(controller.act).to be_a(CreateUserAct)
    end

    it 'returns the instantiated act with the controller object' do
      expect(controller.act.controller).to eq(controller)
    end

    context 'there is no act registered for the given action' do
      let(:controller) do
        controller_class do
          acts_on :create

          def action_name
            "update"
          end
        end.new
      end

      it 'raises error' do
        expect{ controller.act }.to raise_error("No act was registered for action 'update'")
      end
    end
  end

  describe '#act!' do
    let(:controller) do
      controller_class do
        acts_on :create

        def action_name
          "create"
        end
      end.new
    end

    before do
      CreateUserAct.class_eval do
        def call(arg)
          "called with #{arg}"
        end
      end
    end

    it 'calls the method call on the instantiated act' do
      expect(controller.act!(1)).to eq("called with 1")
    end
  end
end
