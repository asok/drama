require 'active_support/concern'

module Drama
  module RSpec
    module ActExampleGroup
      extend ::ActiveSupport::Concern

      module ClassMethods
        def controller(&blk)
          @__controller__ = Class.new(Object, &blk).new
          if @__controller__.respond_to? :params
             @__controller__.class_eval do
               alias_method :__params__, :params

               def params
                 ActionController::Parameters.new(__params__)
               end
             end
          end
        end
      end

      included do
        subject { described_class.new(@__controller__) }
      end
    end

    class Configuration
      def self.initialize_configuration(config)
        config.include(Drama::RSpec::ActExampleGroup, type: :act)
      end

      initialize_configuration(::RSpec.configuration) if defined?(RSpec)
    end
  end
end
