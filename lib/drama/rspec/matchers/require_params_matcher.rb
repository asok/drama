module Drama
  module RSpec
    module Matchers
      module RequireParams
        def require_params(key)
          RequireParamsMatcher.new(key)
        end
      end

      class RequireParamsMatcher
        def initialize(required)
          @required = required
        end

        def matches?(act)
          @act = act

          act.whitelisting.any? do |listing|
            listing.required == @required &&
              listing.permitted.sort(&method(:sort)) == @permitted.sort(&method(:sort))
          end
        end

        def and_permit(*permitted)
          @permitted = permitted
          self
        end

        def description
          "requires #{@required} in params and permits #{@permitted}"
        end

        def failure_message
          actual = @act.whitelisting.find{ |listing| listing.required == @required }
          msg = "expected Act to require #{@required} and permit #{@permitted}"

          if actual
            "#{msg} but only #{actual.permitted} was permitted"
          else
            "#{msg} but no such key was required"
          end
        end
        alias_method :failure_message_for_should, :failure_message

        def failure_message_when_negated
          "expected Act to not require #{@required} and permit #{@permitted} but it does"
        end
        alias_method :failure_message_for_should_not, :failure_message_when_negated

        private

        def sort(a, b)
          if a.is_a?(Hash)
            -1
          elsif b.is_a?(Hash)
            1
          else
            a <=> b
          end
        end
      end
    end
  end
end
