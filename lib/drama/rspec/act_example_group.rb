require 'active_support/concern'
require 'drama/rspec/fake_controller'
require 'drama/rspec/fallback_to_example_controller'

module Drama
  module RSpec
    module ActExampleGroup
      extend ::ActiveSupport::Concern

      module ClassMethods
        def controller(&blk)
          controller = Class.new(Drama::RSpec::FallbackToExampleController, &blk).new

          if controller.respond_to? :params
             controller.class_eval do
               alias_method :__params__, :params

               def params
                 ActionController::Parameters.new(__params__)
               end
             end
          end

          let(:controller) do
            controller.__example__ = self
            controller
          end
        end
      end

      included do
        let(:controller){ Drama::RSpec::FakeController.new }

        def act
          described_class.new(controller)
        end

        def act!(*args)
          act.call(*args)
        end
      end
    end
  end
end
