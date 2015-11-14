module Drama
  module RSpec
    module Matchers
      module ActOn
        def act_on(action_name)
          ActOnMatcher.new(action_name)
        end
      end

      class ActOnMatcher
        def initialize(action_name)
          @action_name = action_name
        end

        def matches?(controller)
          @controller = controller

          if @expected_act_class
            @controller.class.acts[@action_name.intern] == @expected_act_class
          else
            @controller.class.acts.has_key?(@action_name.intern)
          end
        end

        def with(act_class)
          @expected_act_class = act_class
          self
        end

        def description
          msg = "act on #{@action_name}"
          if @expected_act_class
            "#{msg} with #{@expected_act_class}"
          else
            msg
          end
        end

        def failure_message
          msg = "expected to act on #{@action_name}"

          if @expected_act_class
            msg = "#{msg} with #{@expected_act_class} but it"

            if act_class = @controller.class.acts[@action_name]
              "#{msg} acts with #{act_class}"
            else
              "#{msg} acts with nothing"
            end
          else
            msg
          end
        end
        alias_method :failure_message_for_should, :failure_message

        def failure_message_when_negated
          "expected to not act on #{@action_name} with #{@expected_act_class} but it does"
        end
        alias_method :failure_message_for_should_not, :failure_message_when_negated
      end
    end
  end
end
