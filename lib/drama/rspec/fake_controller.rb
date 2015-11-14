module Drama
  module RSpec
    class FakeController
      def method_missing(*)
        raise NotImplementedError.new(<<-MSG)
The controller was not setup for the example. Please use Example#controller like that:
describe Act do
  controller do
    def params
      {foo: :bar}
    end
  end
end
MSG
      end
    end
  end
end
